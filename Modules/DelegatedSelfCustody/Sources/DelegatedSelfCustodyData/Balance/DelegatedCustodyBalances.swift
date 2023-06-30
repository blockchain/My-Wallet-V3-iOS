// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DelegatedSelfCustodyDomain
import MoneyKit

extension DelegatedCustodyBalances {
    init(response: BalanceResponse, enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        let balances = response.currencies
            .compactMap { entry -> DelegatedCustodyBalances.Balance? in
                guard let currency = CryptoCurrency(
                    code: entry.ticker,
                    service: enabledCurrenciesService
                ) else {
                    return nil
                }
                let balance: MoneyValue? = entry.amount.flatMap { amount in
                    MoneyValue.create(
                        minor: amount.amount,
                        currency: .crypto(currency)
                    )
                }
                return Balance(
                    index: entry.account.index,
                    name: entry.account.name ?? "",
                    balance: balance ?? .zero(currency: currency)
                )
            }
        let networks = response.networks.compactMap { entry -> DelegatedCustodyBalances.Network? in
            guard let currency = CryptoCurrency(
                code: entry.ticker,
                service: enabledCurrenciesService
            ) else {
                return nil
            }
            return Network(currency: currency, errorLoadingBalances: entry.errorLoadingBalances)
        }
        self.init(balances: balances, networks: networks)
    }
}
