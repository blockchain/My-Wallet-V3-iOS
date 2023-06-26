// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import MoneyKit

public struct DelegatedCustodyBalances: Equatable {

    public struct Balance: Equatable {

        public let index: Int
        public let name: String
        public let balance: MoneyValue?
        public let currency: CurrencyType

        public init(index: Int, name: String, balance: MoneyValue) {
            self.index = index
            self.name = name
            self.balance = balance
            self.currency = balance.currency
        }
    }

    public struct Network: Equatable {
        public let currency: CryptoCurrency
        public let errorLoadingBalances: Bool

        public init(currency: CryptoCurrency, errorLoadingBalances: Bool) {
            self.currency = currency
            self.errorLoadingBalances = errorLoadingBalances
        }
    }

    public let balances: [Balance]
    public let networks: [Network]

    public func balance(index: Int, currency: CryptoCurrency) -> MoneyValue? {
        balances
            .first(where: { $0.index == index && $0.currency == currency })?.balance
    }

    public init(balances: [DelegatedCustodyBalances.Balance], networks: [DelegatedCustodyBalances.Network]) {
        self.balances = balances
        self.networks = networks
    }

    public var hasAnyBalance: Bool {
        balances.contains(where: { $0.balance?.isPositive ?? false })
    }

    public var networksFailing: [Network] {
        networks.filter(\.errorLoadingBalances)
    }
}

extension DelegatedCustodyBalances {

    public static var empty: DelegatedCustodyBalances {
        DelegatedCustodyBalances(balances: [], networks: [])
    }

    public static var preview: DelegatedCustodyBalances {
        _ = App.preview
        let currencies = EnabledCurrenciesService
            .default
            .allEnabledCryptoCurrencies
        return DelegatedCustodyBalances(
            balances: currencies.map { currency in
                    .init(index: 0, name: "Defi Wallet", balance: .one(currency: currency))
            },
            networks: []
        )
    }
}
