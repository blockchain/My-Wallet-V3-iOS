// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(Combine)

import Combine
import Foundation
import SwiftExtensions

extension Publisher where Failure == Never {

    public func task<T>(
        priority: TaskPriority? = nil,
        maxPublishers demand: Subscribers.Demand = .unlimited,
        @_inheritActorContext @_implicitSelfCapture _ yield: __owned @Sendable @escaping (Output) async -> T
    ) -> AnyPublisher<T, Never> {
        flatMap(maxPublishers: demand) { value -> Task<T, Never>.Publisher in
            Task<T, Never>.Publisher(priority: priority) {
                await yield(value)
            }
        }
        .eraseToAnyPublisher()
    }

    public func task<T>(
        priority: TaskPriority? = nil,
        maxPublishers demand: Subscribers.Demand = .unlimited,
        @_inheritActorContext @_implicitSelfCapture _ yield: __owned @Sendable @escaping (Output) async throws -> T
    ) -> AnyPublisher<T, Error> {
        setFailureType(to: Error.self)
            .flatMap(maxPublishers: demand) { value -> Task<T, Error>.Publisher in
                Task<T, Error>.Publisher(priority: priority) {
                    try await yield(value)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func task<T>(
        priority: TaskPriority? = nil,
        maxPublishers demand: Subscribers.Demand = .unlimited,
        @_inheritActorContext @_implicitSelfCapture _ yield: __owned @Sendable @escaping (Output) async throws -> T
    ) -> AnyPublisher<T, Error> {
        mapError { $0 as Error }
            .flatMap(maxPublishers: demand) { value -> Task<T, Error>.Publisher in
                Task<T, Error>.Publisher(priority: priority) {
                    try await yield(value)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Task where Success: Sendable {

    public struct Publisher: Combine.Publisher, Sendable {

        public typealias Output = Success

        var priority: TaskPriority?
        var operation: @Sendable () async throws -> Output

        public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            subscriber.receive(
                subscription: Subscription(
                    priority: priority,
                    subscriber: AnySubscriber(
                        receiveSubscription: subscriber.receive(subscription:),
                        receiveValue: subscriber.receive(_:),
                        receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                subscriber.receive(completion: .finished)
                            case .failure(let error as Failure):
                                subscriber.receive(completion: .failure(error))
                            case .failure:
                                subscriber.receive(completion: .finished)
                            }
                        }
                    ),
                    operation: operation
                )
            )
        }
    }

    final class Subscription<S: Subscriber>: @unchecked Sendable, Cancellable, Combine.Subscription where S.Input == Success, S.Failure == Error {

        typealias Output = Success

        enum State {

            case ready(operation: @Sendable () async throws -> Success)
            case started(Task<Void, Never>)
            case finished

            func cancel() {
                switch self {
                case .finished, .ready: break
                case let .started(task): task.cancel()
                }
            }
        }

        private var lock = UnfairLock()
        private var state: State

        let priority: TaskPriority?
        let subscriber: S

        init(priority: TaskPriority?, subscriber: S, operation: __owned @Sendable @escaping () async throws -> Output) {
            self.priority = priority
            self.state = .ready(operation: operation)
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            lock.withLock {
                switch state {
                case let .ready(operation):
                    let task = Task<Void, Never>(priority: priority) {
                        defer { lock.withLock { state = .finished } }
                        do {
                            let output = try await operation()
                            guard !Task<Never, Never>.isCancelled else { return }
                            _ = subscriber.receive(output)
                            subscriber.receive(completion: .finished)
                        } catch {
                            guard !Task<Never, Never>.isCancelled else { return }
                            subscriber.receive(completion: .failure(error))
                        }
                    }
                    state = .started(task)
                case .started, .finished:
                    break
                }
            }
        }

        func cancel() {
            lock.withLock {
                state.cancel()
                state = .finished
            }
        }
    }
}

extension Task.Publisher where Failure == Never {

    public init(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ operation: __owned @Sendable @escaping () async -> Output
    ) where Failure == Never {
        self.priority = priority
        self.operation = operation
    }
}

extension Task.Publisher where Failure == Error {

    public init(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ operation: __owned @Sendable @escaping () async throws -> Output
    ) {
        self.priority = priority
        self.operation = operation
    }
}

#endif
