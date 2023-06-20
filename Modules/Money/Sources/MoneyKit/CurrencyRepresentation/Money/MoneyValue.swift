// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Extensions
import Foundation

/// A money value.
public struct MoneyValue: Money, Hashable {

    // MARK: - Private Types

    /// A wrapped money implementing value.
    private enum Value: Hashable {

        case fiat(FiatValue)

        case crypto(CryptoValue)
    }

    // MARK: - Public properties

    public var currency: CurrencyType {
        switch _value {
        case .crypto(let cryptoValue):
            return cryptoValue.currencyType
        case .fiat(let fiatValue):
            return fiatValue.currencyType
        }
    }

    public var storeAmount: BigInt {
        switch _value {
        case .crypto(let cryptoValue):
            return cryptoValue.storeAmount
        case .fiat(let fiatValue):
            return fiatValue.storeAmount
        }
    }

    /// Whether the money value is a crypto value.
    public var isCrypto: Bool {
        switch _value {
        case .crypto:
            return true
        case .fiat:
            return false
        }
    }

    /// Whether the money value is a fiat value.
    public var isFiat: Bool {
        switch _value {
        case .crypto:
            return false
        case .fiat:
            return true
        }
    }

    /// The fiat value, or `nil` if not a fiat value.
    public var fiatValue: FiatValue? {
        switch _value {
        case .crypto:
            return nil
        case .fiat(let fiatValue):
            return fiatValue
        }
    }

    /// The crypto value, or `nil` if not a crypto value.
    public var cryptoValue: CryptoValue? {
        switch _value {
        case .crypto(let cryptoValue):
            return cryptoValue
        case .fiat:
            return nil
        }
    }

    // MARK: - Private properties

    private let _value: Value

    // MARK: - Setup

    /// Creates a money value.
    ///
    /// - Parameter cryptoValue: A crypto value.
    public init(cryptoValue: CryptoValue) {
        self._value = .crypto(cryptoValue)
    }

    /// Creates a money value.
    ///
    /// - Parameter fiatValue: A fiat value.
    public init(fiatValue: FiatValue) {
        self._value = .fiat(fiatValue)
    }

    /// Creates a money value.
    ///
    /// - Parameters:
    ///   - amount:   An amount in minor units.
    ///   - currency: A currency.
    public init(storeAmount: BigInt, currency: CurrencyType) {
        switch currency {
        case .crypto(let cryptoCurrency):
            self._value = .crypto(CryptoValue(storeAmount: storeAmount, currency: cryptoCurrency))
        case .fiat(let fiatCurrency):
            self._value = .fiat(FiatValue(storeAmount: storeAmount, currency: fiatCurrency))
        }
    }

    // MARK: - Public methods

