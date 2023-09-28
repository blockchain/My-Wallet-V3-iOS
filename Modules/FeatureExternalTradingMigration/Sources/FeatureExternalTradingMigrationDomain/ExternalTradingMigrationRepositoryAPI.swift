// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ExternalTradingMigrationRepositoryAPI {
    func fetchMigrationInfo() async throws -> ExternalTradingMigrationInfo
    func startMigration() async throws
}
