// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension AnyPublisher {

    public static func just(
        _ value: Output
    ) -> AnyPublisher<Output, Failure> {
        Just(value)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

    public static func failure(
        _ error: Failure
    ) -> AnyPublisher<Output, Failure> {
        Fail(error: error).eraseToAnyPublisher()
    }

    public static func empty() -> AnyPublisher<Output, Failure> {
        Empty().eraseToAnyPublisher()
    }
}

extension Publisher where Output: OptionalProtocol {

    public func onNil(_ error: Failure) -> AnyPublisher<Output.Wrapped, Failure> {
        flatMap { element -> AnyPublisher<Output.Wrapped, Failure> in
            guard let value = element.wrapped else {
                return .failure(error)
            }
            return .just(value)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {

    public func mapError<E: Error>(to type: E.Type = E.self) -> AnyPublisher<Output, E> {
        setFailureType(to: E.self).eraseToAnyPublisher()
    }
}

extension Publisher {

    public func eraseError() -> AnyPublisher<Output, Error> {
        mapError { $0 }.eraseToAnyPublisher()
    }

    public func replaceError<E: Error>(with error: E) -> AnyPublisher<Output, E> {
        mapError { _ -> E in
            error
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func optional() -> AnyPublisher<Output?, Failure> {
        map { element -> Output? in
            element
        }
        .eraseToAnyPublisher()
    }

    public func mapToVoid() -> AnyPublisher<Void, Failure> {
        replaceOutput(with: ())
    }
}

extension Publisher {

    public func replaceOutput<O>(with output: O) -> AnyPublisher<O, Failure> {
        map { _ -> O in
            output
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {

    /// Subscribes to a `Publisher` ignoring all published events
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    ///
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func subscribe() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}

extension Publisher {

    /// Similar to flatMap but this will cancel the subscription to the previous one, keeping only a single
    /// subscription active along with its event emissions
    ///
    /// - Parameter transform: A transform to apply to each emitted value, from which you can return a new Publisher
    ///
    /// - note: This operator is a combination of `map` and `switchToLatest`
    ///
    /// - returns: A publisher emitting the values of the latest inner publisher
    public func flatMapLatest<P: Publisher>(
        _ transform: @escaping (Output) -> P
    ) -> Publishers.SwitchToLatest<P, Publishers.Map<Self, P>> {
        map(transform).switchToLatest()
    }
}

extension AnyPublisher {
    init(builder: @escaping (AnySubscriber<Output, Failure>) -> any Cancellable) {
        self.init(
            Deferred<Publishers.HandleEvents<PassthroughSubject<Output, Failure>>> {
                let subject = PassthroughSubject<Output, Failure>()
                var cancellable: Cancellable?
                cancellable = builder(AnySubscriber(subject))
                return subject
                    .handleEvents(
                        receiveCancel: {
                            cancellable?.cancel()
                            cancellable = nil
                        }
                    )
            }
        )
    }
}
