// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftExtensions

/// A currency error.
public enum CurrencyError: Error {

    /// Unknown currency code.
    case unknownCurrency
}

public protocol Currency {

    /// The maximum display precision between all the possible currencies.
    static var maxDisplayPrecision: Int { get }

    /// The currency name (e.g. `US Dollar`, `Bitcoin`, etc.).
    var name: String { get }

    /// The currency code (e.g. `USD`, `BTC`, etc.).
    var code: String { get }

    /// The currency display code (e.g. `USD`, `BTC`, etc.).
    var displayCode: String { get }

    /// The currency symbol (e.g. `$`, `BTC`, etc.).
    var displaySymbol: String { get }

    /// The currency precision.
    var precision: Int { get }

    /// The precison to be used when storing values in memory.
    /// Used when doing mathematical operations.
    var storePrecision: Int { get }

    var storeExtraPrecision: Int { get }

    /// The currency display precision (shorter than or equal to `precision`).
    var displayPrecision: Int { get }

    /// Whether the currency is a fiat currency.
    var isFiatCurrency: Bool { get }

    /// Whether the currency is a crypto currency.
    var isCryptoCurrency: Bool { get }

    /// The `CurrencyType` wrapper for self.
    var currencyType: CurrencyType { get }
}

extension Currency {

    public var storePrecision: Int {
        precision + storeExtraPrecision
    }

    public var isFiatCurrency: Bool {
        self is FiatCurrency
    }

    public var isCryptoCurrency: Bool {
        self is CryptoCurrency
    }
}

extension Currency {

    public func matchSearch(_ searchString: String?) -> Bool {
        guard let searchString,
              !searchString.isEmpty
        else {
            return true
        }
        return name.localizedCaseInsensitiveContains(searchString)
            || code.localizedCaseInsensitiveContains(searchString)
            || displayCode.localizedCaseInsensitiveContains(searchString)
    }

    public func filter(by searchText: String, using algorithm: StringDistanceAlgorithm) -> Bool {
        name.distance(between: searchText, using: algorithm) == 0 ||
            code.distance(between: searchText, using: algorithm) == 0 ||
            displayCode.distance(between: searchText, using: algorithm) == 0
    }
}
