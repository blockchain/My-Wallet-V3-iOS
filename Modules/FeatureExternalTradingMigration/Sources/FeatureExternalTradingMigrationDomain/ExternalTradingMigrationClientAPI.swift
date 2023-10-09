// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

public protocol ExternalTradingMigrationClientAPI {
    func fetchMigrationInfo() -> AnyPublisher<ExternalTradingMigrationInfo, NetworkError>
    func startMigration() -> AnyPublisher<Void, NabuNetworkError>
}
