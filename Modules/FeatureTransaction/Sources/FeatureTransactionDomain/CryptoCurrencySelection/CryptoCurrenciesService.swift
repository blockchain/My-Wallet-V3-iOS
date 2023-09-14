// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

public struct CryptoCurrencyQuote: Equatable {
    public let cryptoCurrency: CryptoCurrency
    public let fiatCurrency: FiatCurrency
    public let quote: BigInt
    public let formattedQuote: String
    public let priceChange: Decimal
    public let formattedPriceChange: String
    public let timestamp: Date

    public init(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        quote: BigInt,
        formattedQuote: String,
        priceChange: Decimal,
        formattedPriceChange: String,
        timestamp: Date
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.fiatCurrency = fiatCurrency
        self.quote = quote
        self.formattedQuote = formattedQuote
        self.priceChange = priceChange
        self.formattedPriceChange = formattedPriceChange
        self.timestamp = timestamp
    }
}

extension CryptoCurrencyQuote: Identifiable {

    public var id: String {
        "\(cryptoCurrency.code)\(fiatCurrency.code)"
    }
}

public enum CryptoCurrenciesServiceError: Error, Equatable {
    case other(Error)

    var description: String? {
        if case .other(let error) = self {
            return String(describing: error)
        }
        return nil
    }

    public static func == (lhs: CryptoCurrenciesServiceError, rhs: CryptoCurrenciesServiceError) -> Bool {
        lhs.description == rhs.description
    }
}

public protocol CryptoCurrenciesServiceAPI {
    /// Fetches purchasable crypto currencies for fiat currency defaulted to USD.
    /// This is used for showing the list of crypto in buy button as card payment.
    func fetchPurchasableCryptoCurrencies() -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError>

    func fetchPurchasableCryptoCurrencies(
        using fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError>
}

final class CryptoCurrenciesService: CryptoCurrenciesServiceAPI {

    // MARK: - Private Properties

    private let pairsService: SupportedPairsServiceAPI
    private let priceService: PriceServiceAPI

    // MARK: - Init

    init(pairsService: SupportedPairsServiceAPI, priceService: PriceServiceAPI) {
        self.pairsService = pairsService
        self.priceService = priceService
    }

    // MARK: - CryptoCurrenciesServiceAPI

    func fetchPurchasableCryptoCurrencies() -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError> {
        fetchPurchasableCryptoCurrencies(using: FiatCurrency.USD)
    }

    func fetchPurchasableCryptoCurrencies(
        using fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError> {
        // Step 1: Fetch all Crypto Currencies that can be purchased using the passed-in Fiat Currency
        pairsService.fetchPairs(for: .only(fiatCurrency: fiatCurrency))
            .mapError(CryptoCurrenciesServiceError.other)
            .flatMap { [priceService] data -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError> in
                // Step 2: Combine each purchasable Crypto Currency with its price data from the last 24h and merge results into a single value
                Publishers.MergeMany(
                    data.pairs.map { pair -> AnyPublisher<CryptoCurrencyQuote, CryptoCurrenciesServiceError> in
                        // Step 2a: Fetch latest quote as the historical data doesn't provide enough info
                        priceService.price(of: pair.cryptoCurrency, in: pair.fiatCurrency)
                            .zip(
                                // Step 2b: Fetch also the historical prices to get the price change delta
                                priceService
                                    .priceSeries(
                                        of: pair.cryptoCurrency,
                                        in: pair.fiatCurrency,
                                        within: .day(.oneHour)
                                    )
                            )
                            .mapError(CryptoCurrenciesServiceError.other)
                            .map { quote, historicalPriceSeries in
                                CryptoCurrencyQuote(
                                    cryptoCurrency: pair.cryptoCurrency,
                                    fiatCurrency: pair.fiatCurrency,
                                    quote: quote.moneyValue.minorAmount,
                                    formattedQuote: quote
                                        .moneyValue
                                        .toDisplayString(
                                            includeSymbol: true,
                                            locale: .current
                                        ),
                                    priceChange: historicalPriceSeries.delta,
                                    formattedPriceChange: "\(historicalPriceSeries.deltaPercentage.string(with: 2))%",
                                    timestamp: quote.timestamp
                                )
                            }
                            .eraseToAnyPublisher()
                    }
                )
                .collect()
                .map { quotes in
                    quotes.sorted { $0.cryptoCurrency < $1.cryptoCurrency }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
