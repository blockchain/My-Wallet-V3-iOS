// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension SharedSequenceConvertibleType where Self.SharingStrategy == RxCocoa.SignalSharingStrategy {

    public func emit<A: AnyObject>(
        weak object: A,
        onNext: @escaping (A, Element) -> Void
    ) -> Disposable {
        emit(
            onNext: { [weak object] element in
                guard let object else { return }
                onNext(object, element)
            }
        )
    }

    public func emit<A: AnyObject>(
        weak object: A,
        onNext: @escaping ((A) -> Void)
    ) -> Disposable {
        emit(
            onNext: { [weak object] _ in
                guard let object else { return }
                onNext(object)
            }
        )
    }
}
