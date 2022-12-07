// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol PhoneVerificationRepositoryAPI {

    func startInstantLinkPossession(
        phoneNumber: String
    ) -> AnyPublisher<Void, NabuError>

    func fetchInstantLinkPossessionStatus()
    -> AnyPublisher<PhoneVerification, NabuError>
}
