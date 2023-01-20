// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class HistoricalBalanceCellInteractor {

    // MARK: - Properties

    let sparklineInteractor: SparklineInteracting
    let priceInteractor: AssetPriceViewInteracting
    let balanceInteractor: AssetBalanceViewInteracting
    let historicalFiatPriceService: HistoricalFiatPriceServiceAPI
    let cryptoCurrency: CryptoCurrency
    let evmNetwork: EVMNetwork?

    // MARK: - Setup

    init(
        cryptoAsset: CryptoAsset,
        historicalFiatPriceService: HistoricalFiatPriceServiceAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.cryptoCurrency = cryptoAsset.asset
        self.historicalFiatPriceService = historicalFiatPriceService
        self.sparklineInteractor = SparklineInteractor(
            priceService: historicalFiatPriceService,
            cryptoCurrency: cryptoCurrency
        )
        self.priceInteractor = AssetPriceViewHistoricalInteractor(
            historicalPriceProvider: historicalFiatPriceService
        )
        self.balanceInteractor = AccountAssetBalanceViewInteractor(
            cryptoAsset: cryptoAsset,
            fiatCurrencyService: fiatCurrencyService
        )
        self.evmNetwork = enabledCurrenciesService.network(for: cryptoCurrency)
    }

    func refresh() {
        historicalFiatPriceService.fetchTriggerRelay.accept(.day(.oneHour))
        balanceInteractor.refresh()
    }
}
