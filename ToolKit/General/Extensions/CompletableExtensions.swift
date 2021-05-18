//
//  CompletableExtensions.swift
//  ToolKit
//
//  Created by Alex McGregor on 10/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {
    
    public func onErrorComplete() -> Completable {
        catchError { _ in
            .empty()
        }
    }
    
    public static func fromCallable(_ callable: @escaping () throws -> Void) -> Completable {
        Completable.create { observer in
            do {
                try callable()
                observer(CompletableEvent.completed)
            } catch {
                observer(CompletableEvent.error(error))
            }

            return Disposables.create()
        }
    }

    public static func fromCallable<A: AnyObject>(weak object: A, _ callable: @escaping (A) throws -> Void) -> Completable {
        Completable.create(weak: object) { (object, observer) -> Disposable in
            do {
                try callable(object)
                observer(CompletableEvent.completed)
            } catch {
                observer(CompletableEvent.error(error))
            }

            return Disposables.create()
        }
    }

    public static func just(event: CompletableEvent) -> Completable {
        Completable.create { completable -> Disposable in
            completable(event)
            return Disposables.create()
        }
    }

    public static func create<A: AnyObject>(
        weak object: A,
        subscribe: @escaping (A, @escaping Self.CompletableObserver) -> Disposable
    ) -> RxSwift.PrimitiveSequence<Self.Trait, Self.Element> {
        Completable.create { [weak object] observer -> Disposable in
            guard let object = object else {
                observer(.error(ToolKitError.nullReference(A.self)))
                return Disposables.create()
            }
            return subscribe(object, observer)
        }
    }
}
