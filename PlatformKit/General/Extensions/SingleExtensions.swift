//
//  SingleExtensions.swift
//  PlatformKit
//
//  Created by Jack on 25/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

extension ObservableType where E: OptionalType {
    func onNil(error: Error) -> Observable<E.Wrapped> {
        return flatMap { element -> Observable<E.Wrapped> in
            guard let value = element.value else {
                return Observable<E.Wrapped>.error(error)
            }
            return Observable<E.Wrapped>.just(value)
        }
    }
}

public extension Single where E: OptionalType {
    public func onNil(error: Error) -> Single<E.Wrapped> {
        // TODO: figure out how to implement this the right way
        return asObservable().onNil(error: error).asSingle()
    }
}

extension Single {
    public static func from<T, U: Error>(block: @escaping (@escaping (NewResult<T, U>) -> Void) -> Void) -> Single<T> {
        return Single.create(subscribe: { observer -> Disposable in
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
    public func flatMap<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, ElementType) throws -> Single<R>) -> Single<R> {
        return asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asSingle()
    }
}

extension PrimitiveSequence where TraitType == SingleTrait {
    public func flatMapCompletable<A: AnyObject>(weak object: A, _ selector: @escaping (A, ElementType) throws -> Completable)
        -> Completable {
        return asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asCompletable()
    }
}
