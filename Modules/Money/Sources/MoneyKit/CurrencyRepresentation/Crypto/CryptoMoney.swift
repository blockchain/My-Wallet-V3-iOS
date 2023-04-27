// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A crypto money.
public protocol CryptoMoney: Money {

    /// The crypto currency.
    var currency: CryptoCurrency { get }
}

extension CryptoMoney {

    public var isDust: Bool { false }

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        toDisplayString(includeSymbol: includeSymbol, withPrecision: .short, locale: locale)
    }

    /// Creates a displayable string, representing the currency amount in major units, in the given locale, using the given format, optionally including the currency symbol.
    ///
    /// - Parameters:
    ///   - includeSymbol: Whether the symbol should be included.
    ///   - precision:     A precision level.
    ///   - locale:        A locale.
    public func toDisplayString(
        includeSymbol: Bool,
        withPrecision precision: CryptoPrecision,
        locale: Locale
    ) -> String {
        CryptoFormatterProvider.shared
            .formatter(locale: locale, cryptoCurrency: currency, withPrecision: precision)
            .format(major: displayMajorValue, includeSymbol: includeSymbol)
    }
}
