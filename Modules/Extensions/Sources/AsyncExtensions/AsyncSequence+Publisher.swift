// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(Combine)

import Combine
import Foundation

extension AsyncSequence {

    public func publisher() -> AsyncSequencePublisher<Self, Error> {
        .init(self)
    }
}

extension AsyncStream {

    public func publisher() -> AsyncSequencePublisher<Self, Never> {
        .init(self)
    }
}

extension AsyncThrowingStream {

    public func publisher() -> AsyncSequencePublisher<Self, Failure> {
        .init(self)
    }
}

/// Once it is possible to express conformance to a non-throwing async sequence
/// we should create a new type `AsyncSequencePublisher<Seq: nothrow AsyncSequence>`.
/// At the moment the safest thing to do is capture the error and allow the consumer to ignore it if they wish
public struct AsyncSequencePublisher<Seq: AsyncSequence, Failure: Error>: Combine.Publisher {

    public typealias Output = Seq.Element

    private var sequence: Seq

    public init(_ sequence: Seq) {
        self.sequence = sequence
    }

    public func receive<Sub>(
        subscriber: Sub
    ) where Sub: Subscriber, Failure == Sub.Failure, Output == Sub.Input {
        subscriber.receive(
            subscription: Subscription(subscriber: subscriber, sequence: sequence)
        )
    }

    actor Subscription<
        Subscriber: Combine.Subscriber
    >: Combine.Subscription where Subscriber.Input == Output, Subscriber.Failure == Failure {

        private var sequence: Seq
        private var subscriber: Subscriber
        private var isCancelled = false

        private var demand: Subscribers.Demand = .none
        private var task: Task<Void, Error>?

        init(subscriber: Subscriber, sequence: Seq) {
            self.sequence = sequence
            self.subscriber = subscriber
        }

        nonisolated func request(_ demand: Subscribers.Demand) {
            Task { await _request(demand) }
        }

        private func _request(_ __demand: Subscribers.Demand) {
            demand = __demand
            guard demand > 0 else { return }
            task?.cancel()
            task = Task {
                var iterator = sequence.makeAsyncIterator()
                while !isCancelled, demand > 0 {
                    let element: Seq.Element?
                    do {
                        element = try await iterator.next()
                    } catch is CancellationError {
                        subscriber.receive(completion: .finished)
                        return
                    } catch let error as Failure {
                        subscriber.receive(completion: .failure(error))
                        throw CancellationError()
                    } catch {
                        assertionFailure("Expected \(Failure.self) but got \(type(of: error))")
                        throw CancellationError()
                    }
                    guard let element else {
                        subscriber.receive(completion: .finished)
                        throw CancellationError()
                    }
                    try Task.checkCancellation()
                    demand -= 1
                    demand += subscriber.receive(element)
                    await Task.yield()
                }
            }
        }

        nonisolated func cancel() {
            Task { await _cancel() }
        }

        private func _cancel() {
            task?.cancel()
            isCancelled = true
        }
    }
}
#endif
