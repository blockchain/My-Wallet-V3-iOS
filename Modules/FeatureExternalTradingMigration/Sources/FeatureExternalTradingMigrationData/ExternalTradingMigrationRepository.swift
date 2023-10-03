// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import FeatureExternalTradingMigrationDomain
import Foundation
import NetworkKit
import ToolKit

public final class ExternalTradingMigrationRepository: ExternalTradingMigrationRepositoryAPI {
    private enum CacheKey: Hashable {
        case bakktMigrationInfo
    }

    private let cachedProducts: CachedValueNew<CacheKey, ExternalTradingMigrationInfo, NetworkError>
    private let client: ExternalTradingMigrationClientAPI

    public init(app: AppProtocol,
                client: ExternalTradingMigrationClientAPI) {
        self.client = client
        let cache: AnyCache<CacheKey, ExternalTradingMigrationInfo> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        self.cachedProducts = CachedValueNew(
            cache: cache,
            fetch: {_ in
                client
                    .fetchMigrationInfo()
                    .eraseToAnyPublisher()
            }
        )
    }

    public func fetchMigrationInfo() async throws -> ExternalTradingMigrationInfo {
        try await cachedProducts.get(key: CacheKey.bakktMigrationInfo).await()
    }

    public func startMigration() async throws {
        try await client.startMigration().await()
    }
}
