// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
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

    /// Get all supported symbols for both crypto currency and fiat currency. Includes static data for each symbol.
    func symbols() -> AnyPublisher<CurrencySymbols, PriceServiceError>

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
    ///  - base:  The currency to get the price of.
    ///  - quote: The currency to get the price in.
    ///  - time:  The time to get the price at.
    ///
    /// - Returns: A publisher that emits a `[String: PriceQuoteAtTime]` on success, or a `PriceServiceError` on failure.
    func stream(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<Result<PriceQuoteAtTime, PriceServiceError>, Never>
}

final class PriceService: PriceServiceAPI {

    // MARK: - Private Properties

    private let app: AppProtocol
    private let multiSeries: IndexMutiSeriesPriceService
    private let repository: PriceRepositoryAPI
    private let currenciesService: EnabledCurrenciesServiceAPI

    // MARK: - Setup

    /// Creates a price service.
    ///
    /// - Parameters:
    ///   - repository:               A price repository.
    ///   - currenciesService: An enabled currencies service.
    init(
        app: AppProtocol,
        multiSeries: IndexMutiSeriesPriceService,
        repository: PriceRepositoryAPI,
        currenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.app = app
        self.multiSeries = multiSeries
        self.repository = repository
        self.currenciesService = currenciesService
    }

    func symbols() -> AnyPublisher<CurrencySymbols, PriceServiceError> {
        repository.symbols().mapError(PriceServiceError.networkError).eraseToAnyPublisher()
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

    func stream(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<Result<PriceQuoteAtTime, PriceServiceError>, Never> {
        guard base.code != quote.code else {
            // Base and Quote currencies are the same.
            return .just(.success(one(quote.currencyType, at: time)))
        }
        return Task.Publisher {
            do {
                if try await app.get(blockchain.app.configuration.prices.service.lazy.fetch.is.enabled) {
                    return new_stream(of: base, in: quote, at: time)
                } else {
                    return old_stream(of: base, in: quote, at: time)
                }
            } catch {
                return old_stream(of: base, in: quote, at: time)
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    func new_stream(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<Result<PriceQuoteAtTime, PriceServiceError>, Never> {
        multiSeries.publisher(for: .init(base: base.currencyType, quote: quote.currencyType, time: time.isNow ? nil : time.date))
            .flatMap { price -> AnyPublisher<Result<PriceQuoteAtTime, PriceServiceError>, Never> in
                if let price {
                    return Just(
                        .success(
                            PriceQuoteAtTime(
                                timestamp: price.timestamp,
                                moneyValue: MoneyValue.create(
                                    major: price.price ?? 0,
                                    currency: quote.currencyType
                                ),
                                marketCap: price.marketCap,
                                volume24h: price.volume24h
                            )
                        )
                    )
                    .eraseToAnyPublisher()
                } else {
                    return Just(.failure(PriceServiceError.missingPrice("\(base)-\(quote)")))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func old_stream(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<Result<PriceQuoteAtTime, PriceServiceError>, Never> {
        let baseCode = base.code
        let quoteCode = quote.code
        let key = key(baseCode, quoteCode)
        return Deferred { [currenciesService] in
            Future<[Currency], Never> { promise in
                if time.isSpecificDate {
                    promise(.success([base]))
                } else {
                    let currencies = currenciesService
                        .allEnabledCurrencies
                        .filter { $0.code != quote.code }
                    promise(.success(currencies))
                }
            }
        }
        .flatMap { [repository] bases in
            repository.stream(bases: bases, quote: quote, at: time, skipStale: false)
        }
        .map { prices -> Result<PriceQuoteAtTime, PriceServiceError> in
            prices.mapError(PriceServiceError.networkError).flatMap { result in
                if let price = result[key] {
                    return .success(price)
                } else {
                    return .failure(PriceServiceError.missingPrice(key))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        guard base.code != quote.code else {
            // Base and Quote currencies are the same.
            return .just(one(quote.currencyType, at: time))
        }
        return Task.Publisher {
            do {
                if try await app.get(blockchain.app.configuration.prices.service.lazy.fetch.is.enabled) {
                    return new_price(of: base, in: quote, at: time)
                } else {
                    return old_price(of: base, in: quote, at: time)
                }
            } catch {
                return old_price(of: base, in: quote, at: time)
            }
        }
        .switchToLatest()
        .prefix(1)
        .eraseToAnyPublisher()
    }

    func new_price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        multiSeries.publisher(for: .init(base: base.currencyType, quote: quote.currencyType, time: time.isNow ? nil : time.date))
            .flatMap { price -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> in
                if let price {
                    return Just(
                        PriceQuoteAtTime(
                            timestamp: price.timestamp,
                            moneyValue: MoneyValue.create(
                                major: price.price ?? 0,
                                currency: quote.currencyType
                            ),
                            marketCap: price.marketCap,
                            volume24h: price.volume24h
                        )
                    )
                    .setFailureType(to: PriceServiceError.self)
                    .eraseToAnyPublisher()
                } else {
                    return Fail(
                        outputType: PriceQuoteAtTime.self,
                        failure: PriceServiceError.missingPrice("\(base)-\(quote)")
                    )
                    .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func old_price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        let baseCode = base.code
        let quoteCode = quote.code
        let key = key(baseCode, quoteCode)
        return Deferred { [currenciesService] in
            Future<[Currency], Never> { promise in
                if time.isSpecificDate {
                    promise(.success([base]))
                } else {
                    let currencies = currenciesService
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
        .map { prices -> PriceQuoteAtTime? in
            // Get price of pair.
            prices[key]
        }
        .onNil(PriceServiceError.missingPrice(key))
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
}

private func key(_ baseCode: String, _ quoteCode: String) -> String {
    "\(baseCode)-\(quoteCode)"
}

private func one(_ currency: CurrencyType, at time: PriceTime) -> PriceQuoteAtTime {
    PriceQuoteAtTime(
        timestamp: time.date,
        moneyValue: .one(currency: currency),
        marketCap: nil
    )
}
