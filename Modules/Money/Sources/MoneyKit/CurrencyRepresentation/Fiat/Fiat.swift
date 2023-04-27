// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

/// A fiat money.
public protocol Fiat: Money {

    /// The fiat currency.
    var currency: FiatCurrency { get }
}

extension Fiat {

    public var isDust: Bool {
        storeAmount > 0 && displayMajorValue < 1
    }

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        toDisplayString(includeSymbol: includeSymbol, format: .fullLength, locale: locale, precision: nil)
    }

    /// Creates a displayable string, representing the currency amount in major units, in the given locale, using the given format, optionally including the currency symbol.
    ///
    /// - Parameters:
    ///   - includeSymbol: Whether the symbol should be included.
    ///   - format                    A format.
    ///   - locale:        A locale.
    public func toDisplayString(
        includeSymbol: Bool,
        format: NumberFormatter.CurrencyFormat = .fullLength,
        locale: Locale = .current,
        precision: Int? = nil
    ) -> String {
        let currencyPrecision = precision ?? currency.precision
        let displayMajorValue = displayMajorValue
        let oneMinor = Decimal(1) / pow(10, currencyPrecision)
        let valueLessThanOneMinor = displayMajorValue > 0 && (displayMajorValue < oneMinor)
        let exponentLessThanOne = displayMajorValue.exponent < 0

        let maxFractionDigits: Int
        switch (format, valueLessThanOneMinor, exponentLessThanOne) {
        case (.fullLength, false, _):
            maxFractionDigits = currencyPrecision
        case (.fullLength, true, _):
            maxFractionDigits = min(Int(displayMajorValue.exponent.magnitude), currency.storePrecision)
        case (.shortened, _, true):
            maxFractionDigits = currencyPrecision
        case (.shortened, _, false):
            maxFractionDigits = 0
        }

        let result = Self._toDisplayString(
            locale: locale,
            includeSymbol: includeSymbol,
            currency: currency,
            maxFractionDigits: maxFractionDigits,
            displayMajorValue: displayMajorValue
        )

        return result
    }

    private static func _toDisplayString(
        locale: Locale,
        includeSymbol: Bool,
        currency: FiatCurrency,
        maxFractionDigits: Int,
        displayMajorValue: Decimal
    ) -> String {
        FiatFormatterProvider.shared
            .formatter(locale: locale, fiatCurrency: currency, maxFractionDigits: maxFractionDigits)
            .format(major: displayMajorValue, includeSymbol: includeSymbol)
    }
}
