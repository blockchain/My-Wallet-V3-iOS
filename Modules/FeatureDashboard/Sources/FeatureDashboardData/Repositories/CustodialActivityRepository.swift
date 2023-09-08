// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import FeatureDashboardDomain
import ToolKit
import UnifiedActivityDomain

final class CustodialActivityRepository: CustodialActivityRepositoryAPI {

    private typealias ThisCachedValue = CachedValueNew<Key, [ActivityEntry], Never>

    enum Key: String, CustomStringConvertible {
        case custodial

        var description: String { rawValue }
    }

    private let cachedValue: ThisCachedValue
    private let service: CustodialActivityServiceAPI

    init(service: CustodialActivityServiceAPI) {
        self.service = service

        let cache = InMemoryCache<Key, [ActivityEntry]>(
            configuration: .onUserStateChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        )
        .eraseToAnyCache()

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
