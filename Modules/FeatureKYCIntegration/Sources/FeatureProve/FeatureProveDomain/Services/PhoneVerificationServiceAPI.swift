// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Extensions
import Foundation

public protocol PhoneVerificationServiceAPI {

    func startInstantLinkPossession(
        phoneNumber: String
    ) async throws -> Void?

    func fetchInstantLinkPossessionStatus(
    ) async throws -> PhoneVerification
}
