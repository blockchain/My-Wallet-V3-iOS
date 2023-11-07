// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
@testable import FeatureKYCUI
import PlatformKit
import RxSwift

class MockKYCVerifyPhoneNumberInteractor: KYCVerifyPhoneNumberInteractor {
    var shouldSucceed = true

    override func startVerification(number: String) -> Completable {
        if shouldSucceed {
            Completable.empty()
        } else {
            Completable.error(HTTPRequestServerError.badResponse)
        }
    }

    override func verifyNumber(with code: String) -> Completable {
        if shouldSucceed {
            Completable.empty()
        } else {
            Completable.error(HTTPRequestServerError.badResponse)
        }
    }
}
