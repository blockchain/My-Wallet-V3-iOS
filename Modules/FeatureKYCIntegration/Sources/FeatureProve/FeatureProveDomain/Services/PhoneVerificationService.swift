// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public class PhoneVerificationService: PhoneVerificationServiceAPI {

    private let repository: PhoneVerificationRepositoryAPI

    public init(repository: PhoneVerificationRepositoryAPI) {
        self.repository = repository
    }

    public func startInstantLinkPossession(
        phone: String
    ) async throws -> StartPhoneVerification {
        try await repository
            .startInstantLinkPossession(phone: phone)
            .await()
    }

    public func fetchInstantLinkPossessionStatus() async throws -> PhoneVerification {
        try await repository
            .fetchInstantLinkPossessionStatus()
            .await()
    }
}
