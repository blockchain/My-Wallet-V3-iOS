// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ConfirmInfoService: ConfirmInfoServiceAPI {
    private let repository: ConfirmInfoRepositoryAPI

    public init(repository: ConfirmInfoRepositoryAPI) {
        self.repository = repository
    }

    public func confirmInfo(
        confirmInfo: ConfirmInfo
    ) async throws -> ConfirmInfo {
        try await repository
            .confirmInfo(confirmInfo: confirmInfo)
            .await()
    }
}
