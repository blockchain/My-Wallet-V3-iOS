// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

/// A pair of base-quote money values. Read about [Currency pairs](https://en.wikipedia.org/wiki/Currency_pair) for more information.
public struct MoneyValuePair: Equatable, Decodable {

    // MARK: - Public Properties

    /// The base money value.
    public let base: MoneyValue

    /// The quote money value.
    public let quote: MoneyValue

    // MARK: - Setup

    /// Creates a money value pair.
    ///
    /// - Parameters:
    ///   - base:         A base money value.
    ///   - exchangeRate: An exchange rate, representing one major unit of `base`'s currency in another currency.
    public init(base: MoneyValue, exchangeRate: MoneyValue) {
        self.init(
            base: base,
            quote: base.convert(using: exchangeRate)
        )
    }

    /// Creates a money value pair.
    ///
    /// - Parameters:
    ///   - base:         A base crypto value.
    ///   - exchangeRate: An exchange rate, representing one major unit of `base`'s currency in another currency.
    public init(base: CryptoValue, exchangeRate: FiatValue) {
        self.init(
            base: base.moneyValue,
            quote: base.convert(using: exchangeRate).moneyValue
        )
    }

    /// Creates a money value pair.
    ///
    /// - Parameters:
    ///   - fiatValue:      A fiat value.
    ///   - exchangeRate:   An exchange rate to convert `fiatValue` to a crypto value.
    ///   - cryptoCurrency: A crypto currency.
    ///   - usesFiatAsBase: Whether to use the fiat value or the crypto value as the base.
    public init(fiatValue: FiatValue, exchangeRate: FiatValue, cryptoCurrency: CryptoCurrency, usesFiatAsBase: Bool) {
        let cryptoValue: CryptoValue = fiatValue.convert(usingInverse: exchangeRate, currency: cryptoCurrency)

        if usesFiatAsBase {
            self.init(base: fiatValue.moneyValue, quote: cryptoValue.moneyValue)
        } else {
            self.init(base: cryptoValue.moneyValue, quote: fiatValue.moneyValue)
        }
    }

    /// Creates a money value pair.
    ///
    /// - Parameters:
    ///   - base:  A base money value.
    ///   - quote: A quote money value.
    public init(base: MoneyValue, quote: MoneyValue) {
        self.base = base
        self.quote = quote
    }

    // MARK: - Arithmetics

    /// Calculates the sum of two money value pairs.
    ///
    /// - Parameters:
    ///   - lhs: The first value to add.
    ///   - rhs: The second value to add.
    ///
    /// - Throws: A `MoneyOperatingError.mismatchingCurrencies` if the base currencies or the quote currencies do not match.
    public static func + (lhs: MoneyValuePair, rhs: MoneyValuePair) throws -> MoneyValuePair {
        let base = try lhs.base + rhs.base
        let quote = try lhs.quote + rhs.quote
        return MoneyValuePair(base: base, quote: quote)
    }

    /// Calculates the difference of two money value pairs.
    ///
    /// - Parameters:
    ///   - lhs: The value to subtract.
    ///   - rhs: The value to subtract from `lhs`.
    ///
    /// - Throws: A `MoneyOperatingError.mismatchingCurrencies` if the base currencies or the quote currencies do not match.
    public static func - (lhs: MoneyValuePair, rhs: MoneyValuePair) throws -> MoneyValuePair {
        let base = try lhs.base - rhs.base
        let quote = try lhs.quote - rhs.quote
        return MoneyValuePair(base: base, quote: quote)
    }

    /// Creates a zero valued money value pair.
    ///
    /// - Parameters:
    ///   - baseCurrency:  A base currency.
    ///   - quoteCurrency: A quote currency.
    public static func zero(baseCurrency: CurrencyType, quoteCurrency: CurrencyType) -> MoneyValuePair {
        MoneyValuePair(
            base: .zero(currency: baseCurrency),
            quote: .zero(currency: quoteCurrency)
        )
    }

    /// Returns the value before a percentage increase/decrease (e.g. for a value of 15, and a `percentChange` of 0.5 i.e. 50%, this returns 10).
    ///
    /// - Parameter percentageChange: A percentage of change.
    public func value(before percentageChange: Double) -> MoneyValuePair {
        MoneyValuePair(
            base: base.value(before: percentageChange),
            quote: quote.value(before: percentageChange)
        )
    }

    /// Returns a new `MoneyValuePair` instance intended to get the FX quote from an existing quote.
    /// This means that given a FX quote like 3 BTC = 150,000 USD, this will return a new quote => 1 BTC  = 150,000 / 3 BTC.
    public var exchangeRate: MoneyValuePair {
        // `try`s are disabled here as this operation can never fail.
        // If it failed, it would be a developer error and thus it's better to crash.
        guard !base.isZero, !quote.isZero else {
            return MoneyValuePair.zero(baseCurrency: base.currency, quoteCurrency: quote.currency)
        }

        let basePrecisionMultiplier = BigInt(10).power(base.storePrecision)
        let convertedAmount = (quote.storeAmount * basePrecisionMultiplier) / base.storeAmount

        return MoneyValuePair(
            base: .one(currency: base.currency),
            quote: MoneyValue(storeAmount: convertedAmount, currency: quote.currency)
        )
    }

    /// Returns a new `MoneyValuePair` instance intended to get the inverse FX quote from an existing quote.
    /// This means that given a FX quote like 1 BTC = 50,000 USD, this will return a new quote => 1 USD  = 1 / 50,000 BTC.
    public var inverseExchangeRate: MoneyValuePair {
        // `try`s are disabled here as this operation can never fail.
        // If it failed, it would be a developer error and thus it's better to crash.
        guard !base.isZero, !quote.isZero else {
            return MoneyValuePair.zero(baseCurrency: quote.currency, quoteCurrency: base.currency)
        }

        let quotePrecisionMultiplier = BigInt(10).power(quote.storePrecision)
        let convertedAmount = (base.storeAmount * quotePrecisionMultiplier) / quote.storeAmount

        return MoneyValuePair(
            base: .one(currency: quote.currencyType),
            quote: MoneyValue(storeAmount: convertedAmount, currency: base.currency)
        )
    }

    /// Returns the inversed money value pair.
    ///
    /// For a pair with base `2 BTC` and quote `50,000 USD`, this will return a pair with base `1 USD` and quote `2 / 50,000 BTC`.
    public var inverseQuote: MoneyValuePair {
        guard !base.isZero, !quote.isZero else {
            return .zero(
                baseCurrency: quote.currency,
                quoteCurrency: base.currency
            )
        }

        let newBase: MoneyValue = .one(currency: quote.currency)
        // Convert base to quote currency first, and then perform conversion with inverse quote.
        let newQuote: MoneyValue = base
            .convert(using: newBase)
            .convert(usingInverse: quote, currency: base.currency)

        return MoneyValuePair(base: newBase, quote: newQuote)
    }
}

extension MoneyValuePair: CustomDebugStringConvertible {

    public var debugDescription: String {
        """
        MoneyValuePair: \
        base \(base.displayString), \
        quote \(quote.displayString)
        """
    }
}
