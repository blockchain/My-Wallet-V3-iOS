// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol PinInteracting: AnyObject {
    var hasLogoutAttempted: Bool { get set }

    func create(using payload: PinPayload) -> Completable
    func validate(using payload: PinPayload) -> Single<String>
    func password(from pinDecryptionKey: String) -> Single<String>
    func persist(pin: Pin)
}
