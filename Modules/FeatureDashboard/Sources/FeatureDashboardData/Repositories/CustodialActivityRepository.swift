// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import ToolKit
import UnifiedActivityDomain

final class CustodialActivityRepository: CustodialActivityRepositoryAPI {

    private typealias ThisCachedValue = CachedValueNew<Key, [ActivityEntry], Never>
    private static let inDiskCacheID = "CustodialActivityRepository"

    enum Key: String, CustomStringConvertible {
        case custodial

        var description: String { rawValue }
    }

    private let cachedValue: ThisCachedValue
    private let service: CustodialActivityServiceAPI

    init(service: CustodialActivityServiceAPI) {
        self.service = service

        let cache = InDiskCache<Key, [ActivityEntry]>(
            id: Self.inDiskCacheID,
            configuration: .onUserStateChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        self.cachedValue = ThisCachedValue(
            cache: cache,
            fetch: { [service] _ in
                service.activity()
            }
        )
    }

    func activity() -> StreamOf<[ActivityEntry], Never> {
        cachedValue.stream(key: Key.custodial)
    }
}
