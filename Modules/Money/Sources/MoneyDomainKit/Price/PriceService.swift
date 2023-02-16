// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import ToolKit

/// A price service error.
public enum PriceServiceError: Error {

    /// The requested price is missing,
    case missingPrice(String)

    /// A network error ocurred.
    case networkError(NetworkError)
}

/// Used to convert fiat <-> crypto
public protocol PriceServiceAPI {

    /// Gets the money value pair of the given fiat value and crypto currency.
    ///
    /// - Parameters:
    ///  - fiatValue:      The fiat value to use in the pair.
    ///  - cryptoCurrency: The crypto currency to use in the pair.
    ///  - usesFiatAsBase: Whether the base of the pair will be the fiat value or the crypto value.
    ///
    /// - Returns: A publisher that emits a `MoneyValuePair` on success, or a `PriceServiceError` on failure.
    func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, PriceServiceError>

    /// Gets the quoted price of the given base `Currency` in the given quote `Currency`, at the current time.
    ///
    /// - Parameters:
    ///  - base:  The currency to get the price of.
    ///  - quote: The currency to get the price in.
    ///
    /// - Returns: A publisher that emits a `PriceQuoteAtTime` on success, or a `PriceServiceError` on failure.
    func price(
        of base: Currency,
        in quote: Currency
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError>

    /// Gets the quoted price of the given base `Currency` in the given quote `Currency`, at the given time.
    ///
    /// - Parameters:
    ///  - base:  The currency to get the price of.
    ///  - quote: The currency to get the price in.
    ///  - time:  The time to get the price at.
    ///
    /// - Returns: A publisher that emits a `PriceQuoteAtTime` on success, or a `PriceServiceError` on failure.
    func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError>

    /// Gets the quoted price of all known `Currency` in the given quote `Currency`, at the given time.
    ///
    /// - Parameters:
    ///  - quote: The currency to get the price in.
    ///  - time:  The time to get the price at. A value of `nil` will default to the current time.
    ///
    /// - Returns: A publisher that emits a hashmap of `Currency.code`: `PriceQuoteAtTime` on success, or a `PriceServiceError` on failure.
    func prices(
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<[String: PriceQuoteAtTime], PriceServiceError>

    /// Gets the historical price series of the given `CryptoCurrency`-`FiatCurrency` pair, within the given price window.
    /// - Parameters:
    ///  - base:   The crypto currency to get the price series of.
    ///  - quote:  The fiat currency to get the price in.
    ///  - window: The price window to get the price in.
    ///
    /// - Returns: A publisher that emits a `HistoricalPriceSeries` on success, or a `PriceServiceError` on failure.
    func priceSeries(
        of base: CryptoCurrency,
        in quote: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, PriceServiceError>

    /// Streams the quoted price of the given base `Currency` in the given quote `Currency` for now.
    ///
    /// - Parameters:
    ///  - quote: The currency to get the price in.
    ///  - time:  The time to get the price at.
    ///
    /// - Returns: A publisher that emits a `[String: PriceQuoteAtTime]` on success, or a `PriceServiceError` on failure.
    func stream(
        quote: Currency,
        at time: PriceTime,
        skipStale: Bool
    ) -> AnyPublisher<Result<[String: PriceQuoteAtTime], NetworkError>, Never>
}

final class PriceService: PriceServiceAPI {

    // MARK: - Private Properties

    private let repository: PriceRepositoryAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    // MARK: - Setup

    /// Creates a price service.
    ///
    /// - Parameters:
    ///   - repository:               A price repository.
    ///   - enabledCurrenciesService: An enabled currencies service.
    init(
        repository: PriceRepositoryAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.repository = repository
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, PriceServiceError> {
        price(of: cryptoCurrency, in: fiatValue.currency)
            .map(\.moneyValue.fiatValue)
            .replaceNil(with: .zero(currency: fiatValue.currency))
            .map { price in
                MoneyValuePair(
                    fiatValue: fiatValue,
                    exchangeRate: price,
                    cryptoCurrency: cryptoCurrency,
                    usesFiatAsBase: usesFiatAsBase
                )
            }
            .eraseToAnyPublisher()
    }

    func price(
        of base: Currency,
        in quote: Currency
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        price(of: base, in: quote, at: .now)
    }

    func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        let baseCode = base.code
        let quoteCode = quote.code

        guard baseCode != quoteCode else {
            // Base and Quote currencies are the same.
            return .just(
                PriceQuoteAtTime(
                    timestamp: time.date,
                    moneyValue: .one(currency: quote.currencyType),
                    marketCap: nil
                )
            )
        }
        return Deferred { [enabledCurrenciesService] in
            Future<[Currency], Never> { promise in
                if time.isSpecificDate {
                    promise(.success([base]))
                } else {
                    let currencies = enabledCurrenciesService
                        .allEnabledCurrencies
                        .filter { $0.code != quote.code }
                    promise(.success(currencies))
                }
            }
        }
        .flatMap { [repository] bases in
            repository.prices(of: bases, in: quote, at: time)
        }
        .mapError(PriceServiceError.networkError)
        .map { prices in
            // Get price of pair.
            prices["\(baseCode)-\(quoteCode)"]
        }
        .onNil(PriceServiceError.missingPrice("\(baseCode)-\(quoteCode)"))
        .eraseToAnyPublisher()
    }

    func prices(
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<[String: PriceQuoteAtTime], PriceServiceError> {
        Deferred { [enabledCurrenciesService] in
            Future<[Currency], Never> { promise in
                let currencies = enabledCurrenciesService
                    .allEnabledCurrencies
                    .filter { $0.code != quote.code }
                promise(.success(currencies))
            }
        }
        .flatMap { [repository] bases in
            repository.prices(of: bases, in: quote, at: time)
        }
        .mapError(PriceServiceError.networkError)
        .eraseToAnyPublisher()
    }

    func priceSeries(
        of base: CryptoCurrency,
        in quote: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, PriceServiceError> {
        repository
            .priceSeries(of: base, in: quote, within: window)
            .mapError(PriceServiceError.networkError)
            .eraseToAnyPublisher()
    }

    func stream(
        quote: Currency,
        at time: PriceTime,
        skipStale: Bool
    ) -> AnyPublisher<Result<[String: PriceQuoteAtTime], NetworkError>, Never> {
        repository.stream(
            bases: enabledCurrenciesService.allEnabledCryptoCurrencies,
            quote: quote,
            at: time,
            skipStale: skipStale
        )
    }
}
