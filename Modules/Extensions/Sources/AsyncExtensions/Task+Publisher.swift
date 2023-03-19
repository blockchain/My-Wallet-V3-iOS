// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(Combine)

import Combine
import Foundation

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
        @_inheritActorContext @_implicitSelfCapture _ yield: __owned @Sendable  @escaping (Output) async throws -> T
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

extension Task {

    public struct Publisher: Combine.Publisher {

        public typealias Output = Success

        private let priority: TaskPriority?
        private let yield: @Sendable () async throws -> Output

        actor Subscription: Combine.Subscription where Failure == Never {

            private let yield: @Sendable () async throws -> Output
            private let priority: TaskPriority?
            private var task: Task<Void, Never>?
            private var downstream: AnySubscriber<Output, Failure>?

            init<Downstream>(
                priority: TaskPriority?,
                yield: @escaping @Sendable () async throws -> Output,
                downstream: Downstream
            ) where Downstream: Subscriber, Output == Downstream.Input, Downstream.Failure == Failure {
                self.priority = priority
                self.yield = yield
                self.downstream = AnySubscriber(downstream)
            }

            func receive(_ input: Output) {
                _ = downstream?.receive(input)
                downstream?.receive(completion: .finished)
                task = nil
                downstream = nil
            }

            nonisolated func request(_ demand: Subscribers.Demand) {
                Task<Void, Never> { await _request(demand) }
            }

            private func _request(_ demand: Subscribers.Demand) {
                guard demand > 0 else { return }
                guard task == nil else { return }
                task = .detached { [yield, weak self] in
                    do {
                        let value = try await yield()
                        await self?.receive(value)
                    } catch { /* none */ }
                }
            }

            nonisolated func cancel() {
                Task<Void, Never> { await _cancel() }
            }

            private func _cancel() {
                task?.cancel()
                task = nil
                downstream = nil
            }
        }

        actor ThrowingSubscription: Combine.Subscription {

            typealias Failure = Error

            private let yield: @Sendable () async throws -> Output
            private let priority: TaskPriority?
            private var task: Task<Void, Never>?
            private var downstream: AnySubscriber<Output, Error>?

            init<Downstream>(
                priority: TaskPriority?,
                yield: @escaping @Sendable () async throws -> Output,
                downstream: Downstream
            ) where Downstream: Subscriber, Output == Downstream.Input, Downstream.Failure == Failure {
                self.priority = priority
                self.yield = yield
                self.downstream = AnySubscriber(downstream)
            }

            nonisolated func request(_ demand: Subscribers.Demand) {
                Task<Void, Never> { await _request(demand) }
            }

            func _request(_ demand: Subscribers.Demand) {
                guard demand > 0 else { return }
                guard task == nil else { return }
                task = .detached(priority: priority) { [yield, weak self] in
                    guard let self else { return }
                    do {
                        let value = try await yield()
                        await self.receive(value)
                    } catch {
                        await self.receive(error: error)
                    }
                }
            }

            nonisolated func cancel() {
                Task<Void, Never> { await _cancel() }
            }

            func _cancel() {
                task?.cancel()
                task = nil
                downstream = nil
            }

            private func receive(_ input: Output) {
                _ = downstream?.receive(input)
                downstream?.receive(completion: .finished)
                task = nil
                downstream = nil
            }

            private func receive(error: Failure) {
                _ = downstream?.receive(completion: .failure(error))
                task = nil
                downstream = nil
            }
        }
    }
}

extension Task.Publisher where Failure == Never {

    public init(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ yield: __owned @Sendable @escaping () async -> Output
    ) where Failure == Never {
        self.priority = priority
        self.yield = yield
    }
}

extension Task.Publisher where Failure == Error {

    public init(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ yield: __owned @Sendable @escaping () async throws -> Output
    ) {
        self.priority = priority
        self.yield = yield
    }
}

extension Task.Publisher where Failure == Never {

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(
            subscription: Subscription(priority: priority, yield: yield, downstream: subscriber)
        )
    }
}

extension Task.Publisher where Failure == Error {

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(
            subscription: ThrowingSubscription(priority: priority, yield: yield, downstream: subscriber)
        )
    }
}

extension Task.Publisher {

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(
            subscription: ThrowingSubscription(priority: priority, yield: yield, downstream: AnySubscriber(
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
            ))
        )
    }
}

#endif
