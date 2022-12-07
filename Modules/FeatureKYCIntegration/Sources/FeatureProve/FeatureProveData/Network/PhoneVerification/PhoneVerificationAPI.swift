// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol PhoneVerificationClientAPI {

    func startInstantLinkPossession(
        phoneNumber: String
    ) -> AnyPublisher<Void, NabuError>

    func fetchInstantLinkPossessionStatus()
    -> AnyPublisher<PhoneVerificationResponse, NabuError>
}
