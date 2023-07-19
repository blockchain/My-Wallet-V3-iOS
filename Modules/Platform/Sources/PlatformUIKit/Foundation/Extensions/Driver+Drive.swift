// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension SharedSequenceConvertibleType where Self.SharingStrategy == RxCocoa.DriverSharingStrategy {
    public func drive<A: AnyObject>(
        weak object: A,
        onNext: ((A, Element) -> Void)? = nil
    ) -> Disposable {
        drive(
            onNext: { [weak object] element in
                guard let object else { return }
                onNext?(object, element)
            }
        )
    }
}
