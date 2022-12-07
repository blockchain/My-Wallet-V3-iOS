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
        phoneNumber: String
    ) async throws -> Void? {
        try await repository
            .startInstantLinkPossession(
                phoneNumber: phoneNumber
            )
            .await()
    }

    public func fetchInstantLinkPossessionStatus() async throws -> PhoneVerification {
        try await repository
            .fetchInstantLinkPossessionStatus()
            .await()
    }
}
