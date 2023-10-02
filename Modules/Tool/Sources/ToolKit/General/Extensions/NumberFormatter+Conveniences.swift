// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension NumberFormatter {

    // MARK: - Public Types

    /// A currency format.
    public enum CurrencyFormat {

        /// Hide all fractional digits (e.g. `23.99` becomes `23`).
        case forceShortened

        /// If there are no fractional digits, the string would be shortened (e.g. `23.00` becomes `23`).
        case shortened

        /// The string would never be shortened (e.g. `23.00` stays `23.00`).
        case fullLength
    }

    // MARK: - Setup

    /// Creates a number formatter.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - currencyCode:      A currency code.
    ///   - maxFractionDigits: The maximum number of digits after the decimal separator.
    public convenience init(
        locale: Locale,
        currencyCode: String,
        maxFractionDigits: Int
    ) {
        self.init()
        usesGroupingSeparator = true
        roundingMode = .down
        numberStyle = .currency
        self.locale = locale
        self.currencyCode = currencyCode
        maximumFractionDigits = maxFractionDigits
    }

    // MARK: - Public Methods

    /// Returns a string containing the formatted amount, optionally including the symbol.
    ///
    /// - Parameters:
    ///   - amount:        An amount in major units.
    ///   - includeSymbol: Whether the symbol should be included.
    public func format(major amount: Decimal, includeSymbol: Bool) -> String {
        let formattedString = string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
        if !includeSymbol,
           let firstDigitIndex = formattedString.firstIndex(where: { $0.inSet(characterSet: .decimalDigits) }),
           let lastDigitIndex = formattedString.lastIndex(where: { $0.inSet(characterSet: .decimalDigits) })
        {
            return String(formattedString[firstDigitIndex...lastDigitIndex])
        }
        return formattedString
    }
}

extension Character {
    public func inSet(characterSet: CharacterSet) -> Bool {
        CharacterSet(charactersIn: "\(self)").isSubset(of: characterSet)
    }
}
