// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import RxSwift
import ToolKit

// swiftformat:disable indent

extension ObservableConvertibleType {

    public var publisher: Observable<Element>.Publisher<Self> {
        Observable.Publisher(upstream: self)
    }

    public func asPublisher() -> Observable<Element>.Publisher<Self> {
        publisher
    }

    public func await() async throws -> Element {
        try await publisher.stream().next()
    }
}

extension Observable {

    @dynamicMemberLookup
    public struct Publisher<Upstream: ObservableConvertibleType>: Combine.Publisher {

        public typealias Output = Upstream.Element
        public typealias Failure = Swift.Error

        private let upstream: Upstream

        init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S: Subscriber>(
            subscriber: S
        ) where Failure == S.Failure, Output == S.Input {
            subscriber.receive(
                subscription: Subscription(
                    upstream: upstream,
                    downstream: subscriber
                )
            )
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Output, T>) -> Publishers.MapKeyPath<Self, T> {
            map(keyPath)
        }
    }

    final class Subscription<
        Upstream: ObservableConvertibleType,
        Downstream: Subscriber
    >: Combine.Subscription where
        Downstream.Input == Upstream.Element,
        Downstream.Failure == Swift.Error
    {

        private var lock: NSRecursiveLock = .init()
        private var observable: Observable<Upstream.Element>
        private var downstream: Downstream
        private var disposable: Disposable?

        init(upstream: Upstream, downstream: Downstream) {
            self.observable = upstream.asObservable()
            self.downstream = downstream
        }

        func request(_ demand: Subscribers.Demand) {
            guard disposable == nil else { return }
            disposable = observable.subscribe { [weak self] event in
                guard let self else { return }
                self.lock.lock()
                defer { self.lock.unlock() }
                switch event {
                case .next(let element):
                    _ = self.downstream.receive(element)
                case .error(let error):
                    self.downstream.receive(completion: .failure(error))
                case .completed:
                    self.downstream.receive(completion: .finished)
                }
            }
        }

        func cancel() {
            disposable?.dispose()
            disposable = nil
        }
    }
}

extension ObservableType {

    public func withPrevious() -> Observable<(Element?, Element)> {
        scan([]) { previous, current in
            Array(previous + [current]).suffix(2)
        }
        .map { arr -> (previous: Element?, current: Element) in
            (arr.count > 1 ? arr.first : nil, arr.last!)
        }
    }
}

extension ObservableType where Element: OptionalProtocol {
    func onNil(error: Error) -> Observable<Element.Wrapped> {
        map { element -> Element.Wrapped in
            guard let value = element.wrapped else {
                throw error
            }
            return value
        }
    }
}

extension ObservableType {

    public func map<A: AnyObject, R>(
        weak object: A,
        _ selector: @escaping (A, Element) throws -> R
    ) -> Observable<R> {
        map { [weak object] element -> R in
            guard let object else {
                throw ToolKitError.nullReference(A.self)
            }
            return try selector(object, element)
        }
    }
}

extension ObservableType {

    public func flatMap<A: AnyObject, R>(
        weak object: A,
        selector: @escaping (A, Self.Element) throws -> Observable<R>
    ) -> Observable<R> {
        flatMap { [weak object] value -> Observable<R> in
            guard let object else {
                throw ToolKitError.nullReference(A.self)
            }
            return try selector(object, value)
        }
    }

    public func flatMapLatest<A: AnyObject, R>(
        weak object: A,
        selector: @escaping (A, Self.Element) throws -> Observable<R>
    ) -> Observable<R> {
        flatMapLatest { [weak object] value -> Observable<R> in
            guard let object else {
                throw ToolKitError.nullReference(A.self)
            }
            return try selector(object, value)
        }
    }

    public func flatMapFirst<A: AnyObject, R>(
        weak object: A,
        selector: @escaping (A, Self.Element) throws -> Observable<R>
    ) -> Observable<R> {
        flatMapFirst { [weak object] value -> Observable<R> in
            guard let object else {
                throw ToolKitError.nullReference(A.self)
            }
            return try selector(object, value)
        }
    }
}

// MARK: - Creation (weak: self)

extension ObservableType {
    public static func create<A: AnyObject>(
        weak object: A,
        subscribe: @escaping (A, AnyObserver<Element>) -> Disposable
    ) -> Observable<Element> {
        Observable<Element>.create { [weak object] observer -> Disposable in
            guard let object else {
                observer.on(.error(ToolKitError.nullReference(A.self)))
                return Disposables.create()
            }
            return subscribe(object, observer)
        }
    }
}

