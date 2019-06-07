//
//  ObservableTypeExtensions.swift
//  PlatformKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    public func flatMap<A: AnyObject, R>(weak object: A, selector: @escaping (A, Self.E) throws -> Observable<R>) -> Observable<R> {
        return flatMap { [weak object] (value) -> Observable<R> in
            guard let object = object else {
                return Observable.error(PlatformKitError.nullReference(A.self))
            }
            return try selector(object, value)
        }
    }

    public func flatMapLatest<A: AnyObject, R>(weak object: A, selector: @escaping (A, Self.E) throws -> Observable<R>) -> Observable<R> {
        return flatMapLatest { [weak object] (value) -> Observable<R> in
            guard let object = object else {
                return Observable.error(PlatformKitError.nullReference(A.self))
            }
            return try selector(object, value)
        }
    }
}
