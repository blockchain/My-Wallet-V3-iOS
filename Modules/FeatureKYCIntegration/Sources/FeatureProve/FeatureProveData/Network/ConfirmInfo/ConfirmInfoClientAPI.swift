// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain
import Foundation

public protocol ConfirmInfoClientAPI {

    func confirmInfo(
        firstName: String,
        lastName: String,
        address: Address,
        dateOfBirth: Date,
        phone: String
    ) -> AnyPublisher<Void, NabuError>
}