// MARK: - Catch Error Op

extension ObservableType {
    public func catchError<A: AnyObject>(
        weak object: A,
        _ selector: @escaping (A, Swift.Error) throws -> Observable<Element>
    ) -> Observable<Element> {
        `catch` { [weak object] error -> Observable<Element> in
            guard let object else {
                throw ToolKitError.nullReference(A.self)
            }
            return try selector(object, error)
        }
    }
}

// MARK: - Result<Element, Error> mapping

extension ObservableType {

    /// Directly maps to `Result<Element, Error>` type.
    public func mapToResult() -> Observable<Result<Element, Error>> {
        map(Result.success)
            .catch { .just(.failure($0)) }
    }

    /// Map with success and failure mappers.
    /// This is useful in case we would like to have a custom error type.
    public func mapToResult<ResultElement, OutputError: Error>(
        successMap: @escaping (Element) -> ResultElement,
        errorMap: @escaping (Error) -> OutputError
    ) -> Observable<Result<ResultElement, OutputError>> {
        map { .success(successMap($0)) }
            .catch { .just(.failure(errorMap($0))) }
    }

    /// Map with success mapper only.
    public func mapToResult<ResultElement>(
        successMap: @escaping (Element) -> ResultElement
    ) -> Observable<Result<ResultElement, Error>> {
        map { .success(successMap($0)) }
            .catch { .just(.failure($0)) }
    }
}

import RxRelay

extension ObservableType {

    public func bindAndCatch(
        to relays: PublishRelay<Element>...,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable {
        _bind(to: relays, file: file, line: line, function: function)
    }

    private func _bind(
        to relays: [PublishRelay<Element>],
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable {
        `do`(onError: { error in
            fatalError(
                """
                Binding error to publish relay.
                file: \(file), line: \(line), function: \(function), error: \(error).
                """
            )
        })
        .subscribe { event in
            switch event {
            case .next(let element):
                relays.forEach {
                    $0.accept(element)
                }
            case .error:
                break
            case .completed:
                break
            }
        }
    }

    public func bindAndCatch(
        to relays: BehaviorRelay<Element>...,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable {
        _bind(to: relays, file: file, line: line, function: function)
    }

    private func _bind(
        to relays: [BehaviorRelay<Element>],
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable {
        `do`(onError: { error in
            fatalError(
                """
                Binding error to behaviour relay.
                file: \(file), line: \(line), function: \(function), error: \(error).
                """
            )
        })
        .subscribe { event in
            switch event {
            case .next(let element):
                relays.forEach {
                    $0.accept(element)
                }
            case .error:
                break
            case .completed:
                break
            }
        }
    }

    public func bindAndCatch(
        to relays: BehaviorRelay<Element?>...,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> Disposable {
        map { $0 as Element? }
            ._bind(to: relays, file: file, line: line, function: function)
    }

    public func bindAndCatch<Observer: ObserverType>(
        to observers: Observer...,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable where Observer.Element == Element {
        _bind(to: observers, file: file, line: line, function: function)
    }

    public func bindAndCatch<Observer: ObserverType>(
        to observers: Observer...,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable where Observer.Element == Element? {
        map { $0 as Element? }
            ._bind(to: observers, file: file, line: line, function: function)
    }

    private func _bind<Observer: ObserverType>(
        to observers: [Observer],
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Disposable where Observer.Element == Element {
        self.do(onError: { error in
            fatalError(
                """
                Binding error to observers.
                file: \(file), line: \(line), function: \(function), error: \(error).
                """
            )
        })
        .subscribe { event in
            observers.forEach { $0.on(event) }
        }
    }

    public func bindAndCatch<Result>(to binder: (Self) -> Result) -> Result {
        binder(self)
    }
}

extension ObservableType {

    public func _debug(
        file: String = #file,
        line: UInt = #line,
        function: String = #function
    ) -> Observable<Element> {
        debug(
            "\(file).\(function)",
            trimOutput: false,
            file: file,
            line: line,
            function: function
        )
    }

    public func crashOnError(
        file: String = #file,
        line: UInt = #line,
        function: String = #function
    ) -> Observable<Element> {
        `do`(onError: { error in
            fatalError(String(describing: error))
        })
    }
}
