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

    enum Key: Hashable, CustomStringConvertible {
        case custodial(currency: FiatCurrency, time: PriceTime)
        case nonCustodial(currency: FiatCurrency, time: PriceTime)
        case fiat(currency: FiatCurrency, time: PriceTime)

        var description: String {
            switch self {
            case .custodial(let currency, _):
                return "custodial-\(currency.rawValue)-\(timeNameForDB ?? "")"
            case .nonCustodial(let currency, _):
                return "nonCustodial-\(currency.rawValue)-\(timeNameForDB ?? "")"
            case .fiat(let currency, _):
                return "fiat-\(currency.rawValue)-\(timeNameForDB ?? "")"
            }
        }

        var currency: FiatCurrency {
            switch self {
            case .custodial(let currency, _):
                return currency
            case .nonCustodial(let currency, _):
                return currency
            case .fiat(let currency, _):
                return currency
            }
        }

        var time: PriceTime {
            switch self {
            case .custodial(_, let time):
                return time
            case .nonCustodial(_, let time):
                return time
            case .fiat(_, let time):
                return time
            }
        }

        private var timeNameForDB: String? {
            switch self {
            case .custodial(_, let time) where time == .now:
                return "now"
            case .custodial(_, let time) where time == .oneDay:
                return "oneDay"
            case .custodial:
                return nil
            case .nonCustodial(_, let time) where time == .now:
                return "now"
            case .nonCustodial(_, let time) where time == .oneDay:
                return "oneDay"
            case .nonCustodial:
                return nil
            case .fiat(_, let time) where time == .now:
                return "now"
            case .fiat(_, let time) where time == .oneDay:
                return "oneDay"
            case .fiat:
                return nil
            }
        }
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
                    return service.getCustodialCryptoAssetsInfo(fiatCurrency: key.currency, at: key.time)
                case .nonCustodial:
                    return service.getNonCustodialCryptoAssetsInfo(fiatCurrency: key.currency, at: key.time)
                case .fiat:
                    return service.getFiatAssetsInfo(fiatCurrency: key.currency, at: key.time)
                }
            }
        )
    }

    func cryptoCustodial(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key.custodial(currency: fiatCurrency, time: time))
    }

    func fiat(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key.fiat(currency: fiatCurrency, time: time))
    }

    func cryptoNonCustodial(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        cachedValue.stream(key: Key.nonCustodial(currency: fiatCurrency, time: time))
    }
}
