// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain
import Foundation

public struct ConfirmInfoRepository: ConfirmInfoRepositoryAPI {
    private let client: ConfirmInfoClientAPI

    public init(client: ConfirmInfoClientAPI) {
        self.client = client
    }

    public func confirmInfo(
        confirmInfo: ConfirmInfo
    ) -> AnyPublisher<ConfirmInfo, NabuError> {
        client
            .confirmInfo(
                firstName: confirmInfo.firstName,
                lastName: confirmInfo.lastName,
                address: confirmInfo.address,
                dateOfBirth: confirmInfo.dateOfBirth,
                phone: confirmInfo.phone
            )
            .map { _ in
                confirmInfo
            }
            .eraseToAnyPublisher()
    }
}
