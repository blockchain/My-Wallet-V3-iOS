// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol PrefillInfoServiceAPI {

    func getPrefillInfo(
        phone: String,
        dateOfBirth: Date
    ) async throws -> PrefillInfo
}
