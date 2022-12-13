// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

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

public enum CurrencyType: Hashable, Decodable {

    /// A fiat currency.
    case fiat(FiatCurrency)

    /// A crypto currency.
    case crypto(CryptoCurrency)

    /// Creates a currency type.
    ///
    /// - Parameters:
    ///   - code:                     A currency code.
    ///   - enabledCurrenciesService: An enabled currencies service.
    ///
    /// - Throws: A `CurrencyError.unknownCurrency` if `code` is invalid.
    public init(code: String, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) throws {
        if let cryptoCurrency = CryptoCurrency(code: code, enabledCurrenciesService: enabledCurrenciesService) {
            self = .crypto(cryptoCurrency)
            return
        }

        if let fiatCurrency = FiatCurrency(code: code) {
            self = .fiat(fiatCurrency)
            return
        }

        throw CurrencyError.unknownCurrency
    }

    public static func == (lhs: CurrencyType, rhs: FiatCurrency) -> Bool {
        switch lhs {
        case crypto:
            return false
        case fiat(let lhs):
            return lhs == rhs
        }
    }

    public static func == (lhs: CurrencyType, rhs: CryptoCurrency) -> Bool {
        switch lhs {
        case crypto(let lhs):
            return lhs == rhs
        case fiat:
            return false
        }
    }
}

extension CurrencyType: Currency {

    public static let maxDisplayPrecision: Int = max(FiatCurrency.maxDisplayPrecision, CryptoCurrency.maxDisplayPrecision)

    public var name: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.name
        case .fiat(let fiatCurrency):
            return fiatCurrency.name
        }
    }

    public var code: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.code
        case .fiat(let fiatCurrency):
            return fiatCurrency.code
        }
    }

    public var displayCode: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.displayCode
        case .fiat(let fiatCurrency):
            return fiatCurrency.displayCode
        }
    }

    public var displaySymbol: String {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.displaySymbol
        case .fiat(let fiatCurrency):
            return fiatCurrency.displaySymbol
        }
    }

    public var precision: Int {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.precision
        case .fiat(let fiatCurrency):
            return fiatCurrency.precision
        }
    }

    public var storeExtraPrecision: Int {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.storeExtraPrecision
        case .fiat(let fiatCurrency):
            return fiatCurrency.storeExtraPrecision
        }
    }

    public var displayPrecision: Int {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency.displayPrecision
        case .fiat(let fiatCurrency):
            return fiatCurrency.displayPrecision
        }
    }

    public var isFiatCurrency: Bool {
        switch self {
        case .crypto:
            return false
        case .fiat:
            return true
        }
    }

    public var isCryptoCurrency: Bool {
        switch self {
        case .crypto:
            return true
        case .fiat:
            return false
        }
    }

    public var currencyType: CurrencyType { self }

    /// The crypto currency, or `nil` if not a crypto currency.
    public var cryptoCurrency: CryptoCurrency? {
        switch self {
        case .crypto(let cryptoCurrency):
            return cryptoCurrency
        case .fiat:
            return nil
        }
    }

    /// The fiat currency, or `nil` if not a fiat currency.
    public var fiatCurrency: FiatCurrency? {
        switch self {
        case .crypto:
            return nil
        case .fiat(let fiatCurrency):
            return fiatCurrency
        }
    }
}

extension CryptoCurrency {
    public var currencyType: CurrencyType {
        .crypto(self)
    }
}

extension FiatCurrency {
    public var currencyType: CurrencyType {
        .fiat(self)
    }
}

extension CryptoValue {
    public var currencyType: CurrencyType {
        currency.currencyType
    }
}

extension FiatValue {
    public var currencyType: CurrencyType {
        currency.currencyType
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
}
