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

final class AssetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI {

    private typealias ThisCachedValue = CachedValueNew<Key, [AssetBalanceInfo], Never>
    private static let inDiskCacheID = "AssetBalanceInfoRepository"

    enum Key: String, CustomStringConvertible {
        case custodial
        case nonCustodial
        case fiat

        var description: String { rawValue }
    }

    private let cachedValue: ThisCachedValue
    private let service: AssetBalanceInfoServiceAPI

    init(service: AssetBalanceInfoServiceAPI) {
        self.service = service

        let cache = InDiskCache<Key, [AssetBalanceInfo]>(
            id: Self.inDiskCacheID,
            configuration: .onUserStateChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        self.cachedValue = ThisCachedValue(
            cache: cache,
            fetch: { [service] key in
                switch key {
                case .custodial:
                    return service.getCustodialCryptoAssetsInfo()
                case .nonCustodial:
                    return service.getNonCustodialCryptoAssetsInfo()
                case .fiat:
                    return service.getFiatAssetsInfo()
                }
            }
        )
    }

    func cryptoCustodial() -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key.custodial)
    }

    func fiat() -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key.fiat)
    }

    func cryptoNonCustodial() -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key.nonCustodial)
    }
}
