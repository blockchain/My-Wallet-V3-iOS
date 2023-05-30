// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

public protocol MoneyImplementing: Money {

    /// A currency type.
    associatedtype MoneyCurrency: Currency

    /// The currency.
    var currency: MoneyCurrency { get }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - amount:   An amount in minor units.
    ///   - currency: A currency.
    init(storeAmount: BigInt, currency: MoneyCurrency)
}

extension MoneyImplementing {

    public var currencyType: CurrencyType {
        currency.currencyType
    }

    /// Creates a zero valued money (e.g. `0 USD`, `0 BTC`, etc.).
    ///
    /// - Parameter currency: A currency.
    public static func zero(currency: MoneyCurrency) -> Self {
        create(minor: 0, currency: currency)
    }

    /// Creates a one (major unit) valued money (e.g. `1 USD`, `1 BTC`, etc.).
    ///
    /// - Parameter currency: A currency.
    public static func one(currency: MoneyCurrency) -> Self {
        create(majorBigInt: 1, currency: currency)
    }

    // MARK: - Major value

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in major units. Valid if it can be converted to a `Decimal` using the user's current locale.
    ///   - currency: A currency.
    ///
    /// - Returns: A money, or `nil` if `value` is invalid.
    public static func create(majorDisplay value: String, currency: MoneyCurrency) -> Self? {
        create(major: value, currency: currency, locale: Locale.current)
    }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in major units. Valid if it can be converted to a `Decimal` using the `POSIX` locale.
    ///   - currency: A currency.
    ///
    /// - Returns: A money, or `nil` if `value` is invalid.
    public static func create(major value: String, currency: MoneyCurrency) -> Self? {
        create(major: value, currency: currency, locale: Locale.Posix)
    }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in major units.
    ///   - currency: A currency.
    public static func create(major value: Decimal, currency: MoneyCurrency) -> Self {
        let minorDecimal = value * pow(10, currency.precision)
        return create(minor: minorDecimal, currency: currency)
    }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in major units.
    ///   - currency: A currency.
    public static func create(major value: Double, currency: MoneyCurrency) -> Self {
        let minorDouble: Double = value * pow(10, currency.precision).doubleValue
        return create(minorDouble: minorDouble, currency: currency)
    }

    /// Creates a money.
    ///
    /// Note that this method parameter is called majorBigInt so it doesn't clash with the String option, due to BigInt being String representable.
    ///
    /// - Parameters:
    ///   - majorBigInt:    An amount in major units.
    ///   - currency: A currency.
    public static func create(majorBigInt value: BigInt, currency: MoneyCurrency) -> Self {
        let minor: BigInt = value * BigInt(10).power(currency.precision)
        return create(minor: minor, currency: currency)
    }

    // MARK: - Minor value

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in minor units. Valid if it can be converted to a `BigInt`.
    ///   - currency: A currency.
    ///
    /// - Returns: A money, or `nil` if `value` is invalid.
    public static func create(minor value: String, currency: MoneyCurrency) -> Self? {
        guard let value = BigInt(value) else {
            return nil
        }
        let storeAmount: BigInt = value * BigInt(10).power(currency.storeExtraPrecision)
        return Self(storeAmount: storeAmount, currency: currency)
    }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in minor units. Any fractional digits will be trimmed.
    ///   - currency: A currency.
    public static func create(minorDouble value: Double, currency: MoneyCurrency) -> Self {
        let storeAmountDouble: Double = value * pow(10, currency.storeExtraPrecision).doubleValue
        let storeAmount = BigInt(storeAmountDouble)
        return Self(storeAmount: storeAmount, currency: currency)
    }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in minor units. Any fractional digits will be trimmed.
    ///   - currency: A currency.
    public static func create(minor value: Decimal, currency: MoneyCurrency) -> Self {
        let storeAmountDecimal: Decimal = value * pow(10, currency.storeExtraPrecision)
        let storeAmountBigInt = BigInt(decimalLiteral: storeAmountDecimal)
        return Self(storeAmount: storeAmountBigInt, currency: currency)
    }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in minor units.
    ///   - currency: A currency.
    public static func create(minor value: Int, currency: MoneyCurrency) -> Self {
        create(minor: BigInt(value), currency: currency)
    }

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in minor units.
    ///   - currency: A currency.
    public static func create(minor value: BigInt, currency: MoneyCurrency) -> Self {
        let storeAmount: BigInt = value * BigInt(10).power(currency.storeExtraPrecision)
        return Self(storeAmount: storeAmount, currency: currency)
    }

    // MARK: - Private methods

    /// Creates a money.
    ///
    /// - Parameters:
    ///   - value:    An amount in major units. Valid if it can be converted to a `Decimal` using `locale`.
    ///   - currency: A currency.
    ///   - locale:   A locale.
    ///
    /// - Returns: A money, or `nil` if `value` is invalid.
    private static func create(major value: String, currency: MoneyCurrency, locale: Locale) -> Self? {
        guard let majorDecimal = Decimal(string: value, locale: locale), !majorDecimal.isNaN else {
            return nil
        }
        return create(major: majorDecimal, currency: currency)
    }
}
