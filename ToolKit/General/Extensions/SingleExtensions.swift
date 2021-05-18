//
//  SingleExtensions.swift
//  PlatformKit
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public extension Single where Element: OptionalType {
    func onNil(error: Error) -> Single<Element.Wrapped> {
        // TODO: figure out how to implement this the right way
        return asObservable().onNil(error: error).asSingle()
    }
}

extension Single {
    public static func from<T, U: Error>(block: @escaping (@escaping (Swift.Result<T, U>) -> Void) -> Void) -> Single<T> {
        Single.create(subscribe: { observer -> Disposable in
            block { result in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create()
        })
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

extension PrimitiveSequence where Trait == SingleTrait, Element == Array<Single<Bool>> {
    /// Flat maps the array element of this stream, concatenating its elements into a `Single<Bool>` that returns `true` at first chance.
    public func flatMapConcatFirst() -> Single<Bool> {
        flatMap { array -> Single<Bool> in
            // Reduce the `Array<Single<Bool>>`
            array.reduce(Single.just(false)) { (stream, thisSingle) -> Single<Bool> in
                // Flat map the previously reduced value.
                stream
                    .flatMap { streamResult -> Single<Bool> in
                        switch streamResult {
                        case true:
                            // If the stream result was true, return.
                            return .just(true)
                        case false:
                            // Else, concatenate stream on the array.
                            return thisSingle
                        }
                    }
            }
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func map<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> R) -> PrimitiveSequence<SingleTrait, R> {
        map { [weak object] element -> R in
            guard let object = object else { throw ToolKitError.nullReference(A.self) }
            return try selector(object, element)
        }
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    public func flatMap<A: AnyObject>(weak object: A, _ selector: @escaping (A) throws -> Completable) -> Completable {
        do {
            return asObservable().ignoreElements().andThen(try selector(object))
        } catch {
            return .error(error)
        }
    }
    
    /// Convert from `Completable` into `Single`
    public func flatMapSingle<A: AnyObject, R>(weak object: A, _ selector: @escaping (A) throws -> Single<R>) -> Single<R> {
        do {
            return asObservable().ignoreElements().andThen(try selector(object))
        } catch {
            return .error(error)
        }
    }
    
    /// Convert from `Completable` into `Single`
    public func flatMapSingle<R>(_ selector: @escaping () throws -> Single<R>) -> Single<R> {
        do {
            return asObservable().ignoreElements().andThen(try selector())
        } catch {
            return .error(error)
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    public func flatMapCompletable<A: AnyObject>(weak object: A, _ selector: @escaping (A, Element) throws -> Completable)
        -> Completable {
        asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asCompletable()
    }
    
    public static func create<A: AnyObject>(weak object: A, subscribe: @escaping (A, @escaping SingleObserver) -> Disposable) -> Single<Element> {
        Single<Element>.create { [weak object] observer -> Disposable in
            guard let object = object else {
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
        catchError { [weak object] error -> Single<Element> in
            guard let object = object else { throw ToolKitError.nullReference(A.self) }
            return try selector(object, error)
        }
    }
}

// MARK: - Result<Element, Error> mapping

extension PrimitiveSequence where Trait == SingleTrait {
    
    /// Directly maps to `Result<Element, Error>` type.
    public func mapToResult() -> PrimitiveSequence<SingleTrait, Result<Element, Error>> {
        self.map { .success($0) }
            .catchError { .just(.failure($0)) }
    }
    
    /// Map with success and failure mappers.
    /// This is useful in case we would like to have a custom error type.
    public func mapToResult<ResultElement, OutputError: Error>(
        successMap: @escaping (Element) -> ResultElement,
        errorMap: @escaping (Error) -> OutputError) -> PrimitiveSequence<SingleTrait, Result<ResultElement, OutputError>> {
        self.map { .success(successMap($0)) }
            .catchError { .just(.failure(errorMap($0))) }
    }

    /// Map with success mapper only.
    public func mapToResult<ResultElement>(
        successMap: @escaping (Element) -> ResultElement) -> PrimitiveSequence<SingleTrait, Result<ResultElement, Error>> {
        self.map { .success(successMap($0)) }
            .catchError { .just(.failure($0)) }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    
    public func crashOnError(file: String = #file, line: UInt = #line, function: String = #function) -> Single<Element> {
        self.do(onError: { error in
            fatalError(error.localizedDescription)
        })
    }
}
