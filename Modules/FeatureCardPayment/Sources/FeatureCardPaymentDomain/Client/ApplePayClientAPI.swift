// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol ApplePayClientAPI: AnyObject {
    func applePayInfo(
        for currency: String
    ) -> AnyPublisher<ApplePayInfo, NabuNetworkError>
}

public protocol ApplePayEligibleServiceAPI: AnyObject {
    func isFrontendEnabled() -> AnyPublisher<Bool, Never>
}
