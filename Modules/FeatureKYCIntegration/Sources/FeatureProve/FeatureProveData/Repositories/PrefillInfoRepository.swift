// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain
import Foundation

public struct PrefillInfoRepository: PrefillInfoRepositoryAPI {
    private let client: PrefillInfoClientAPI

    public init(client: PrefillInfoClientAPI) {
        self.client = client
    }

    public func getPrefillInfo(
        phone: String,
        dateOfBirth: Date
    ) -> AnyPublisher<PrefillInfo, NabuError> {
        client
            .getPrefillInfo(phone: phone, dateOfBirth: dateOfBirth)
            .map { response in
                PrefillInfo(
                    firstName: response.firstName,
                    lastName: response.lastName,
                    addresses: response.addresses,
                    dateOfBirth: response.dateOfBirth,
                    phone: response.phone
                )
            }
            .eraseToAnyPublisher()
    }
}
