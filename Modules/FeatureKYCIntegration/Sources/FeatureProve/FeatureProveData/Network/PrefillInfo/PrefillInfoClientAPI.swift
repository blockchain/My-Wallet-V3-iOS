// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol PrefillInfoClientAPI {

    func getPrefillInfo(
        phone: String,
        dateOfBirth: Date
    ) -> AnyPublisher<PrefillInfoResponse, NabuError>
}
