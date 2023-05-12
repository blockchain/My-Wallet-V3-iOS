// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import MoneyKit

public struct DelegatedCustodyBalances: Equatable {

    public struct Balance: Equatable {

        public let index: Int
        public let name: String
        public let balance: MoneyValue
        public let currency: CurrencyType

        public init(index: Int, name: String, balance: MoneyValue) {
            self.index = index
            self.name = name
            self.balance = balance
            self.currency = balance.currency
        }
    }

    public let balances: [Balance]

    public func balance(index: Int, currency: CryptoCurrency) -> MoneyValue? {
        balances
            .first(where: { $0.index == index && $0.currency == currency })
            .map(\.balance)
    }

    public init(balances: [DelegatedCustodyBalances.Balance]) {
        self.balances = balances
    }

    public var hasAnyBalance: Bool {
        balances.contains(where: \.balance.isPositive)
    }
}

extension DelegatedCustodyBalances {

    public static var empty: DelegatedCustodyBalances {
        DelegatedCustodyBalances(balances: [])
    }

    public static var preview: DelegatedCustodyBalances {
        _ = App.preview
        let currencies = EnabledCurrenciesService
            .default
            .allEnabledCryptoCurrencies
        return DelegatedCustodyBalances(
            balances: currencies.map { currency in
                    .init(index: 0, name: "Defi Wallet", balance: .one(currency: currency))
            }
        )
    }
}
