// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PricesScreenInteractor {

    // MARK: - Properties

    var cryptoCurrencies: AnyPublisher<[CryptoCurrency], Error> {
        guard !showSupportedPairsOnly else {
            return supportedPairsInteractorService
                .fetchSupportedTradingCryptoCurrencies()
                .eraseError()
                .eraseToAnyPublisher()
        }

        // tradingCurrencies for sorting only, never fails
        let tradingCurrencies: AnyPublisher<[CryptoCurrency], Never> = supportedPairsInteractorService
            .fetchSupportedTradingCryptoCurrencies()
            .replaceError(with: [])
            .eraseToAnyPublisher()
        // marketCap for sorting only, never fails
        let marketCap: AnyPublisher<[String: Double], Never> = marketCapService.marketCaps()
            .replaceError(with: [:])
            .eraseToAnyPublisher()

       return app.modePublisher()
            .combineLatest(
                tradingCurrencies,
                marketCap
            )
            .map { [enabledCurrenciesService] appMode, tradingCurrencies, marketCaps -> [CryptoCurrency] in
                filterAndSortCryptoCurrencies(
                    enabledCurrenciesService.allEnabledCryptoCurrencies,
                    appMode: appMode,
                    marketCaps: marketCaps,
                    tradingCurrencies: tradingCurrencies
                )
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let marketCapService: MarketCapServiceAPI
    private let showSupportedPairsOnly: Bool
    private let app: AppProtocol

    // MARK: - Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        marketCapService: MarketCapServiceAPI = resolve(),
        app: AppProtocol = resolve(),
        showSupportedPairsOnly: Bool
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.marketCapService = marketCapService
        self.app = app
        self.showSupportedPairsOnly = showSupportedPairsOnly
    }

    // MARK: - Methods

    func assetPriceViewInteractor(
        for currency: CryptoCurrency
    ) -> AssetPriceViewInteracting {
        AssetPriceViewDailyInteractor(
            cryptoCurrency: currency,
            priceService: priceService,
            fiatCurrencyService: fiatCurrencyService
        )
    }

    func refresh() {}
}

private func filterAndSortCryptoCurrencies(
    _ cryptoCurrencies: [CryptoCurrency],
    appMode: AppMode,
    marketCaps: [String: Double],
    tradingCurrencies: [CryptoCurrency]
) -> [CryptoCurrency] {
    cryptoCurrencies
        .filter(appMode: appMode)
        .map { currency in
            (currency: currency, marketCap: marketCaps[currency.code] ?? 0)
        }
        .sorted { $0.currency.name < $1.currency.name }
        .sorted { $0.marketCap > $1.marketCap }
        .map(\.currency)
        .sorted(like: tradingCurrencies)
}

extension [CryptoCurrency] {
    fileprivate func filter(appMode: AppMode) -> [CryptoCurrency] {
        filter { currency in
            switch appMode {
            case .pkw:
                return currency.supports(product: .privateKey)
            case .trading:
                return currency.supports(product: .custodialWalletBalance) || currency.supports(product: .interestBalance)
            case .universal:
                return true
            }
        }
    }
}
