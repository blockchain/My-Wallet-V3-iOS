// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol PhoneVerificationClientAPI {

    func startInstantLinkPossession(
        phone: String
    ) -> AnyPublisher<StartPhoneVerificationResponse, NabuError>

    func fetchInstantLinkPossessionStatus()
    -> AnyPublisher<PhoneVerificationResponse, NabuError>
}
