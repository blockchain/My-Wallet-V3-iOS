// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import FeatureDashboardDomain
import MoneyKit
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

        let userId: String?
        let balanceType: BalanceType
        let currency: FiatCurrency
        let time: PriceTime

        var description: String {
            "\(userId ?? "anon")-\(balanceType.rawValue)-\(currency.code)-\(time.id)"
        }
    }

    @Dependency(\.app) var app

    private let cachedValue: ThisCachedValue
    private let service: AssetBalanceInfoServiceAPI

    init(service: AssetBalanceInfoServiceAPI) {
        self.service = service

        let cache = InDiskCache<Key, [AssetBalanceInfo]>(
            id: Self.inDiskCacheID,
            configuration: .on(
                blockchain.ux.transaction.event.did.finish,
                blockchain.session.event.did.sign.in,
                blockchain.ux.kyc.event.status.did.change,
                blockchain.ux.home.event.did.pull.to.refresh
            ),
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
        app.publisher(for: blockchain.user.id, as: String.self)
            .map(\.value)
            .flatMap { [cachedValue] userId -> StreamOf<[AssetBalanceInfo], Never> in
                cachedValue.stream(key: Key(
                    userId: userId,
                    balanceType: .custodial,
                    currency: fiatCurrency,
                    time: time
                ), skipStale: false)
            }
            .eraseToAnyPublisher()
    }

    func fiat(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        app.publisher(for: blockchain.user.id, as: String.self)
            .map(\.value)
            .flatMap { [cachedValue] userId -> StreamOf<[AssetBalanceInfo], Never> in
                cachedValue.stream(key: Key(
                    userId: userId,
                    balanceType: .fiat,
                    currency: fiatCurrency,
                    time: time
                ), skipStale: false)
            }
            .eraseToAnyPublisher()
    }

    func cryptoNonCustodial(fiatCurrency: FiatCurrency, time: PriceTime) -> StreamOf<[AssetBalanceInfo], Never> {
        app.publisher(for: blockchain.user.id, as: String.self)
            .map(\.value)
            .flatMap { [cachedValue] userId -> StreamOf<[AssetBalanceInfo], Never> in
                cachedValue.stream(key: Key(
                    userId: userId,
                    balanceType: .nonCustodial,
                    currency: fiatCurrency,
                    time: time
                ), skipStale: false)
            }
            .eraseToAnyPublisher()
    }
}
