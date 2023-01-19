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
        phone: String
    ) -> AnyPublisher<StartPhoneVerification, NabuError> {
        client
            .startInstantLinkPossession(phone: phone)
            .map { response in
                StartPhoneVerification(
                    resendWaitTime: response.resendWaitTime
                )
            }
            .eraseToAnyPublisher()
    }

    public func fetchInstantLinkPossessionStatus()
    -> AnyPublisher<PhoneVerification, NabuError> {
        client
            .fetchInstantLinkPossessionStatus()
            .map { response in
                PhoneVerification(
                    isVerified: response.isVerified,
                    phone: response.phone
                )
            }
            .eraseToAnyPublisher()
    }
}
