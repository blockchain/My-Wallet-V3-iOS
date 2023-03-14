// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

extension PrimitiveSequenceType where Trait == SingleTrait, Element: OptionalProtocol {
    public func onNil(error: Error) -> Single<Element.Wrapped> {
        map { element -> Element.Wrapped in
            guard let value = element.wrapped else {
                throw error
            }
            return value
        }
    }

    public func onNilJustReturn(_ fallback: Element.Wrapped) -> Single<Element.Wrapped> {
        map { element -> Element.Wrapped in
            guard let value = element.wrapped else {
                return fallback
            }
            return value
        }
    }
}

extension Single {
    public func flatMap<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> Single<R>) -> Single<R> {
        asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asSingle()
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func map<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> R) -> PrimitiveSequence<SingleTrait, R> {
        map { [weak object] element -> R in
            guard let object else {
                throw ToolKitError.nullReference(A.self)
            }
            return try selector(object, element)
        }
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    public func flatMap<A: AnyObject>(weak object: A, _ selector: @escaping (A) throws -> Completable) -> Completable {
        do {
            return try asObservable().ignoreElements().asCompletable().andThen(selector(object))
        } catch {
            return .error(error)
        }
    }

    /// Convert from `Completable` into `Single`
    public func flatMapSingle<A: AnyObject, R>(weak object: A, _ selector: @escaping (A) throws -> Single<R>) -> Single<R> {
        do {
            return try asObservable().ignoreElements().asCompletable().andThen(selector(object))
        } catch {
            return .error(error)
        }
    }

    /// Convert from `Completable` into `Single`
    public func flatMapSingle<R>(_ selector: @escaping () throws -> Single<R>) -> Single<R> {
        do {
            return try asObservable().ignoreElements().asCompletable().andThen(selector())
        } catch {
            return .error(error)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func flatMapCompletable<A: AnyObject>(weak object: A, _ selector: @escaping (A, Element) throws -> Completable)
        -> Completable
    {
        asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asCompletable()
    }

    public static func create<A: AnyObject>(weak object: A, subscribe: @escaping (A, @escaping SingleObserver) -> Disposable) -> Single<Element> {
        Single<Element>.create { [weak object] observer -> Disposable in
            guard let object else {
                observer(.error(ToolKitError.nullReference(A.self)))
                return Disposables.create()
            }
            return subscribe(object, observer)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func recordErrors(on recorder: ErrorRecording?) -> Single<Element> {
        self.do(onError: { error in
            recorder?.error(error)
        })
    }

    public func recordErrors(on recorder: ErrorRecording?, enabled: Bool) -> Single<Element> {
        guard enabled else { return self }
        return recordErrors(on: recorder)
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func catchError<A: AnyObject>(weak object: A, _ selector: @escaping (A, Swift.Error) throws -> Single<Element>) -> Single<Element> {
        `catch` { [weak object] error -> Single<Element> in
            guard let object else {
                throw ToolKitError.nullReference(A.self)
            }
            return try selector(object, error)
        }
    }
}

// MARK: - Result<Element, Error> mapping

extension PrimitiveSequence where Trait == SingleTrait {

    /// Directly maps to `Result<Element, Error>` type.
    public func mapToResult() -> PrimitiveSequence<SingleTrait, Result<Element, Error>> {
        map { .success($0) }
            .catch { .just(.failure($0)) }
    }

    /// Map with success and failure mappers.
    /// This is useful in case we would like to have a custom error type.
    public func mapToResult<ResultElement, OutputError: Error>(
        successMap: @escaping (Element) -> ResultElement,
        errorMap: @escaping (Error) -> OutputError
    ) -> PrimitiveSequence<SingleTrait, Result<ResultElement, OutputError>> {
        map { .success(successMap($0)) }
            .catch { .just(.failure(errorMap($0))) }
    }

    /// Map with success mapper only.
    public func mapToResult<ResultElement>(
        successMap: @escaping (Element) -> ResultElement) -> PrimitiveSequence<SingleTrait, Result<ResultElement, Error>>
    {
        map { .success(successMap($0)) }
            .catch { .just(.failure($0)) }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {

    public func crashOnError(file: String = #file, line: UInt = #line, function: String = #function) -> Single<Element> {
        self.do(onError: { error in
            fatalError(String(describing: error))
        })
    }
}