    /// Creates a displayable string, representing the currency amount in major units, in the given locale, optionally including the currency symbol.
    ///
    /// - Parameters:
    ///   - includeSymbol: Whether the symbol should be included.
    ///   - locale:        A locale.
    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        switch _value {
        case .crypto(let cryptoValue):
            return cryptoValue.toDisplayString(includeSymbol: includeSymbol, locale: locale)
        case .fiat(let fiatValue):
            return fiatValue.toDisplayString(includeSymbol: includeSymbol, locale: locale)
        }
    }

    /// Creates a simple string with minimal formatting, representing the currency amount in major units, optionally including the currency symbol.
    ///
    /// - Parameters:
    ///   - includeSymbol: Whether the symbol should be included.
    public func toSimpleString(includeSymbol: Bool, fullPrecision: Bool = true) -> String {
        let displayMajorValue = displayMajorValue
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.groupingSeparator = ""
        formatter.usesGroupingSeparator = false
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = fullPrecision ? currency.precision : currency.displayPrecision
        formatter.roundingMode = .down

        return [
            formatter.string(from: NSDecimalNumber(decimal: displayMajorValue)) ?? "\(displayMajorValue)",
            includeSymbol ? currency.displayCode : nil
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }

    /// Returns the value before a percentage increase/decrease (e.g. for a value of 15, and a `percentChange` of 0.5 i.e. 50%, this returns 10).
    ///
    /// - Parameter percentageChange: A percentage of change.
    public func value(before percentageChange: Double) -> MoneyValue {
        switch _value {
        case .crypto(let cryptoValue):
            return MoneyValue(cryptoValue: cryptoValue.value(before: percentageChange))
        case .fiat(let fiatValue):
            return MoneyValue(fiatValue: fiatValue.value(before: percentageChange))
        }
    }

    /// Converts the current money value with currency `A` into another money value with currency `B`, using a given exchange rate pair from `A` to `B`.
    ///
    /// - Parameter exchangeRate: An exchange rate, representing a money value pair with the base in currency `A`, and the quote in currency `B`.
    ///
    /// - Throws: A `MoneyOperatingError.mismatchingCurrencies` if the current currency and the `exchangeRate`'s base currency do not match.
    public func convert(using exchangeRate: MoneyValuePair) throws -> MoneyValue {
        guard currency != exchangeRate.quote.currency else {
            // Converting to the same currency.
            return self
        }
        guard currency == exchangeRate.base.currency else {
            throw MoneyOperatingError.mismatchingCurrencies(currency, exchangeRate.base.currency)
        }
        return convert(using: exchangeRate.quote)
    }

    // MARK: - Public factory methods

    /// Creates a zero valued money value (e.g. `0 USD`, `0 BTC`, etc.).
    ///
    /// - Parameter currency: A crypto currency.
    public static func zero(currency: CryptoCurrency) -> MoneyValue {
        MoneyValue(cryptoValue: .zero(currency: currency))
    }

    /// Creates a zero valued money value (e.g. `0 USD`, `0 BTC`, etc.).
    ///
    /// - Parameter currency: A fiat currency.
    public static func zero(currency: FiatCurrency) -> MoneyValue {
        MoneyValue(fiatValue: .zero(currency: currency))
    }

    /// Creates a one (major unit) valued money value (e.g. `1 USD`, `1 BTC`, etc.).
    ///
    /// - Parameter currency: A crypto currency.
    public static func one(currency: CryptoCurrency) -> MoneyValue {
        MoneyValue(cryptoValue: .one(currency: currency))
    }

    /// Creates a one (major unit) valued money value (e.g. `1 USD`, `1 BTC`, etc.).
    ///
    /// - Parameter currency: A fiat currency.
    public static func one(currency: FiatCurrency) -> MoneyValue {
        MoneyValue(fiatValue: .one(currency: currency))
    }
}

extension MoneyValue: MoneyOperating {}

extension MoneyValue {

    public var isDust: Bool {
        switch _value {
        case .crypto(let c):
            return c.isDust
        case .fiat(let f):
            return f.isDust
        }
    }

    public var isNotDust: Bool { !isDust }

    public var shortDisplayString: String {
        let formattedMinimum: String
        if let fiatValue = fiatValue?.displayableRounding(decimalPlaces: 0, roundingMode: .up) {
            formattedMinimum = fiatValue.toDisplayString(includeSymbol: true, format: .shortened, locale: .current)
        } else {
            formattedMinimum = displayString
        }
        return formattedMinimum
    }

    /// Used for analytics purposes only, for other things use `displayString` instead.
    public var displayMajorValue: Decimal {
        storeAmount.toDecimalMajor(
            baseDecimalPlaces: currencyType.storePrecision,
            roundingDecimalPlaces: currencyType.precision
        )
    }
}

extension CryptoValue {

    /// Creates a money value from the current `CryptoValue`.
    public var moneyValue: MoneyValue {
        MoneyValue(cryptoValue: self)
    }
}

extension FiatValue {

    /// Creates a money value from the current `FiatValue`.
    public var moneyValue: MoneyValue {
        MoneyValue(fiatValue: self)
    }
}

extension CryptoValue {
   public func toFiatAmount(with quote: MoneyValue?) -> FiatValue? {
        guard let quote else {
            return nil
        }
        let moneyValuePair = MoneyValuePair(
            base: .one(currency: currency),
            quote: quote
        )
        return try? moneyValue
            .convert(using: moneyValuePair)
            .fiatValue
    }
}

extension MoneyValue {
    public func toCryptoAmount(
        currency: CryptoCurrency?,
        cryptoPrice: MoneyValue?
    ) -> MoneyValue? {
        guard let currency else {
            return nil
        }

        guard let exchangeRate = cryptoPrice else {
            return nil
        }

        let exchange = MoneyValuePair(
            base: .one(currency: .crypto(currency)),
            quote: exchangeRate
        )
        .inverseExchangeRate

        return try? convert(using: exchange)
    }
}
