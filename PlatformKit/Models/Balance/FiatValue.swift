//
//  FiatValue.swift
//  PlatformKit
//
//  Created by Chris Arriola on 1/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct FiatComparisonError: Error {
    let currencyCode1: String
    let currencyCode2: String
}

public struct FiatValue {
    /// The currency code (e.g. "USD")
    public let currencyCode: String
    public let amount: Decimal
}

extension FiatValue {
    /// Creates a FiatValue from a provided amount in String and currency code.
    /// If the amountString is invalid, the resulting FiatValue amount will be 0.
    ///
    /// - Parameters:
    ///   - amountString: the amount as a String
    ///   - currencyCode: the currency code
    /// - Returns: the FiatValue
    public static func create(amountString: String, currencyCode: String) -> FiatValue {
        let amount = Decimal(string: amountString, locale: Locale.current) ?? 0
        return FiatValue(currencyCode: currencyCode, amount: amount)
    }

    public static func create(amount: Decimal, currencyCode: String) -> FiatValue {
        return FiatValue(currencyCode: currencyCode, amount: amount)
    }
    
    public static func zero(currencyCode: String) -> FiatValue {
        return FiatValue(currencyCode: currencyCode, amount: 0.0)
    }
}

extension FiatValue: Money {
    public var isZero: Bool {
        return amount == 0
    }

    public var isPositive: Bool {
        return amount > 0
    }

    public var symbol: String {
        let locale = NSLocale(localeIdentifier: currencyCode)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: currencyCode) ?? ""
    }

    public var maxDecimalPlaces: Int {
        let formattedString = toDisplayString(includeSymbol: false, locale: Locale.US)
        let components = formattedString.split(separator: ".")
        guard let lastComponent = components.last, components.count > 1 else {
            return 0
        }
        return lastComponent.count
    }

    public var maxDisplayableDecimalPlaces: Int {
        return maxDecimalPlaces
    }

    public func toDisplayString(includeSymbol: Bool = true, locale: Locale = Locale.current) -> String {
        let formatter = FiatFormatterProvider.shared.formatter(locale: locale, fiatValue: self)
        let formattedString = formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
        if let firstDigitIndex = formattedString.firstIndex(where: { $0.inSet(characterSet: CharacterSet.decimalDigits) }),
           let lastDigitIndex = formattedString.lastIndex(where: { $0.inSet(characterSet: CharacterSet.decimalDigits) }),
           !includeSymbol {
            return String(formattedString[firstDigitIndex...lastDigitIndex])
        }
        return formattedString
    }
}

extension Character {
    func inSet(characterSet: CharacterSet) -> Bool {
        return CharacterSet(charactersIn: "\(self)").isSubset(of: characterSet)
    }
}

// MARK: - Operators

extension FiatValue: Hashable, Equatable {
    private static func ensureComparable(value: FiatValue, other: FiatValue) throws {
        if value.currencyCode != other.currencyCode {
            throw FiatComparisonError(currencyCode1: value.currencyCode, currencyCode2: other.currencyCode)
        }
    }

    public static func +(lhs: FiatValue, rhs: FiatValue) throws -> FiatValue {
        try ensureComparable(value: lhs, other: rhs)
        return FiatValue(currencyCode: lhs.currencyCode, amount: lhs.amount + rhs.amount)
    }

    public static func -(lhs: FiatValue, rhs: FiatValue) throws -> FiatValue {
        try ensureComparable(value: lhs, other: rhs)
        return FiatValue(currencyCode: lhs.currencyCode, amount: lhs.amount - rhs.amount)
    }

    public static func *(lhs: FiatValue, rhs: FiatValue) throws -> FiatValue {
        try ensureComparable(value: lhs, other: rhs)
        return FiatValue(currencyCode: lhs.currencyCode, amount: lhs.amount * rhs.amount)
    }

    public static func +=(lhs: inout FiatValue, rhs: FiatValue) throws {
        lhs = try lhs + rhs
    }

    public static func -=(lhs: inout FiatValue, rhs: FiatValue) throws {
        lhs = try lhs - rhs
    }

    public static func *= (lhs: inout FiatValue, rhs: FiatValue) throws {
        lhs = try lhs * rhs
    }
}

// MARK: FiatFormatterProvider

private class FiatFormatterProvider {

    static let shared = FiatFormatterProvider()

    private var formatterMap = [String: NumberFormatter]()

    func formatter(locale: Locale, fiatValue: FiatValue) -> NumberFormatter {
        let mapKey = key(locale: locale, fiatValue: fiatValue)
        guard let matchingFormatter = formatterMap[mapKey] else {
            let formatter = createNumberFormatter(locale: locale, fiatValue: fiatValue)
            formatterMap[mapKey] = formatter
            return formatter
        }
        return matchingFormatter
    }

    private func key(locale: Locale, fiatValue: FiatValue) -> String {
        return "\(locale.identifier)_\(fiatValue.currencyCode)"
    }

    private func createNumberFormatter(locale: Locale, fiatValue: FiatValue) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.roundingMode = .down
        formatter.locale = locale
        formatter.currencyCode = fiatValue.currencyCode
        formatter.numberStyle = .currency
        return formatter
    }
}
