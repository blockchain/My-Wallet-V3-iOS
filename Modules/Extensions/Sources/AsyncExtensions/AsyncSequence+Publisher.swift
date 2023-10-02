// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(Combine)

import Combine
import Foundation
import SwiftExtensions

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

// Once it is possible to express conformance to a non-throwing async sequence we should create a new type
// `AsyncSequencePublisher<S: nothrow AsyncSequence>`. At the moment the safest thing to do is capture the error and
// allow the consumer to ignore it if they wish
public struct AsyncSequencePublisher<S: AsyncSequence, Failure: Error>: Combine.Publisher {

    public typealias Output = S.Element

    private var sequence: S

    public init(_ sequence: S) {
        self.sequence = sequence
    }

    public func receive<Subscriber>(
        subscriber: Subscriber
    ) where Subscriber: Combine.Subscriber, Failure == Subscriber.Failure, Output == Subscriber.Input {
        subscriber.receive(
            subscription: Subscription(subscriber: subscriber, sequence: sequence)
        )
    }

    final class Subscription<
        Subscriber: Combine.Subscriber
    >: Combine.Subscription where Subscriber.Input == Output, Subscriber.Failure == Failure {

        private var sequence: S
        private var subscriber: Subscriber
        private var isCancelled = false

        private var lock = UnfairLock()
        private var demand: Subscribers.Demand = .none
        private var task: Task<Void, Error>?

        init(subscriber: Subscriber, sequence: S) {
            self.sequence = sequence
            self.subscriber = subscriber
        }

        func request(_ __demand: Subscribers.Demand) {
            precondition(__demand > 0)
            lock.withLock { demand = __demand }
            guard task.isNil else { return }
            lock.lock(); defer { lock.unlock() }
            task = Task {
                var iterator = lock.withLock { sequence.makeAsyncIterator() }
                while lock.withLock(body: { !isCancelled && demand > 0 }) {
                    let element: S.Element?
                    do {
                        element = try await iterator.next()
                    } catch is CancellationError {
                        lock.withLock { subscriber }.receive(completion: .finished)
                        return
                    } catch let error as Failure {
                        lock.withLock { subscriber }.receive(completion: .failure(error))
                        throw CancellationError()
                    } catch {
                        assertionFailure("Expected \(Failure.self) but got \(type(of: error))")
                        throw CancellationError()
                    }
                    guard let element else {
                        lock.withLock { subscriber }.receive(completion: .finished)
                        throw CancellationError()
                    }
                    try Task.checkCancellation()
                    lock.withLock { demand -= 1 }
                    let newDemand = lock.withLock { subscriber }.receive(element)
                    lock.withLock { demand += newDemand }
                    await Task.yield()
                }
                task = nil
            }
        }

        func cancel() {
            lock.withLock {
                task?.cancel()
                isCancelled = true
            }
        }
    }
}
#endif
