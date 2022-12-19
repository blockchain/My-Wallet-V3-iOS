// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

// @paulo @audrea: Remove cache from this layer, stop using Coincore.
public final class CustodialAssetsRepository: CustodialAssetsRepositoryAPI {
    private struct Key: Hashable {}

    public var assetsInfo: AnyPublisher<[AssetBalanceInfo], Error> {
        cachedValue.get(key: Key())
    }

    private let cache: AnyCache<Key, [AssetBalanceInfo]> = InMemoryCache(
        configuration: .onLoginLogout(),
        refreshControl: PeriodicCacheRefreshControl(refreshInterval: 320)
    )
    .eraseToAnyCache()

    private lazy var cachedValue: CachedValueNew<
        Key,
        [AssetBalanceInfo],
        Error
    > = CachedValueNew(
        cache: cache,
        fetch: { _ -> AnyPublisher<[AssetBalanceInfo], Error> in
            self.getAllCryptoAssetsInfoPublisher()
                .eraseError()
        }
    )

    private let coincore: CoincoreAPI
    private let app: AppProtocol
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI

    public init(
        coincore: CoincoreAPI,
        app: AppProtocol,
        fiatCurrencyService: FiatCurrencySettingsServiceAPI,
        priceService: PriceServiceAPI
    ) {
        self.coincore = coincore
        self.app = app
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
    }

    private func getAllCustodialCryptoAssetsInfo() async -> [AssetBalanceInfo] {
        let assets = coincore.cryptoAssets
        var assetsInfo: [AssetBalanceInfo] = []
        for asset in assets {
            async let accountGroup = try? await asset.accountGroup(filter: AppMode.trading.filter).await()
            async let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await()
            let balance = try? await accountGroup?.balance.await()
            let currencyType = balance?.currencyType

            if let accountGroup = await accountGroup,
               let fiatCurrency = await fiatCurrency,
               let balance,
               let currencyType,
               let cryptoCurrency = currencyType.cryptoCurrency
            {

                async let fiatBalance = try? await accountGroup.balancePair(fiatCurrency: fiatCurrency).await()
                async let prices = try? await priceService.priceSeries(
                    of: cryptoCurrency,
                    in: fiatCurrency,
                    within: .day()
                )
                .await()

                assetsInfo.append(await AssetBalanceInfo(
                    cryptoBalance: balance,
                    fiatBalance: fiatBalance,
                    currency: currencyType,
                    delta: prices?.deltaPercentage.roundTo(places: 2)
                ))
            }
        }
        return assetsInfo
    }

    private func getAllCryptoAssetsInfoPublisher() -> AnyPublisher<[AssetBalanceInfo], Never> {
        Deferred { [self] in
            Future { promise in
                Task {
                    do {
                        promise(.success(await self.getAllCustodialCryptoAssetsInfo()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
