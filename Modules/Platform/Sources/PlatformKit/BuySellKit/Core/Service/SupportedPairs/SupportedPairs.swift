// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

/// Simple-Buy supported pairs
public struct SupportedPairs: Equatable {
    static let empty: SupportedPairs = .init(pairs: [])

    /// A possible tradable pair supported by Simple-Buy feature
    public struct Pair: Equatable {

        public var string: String {
            "\(cryptoCurrency.code)-\(fiatCurrency.code)"
        }

        /// The crypto currency type
        public let cryptoCurrency: CryptoCurrency

        /// The fiat currency type
        public var fiatCurrency: FiatCurrency {
            minFiatValue.currency
        }

        /// The minimum fiat value to buy
        public let minFiatValue: FiatValue

        /// The maximum fiat value to buy
        public let maxFiatValue: FiatValue
    }

    /// Array of supported pairs
    public let pairs: [Pair]

    /// Array of supported unique crypto-currencies, sorted following `CryptoCurrency` default order.
    public var cryptoCurrencies: [CryptoCurrency] {
        .init(cryptoCurrencySet).sorted()
    }

    var fiatCurrencySet: Set<FiatCurrency> {
        Set(pairs.map(\.minFiatValue.currency))
    }

    public var cryptoCurrencySet: Set<CryptoCurrency> {
        Set(pairs.map(\.cryptoCurrency))
    }

    // MARK: - Methods

    /// Returns all pairs that include the given crypto-currency
    public func pairs(per cryptoCurrency: CryptoCurrency) -> [Pair] {
        pairs.filter { $0.cryptoCurrency == cryptoCurrency }
    }

    func contains(fiatCurrency: FiatCurrency) -> Bool {
        fiatCurrencySet.contains(fiatCurrency)
    }

    func contains(oneOf currencies: [FiatCurrency]) -> Bool {
        !fiatCurrencySet.isDisjoint(with: currencies)
    }

    func contains(oneOf currencies: FiatCurrency...) -> Bool {
        contains(oneOf: currencies)
    }
}

// MARK: - Setup

extension SupportedPairs {
    init(response: SupportedPairsResponse, filterOption: SupportedPairsFilterOption) {
        let pairs = response.pairs.compactMap { Pair(response: $0) }
        switch filterOption {
        case .all:
            self.pairs = pairs
        case .only(fiatCurrency: let currency):
            self.pairs = pairs.filter { $0.maxFiatValue.currencyType == currency }
        }
    }
}

extension SupportedPairs.Pair {
    init?(response: SupportedPairsResponse.Pair) {
        let components = response.pair.split(separator: "-")
        guard components.count == 2 else { return nil }
        let rawCryptoCurrency = String(components[0])

        guard let cryptoCurrency = CryptoCurrency(code: rawCryptoCurrency) else {
            return nil
        }
        guard let fiatCurrency = FiatCurrency(code: String(components[1])) else {
            return nil
        }
        self.cryptoCurrency = cryptoCurrency
        minFiatValue = FiatValue.create(minor: response.buyMin, currency: fiatCurrency)!
        maxFiatValue = FiatValue.create(minor: response.buyMax, currency: fiatCurrency)!
    }
}
