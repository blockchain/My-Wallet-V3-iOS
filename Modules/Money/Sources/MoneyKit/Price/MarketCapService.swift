// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol MarketCapServiceAPI {

    /// Gets the market cap of the given base `Currency` in the user's trading currency.
    ///
    /// - Returns: A publisher that emits a `[String: Double]` on success, or a `PriceServiceError` on failure.
    func marketCaps() -> AnyPublisher<[String: Double], MarketCapServiceError>
}

/// A market cap service error.
public enum MarketCapServiceError: Error {

    /// The requested price is missing,
    case missingMarketCap

    /// A network error ocurred.
    case networkError(NetworkError)
}

final class MarketCapService: MarketCapServiceAPI {

    // MARK: - Private Properties

    private let priceRepository: PriceRepositoryAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Init

    init(
        priceRepository: PriceRepositoryAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.priceRepository = priceRepository
        self.fiatCurrencyService = fiatCurrencyService
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    // MARK: - MarketCapServiceAPI

    func marketCaps() -> AnyPublisher<[String: Double], MarketCapServiceError> {
        let priceRepository = priceRepository
        let enabledCurrenciesService = enabledCurrenciesService
        return fiatCurrencyService.tradingCurrencyPublisher
            .flatMap { tradingCurrency -> AnyPublisher<[String: PriceQuoteAtTime], NetworkError> in
                let currencies = enabledCurrenciesService
                    .allEnabledCurrencies
                    .filter { $0.code != tradingCurrency.code }
                return priceRepository.prices(of: currencies, in: tradingCurrency, at: .now)
            }
            .mapError(MarketCapServiceError.networkError)
            .map { prices in
                prices.reduce(into: [:]) { result, item in
                    var key = item.key
                    if let dashRange = key.range(of: "-") {
                        key.removeSubrange(dashRange.lowerBound..<key.endIndex)
                    }
                    result[key] = item.value.marketCap
                }
            }
            .eraseToAnyPublisher()
    }
}
