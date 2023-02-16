// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol PrefillInfoRepositoryAPI {

    func getPrefillInfo(
        phone: String,
        dateOfBirth: Date
    ) -> AnyPublisher<PrefillInfo, NabuError>
}
