// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PrefillInfoService: PrefillInfoServiceAPI {
    private let repository: PrefillInfoRepositoryAPI

    public init(repository: PrefillInfoRepositoryAPI) {
        self.repository = repository
    }

    public func getPrefillInfo(
        phone: String,
        dateOfBirth: Date
    ) async throws -> PrefillInfo {
        try await repository
            .getPrefillInfo(phone: phone, dateOfBirth: dateOfBirth)
            .await()
    }
}
