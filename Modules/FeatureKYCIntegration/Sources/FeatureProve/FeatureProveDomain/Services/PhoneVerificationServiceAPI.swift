// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Extensions
import Foundation

public protocol PhoneVerificationServiceAPI {

    func startInstantLinkPossession(
        phone: String
    ) async throws -> StartPhoneVerification

    func fetchInstantLinkPossessionStatus(
    ) async throws -> PhoneVerification
}
