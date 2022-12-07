// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain
import Foundation

public struct PhoneVerificationRepository: PhoneVerificationRepositoryAPI {
    private let client: PhoneVerificationClientAPI

    public init(client: PhoneVerificationClientAPI) {
        self.client = client
    }

    public func startInstantLinkPossession(
        phoneNumber: String
    ) -> AnyPublisher<Void, NabuError> {
        client.startInstantLinkPossession(phoneNumber: phoneNumber)
    }

    public func fetchInstantLinkPossessionStatus()
    -> AnyPublisher<PhoneVerification, NabuError> {
        client
            .fetchInstantLinkPossessionStatus()
            .map { response in
                PhoneVerification(
                    status: response.status
                )
            }
            .eraseToAnyPublisher()
    }
}
