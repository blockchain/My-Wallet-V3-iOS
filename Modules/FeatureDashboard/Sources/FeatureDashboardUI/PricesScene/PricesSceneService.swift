// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import MoneyKit
import PlatformKit
import SwiftExtensions

public protocol PricesSceneServiceAPI {
    func pricesRowData(appMode: AppMode) -> AnyPublisher<[PricesRowData], Error>
}

final class PricesSceneService: PricesSceneServiceAPI {

    private let app: AppProtocol
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let marketCapService: MarketCapServiceAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let watchlistRepository: PricesWatchlistRepositoryAPI

    init(
        app: AppProtocol,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        marketCapService: MarketCapServiceAPI,
        priceService: PriceServiceAPI,
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI,
        watchlistRepository: PricesWatchlistRepositoryAPI
    ) {
        self.app = app
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.marketCapService = marketCapService
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.watchlistRepository = watchlistRepository
    }

    func pricesRowData(appMode: AppMode) -> AnyPublisher<[PricesRowData], Error> {
        cryptoCurrencies(appMode: appMode).eraseError()
            .combineLatest(
                pricesNowOneDay,
                watchList.eraseError()
            )
            .map { entries, prices, watchlist in
                entries.map { entry -> PricesRowData in
                    let now = prices.0[entry.currency.code]
                    let oneDay = prices.1[entry.currency.code]
                    return PricesRowData(
                        currency: entry.currency,
                        delta: changePercentage(now: now, then: oneDay),
                        isFavorite: watchlist.contains(entry.currency.code),
                        isTradable: entry.isTradable,
                        price: now?.moneyValue
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    private var watchList: AnyPublisher<Set<String>, Never> {
        watchlistRepository
            .watchlist()
            .get()
            .replaceNil(with: [])
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private var pricesNowOneDay: AnyPublisher<([String: PriceQuoteAtTime], [String: PriceQuoteAtTime]), Error> {
        fiatCurrencyService.displayCurrencyPublisher
            .flatMap { [priceService] displayCurrency in
                let now = priceService
                    .prices(in: displayCurrency, at: .now)
                    .map { dictionary -> [String: PriceQuoteAtTime] in
                        dictionary.reduce(into: [String: PriceQuoteAtTime]()) { result, this in
                            if let key = this.key.components(separatedBy: "-").first {
                                result[key] = this.value
                            }
                        }
                    }
                    .eraseError()
                let oneDay = priceService
                    .prices(in: displayCurrency, at: .oneDay)
                    .map { dictionary -> [String: PriceQuoteAtTime] in
                        dictionary.reduce(into: [String: PriceQuoteAtTime]()) { result, this in
                            if let key = this.key.components(separatedBy: "-").first {
                                result[key] = this.value
                            }
                        }
                    }
                    .replaceError(with: [:])
                    .eraseError()
                return now.zip(oneDay)
            }
            .eraseToAnyPublisher()
    }

    private func cryptoCurrencies(appMode: AppMode) -> AnyPublisher<[CryptoCurrencyEntry], Never> {
        // tradingCurrencies for sorting only, never fails
        let tradingCurrencies: AnyPublisher<[CryptoCurrency], Never> = supportedPairsInteractorService
            .fetchSupportedTradingCryptoCurrencies()
            .replaceError(with: [])
            .eraseToAnyPublisher()
        // marketCap for sorting only, never fails
        let marketCap: AnyPublisher<[String: Double], Never> = marketCapService.marketCaps()
            .replaceError(with: [:])
            .eraseToAnyPublisher()

        return tradingCurrencies
            .combineLatest(
                marketCap
            )
            .map { [enabledCurrenciesService] tradingCurrencies, marketCaps -> [CryptoCurrencyEntry] in
                filterAndSortCryptoCurrencies(
                    enabledCurrenciesService.allEnabledCryptoCurrencies,
                    appMode: appMode,
                    marketCaps: marketCaps,
                    tradingCurrencies: tradingCurrencies
                )
            }
            .eraseToAnyPublisher()
    }
}

private struct CryptoCurrencyEntry: Equatable {
    let currency: CryptoCurrency
    let isTradable: Bool
}

private func filterAndSortCryptoCurrencies(
    _ cryptoCurrencies: [CryptoCurrency],
    appMode: AppMode,
    marketCaps: [String: Double],
    tradingCurrencies: [CryptoCurrency]
) -> [CryptoCurrencyEntry] {
    let tradingCurrenciesMap: [CryptoCurrency: Bool] = tradingCurrencies
        .reduce(into: [CryptoCurrency: Bool]()) { partialResult, this in
            partialResult[this] = true
        }
    let data: [(currency: CryptoCurrency, marketCap: Double, isTradable: Bool)] = cryptoCurrencies
        .map { currency in
            (currency, marketCaps[currency.code] ?? 0, tradingCurrenciesMap[currency] ?? false)
        }
    return data
        .sorted { $0.currency.name < $1.currency.name }
        .sorted { $0.marketCap > $1.marketCap }
        .map { CryptoCurrencyEntry(currency: $0.currency, isTradable: $0.isTradable) }
        .sorted(like: tradingCurrencies, my: \.currency)
}

private func changePercentage(now: PriceQuoteAtTime?, then: PriceQuoteAtTime?) -> Decimal? {
    guard let now, let then else {
        return nil
    }
    guard let priceChange = try? now.moneyValue - then.moneyValue else {
        return nil
    }
    // Zero or negative values shouldn't be possible.
    guard now.moneyValue.isPositive, then.moneyValue.isPositive else {
        return nil
    }
    guard let changePercentage = try? priceChange.percentage(in: then.moneyValue) else {
        return nil
    }
    return changePercentage
}
