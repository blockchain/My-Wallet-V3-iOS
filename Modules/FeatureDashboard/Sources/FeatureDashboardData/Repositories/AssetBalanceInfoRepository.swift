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

    struct Key: Hashable, CustomStringConvertible {
        enum BalanceType: String {
            case custodial
            case nonCustodial
            case fiat
        }

        let balanceType: BalanceType
        let currency: FiatCurrency
        let time: PriceTime

        var description: String {
            "\(balanceType.rawValue)-\(currency.code)-\(time.id)"
        }
    }

    private let cachedValue: ThisCachedValue
    private let service: AssetBalanceInfoServiceAPI

    init(service: AssetBalanceInfoServiceAPI) {
        self.service = service

        let cache = InDiskCache<Key, [AssetBalanceInfo]>(
            id: Self.inDiskCacheID,
            configuration: .onUserStateChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60),
            enableAsyncWrites: true
        ).eraseToAnyCache()

        self.cachedValue = ThisCachedValue(
            cache: cache,
            fetch: { [service] key in
                switch key.balanceType {
                case .custodial:
                    return service.getCustodialCryptoAssetsInfo(
                        fiatCurrency: key.currency,
                        at: key.time
                    )
                case .nonCustodial:
                    return service.getNonCustodialCryptoAssetsInfo(
                        fiatCurrency: key.currency,
                        at: key.time
                    )
                case .fiat:
                    return service.getFiatAssetsInfo(
                        fiatCurrency: key.currency,
                        at: key.time
                    )
                }
            }
        )
    }

    func cryptoCustodial(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key(
            balanceType: .custodial,
            currency: fiatCurrency,
            time: time
        ), skipStale: false)
    }

    func fiat(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key(
            balanceType: .fiat,
            currency: fiatCurrency,
            time: time
        ), skipStale: false)
    }

    func cryptoNonCustodial(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key(
            balanceType: .nonCustodial,
            currency: fiatCurrency,
            time: time
        ), skipStale: false)
    }
}
