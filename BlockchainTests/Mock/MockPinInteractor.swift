// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
@testable import FeaturePin

import Foundation
import PlatformKit
import RxSwift

class MockPinInteractor: PinInteracting {
    var hasLogoutAttempted = false
    let expectedPassword: String
    let expectedError: PinError?

    init(
        expectedError: PinError? = nil,
        expectedPassword: String = "expected password"
    ) {
        self.expectedError = expectedError
        self.expectedPassword = expectedPassword
    }

    func create(using payload: PinPayload) -> Completable {
        if let expectedError {
            return Completable.error(expectedError)
        }
        return Completable.empty()
    }

    func validate(using payload: PinPayload) -> Single<String> {
        if let expectedError {
            return Single.error(expectedError)
        }
        return Single.just(expectedPassword)
    }

    func persist(pin: Pin) {}

    func password(from pinDecryptionKey: String) -> Single<String> {
        .just(expectedPassword)
    }
}
