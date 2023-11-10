// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol CurrencyConversionServiceAPI {

    /// Fetches the conversion rate from a source currency to a target currency.
    /// - Note: Contrary to `PriceServiceAPI.price(of:in:)` this API checks for edge cases to always return the correct value.
    /// - Parameters:
    ///   - sourceCurrency: The currency to convert from.
    ///   - targetCurrency: The currency to convert to.
    func conversionRate(
        from sourceCurrency: CurrencyType,
        to targetCurrency: CurrencyType
    ) -> AnyPublisher<MoneyValue, PriceServiceError>

    /// Converts an amount in the target currency.
    /// - Parameters:
    ///   - amount: The amount to convert.
    ///   - targetCurrency: The target currency. The passed-in amount will be converted to this currency.
    /// - Returns: A publisher that emits a `MoneyValue` on success or a  `PriceServiceError` on failure.
    func convert(
        _ amount: MoneyValue,
        to targetCurrency: CurrencyType
    ) -> AnyPublisher<MoneyValue, PriceServiceError>
}

final class CurrencyConversionService: CurrencyConversionServiceAPI {

    private let priceService: PriceServiceAPI

    init(priceService: PriceServiceAPI) {
        self.priceService = priceService
    }

    func conversionRate(
        from sourceCurrency: CurrencyType,
        to targetCurrency: CurrencyType
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        guard sourceCurrency != targetCurrency else {
            return .just(.one(currency: sourceCurrency))
        }
        // The API doesn't respond on requests like USD-BTC but it responds to BTC-USD 🤷
        guard sourceCurrency.isCryptoCurrency || (sourceCurrency.isFiatCurrency && targetCurrency.isFiatCurrency) else {
            return priceService
                .price(of: targetCurrency, in: sourceCurrency)
                .map(\.moneyValue)
                .map { price in
                    MoneyValuePair(base: .one(currency: targetCurrency), exchangeRate: price)
                }
                .map(\.inverseQuote.quote)
                .eraseToAnyPublisher()
        }
        return priceService
            .price(of: sourceCurrency, in: targetCurrency)
            .map(\.moneyValue)
            .eraseToAnyPublisher()
    }

    func convert(
        _ amount: MoneyValue,
        to targetCurrency: CurrencyType
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        let sourceCurrency = amount.currencyType
        guard sourceCurrency != targetCurrency else {
            return .just(amount)
        }
        return conversionRate(from: sourceCurrency, to: targetCurrency)
            .map { conversionRate in
                amount.convert(using: conversionRate)
            }
            .eraseToAnyPublisher()
    }
}
