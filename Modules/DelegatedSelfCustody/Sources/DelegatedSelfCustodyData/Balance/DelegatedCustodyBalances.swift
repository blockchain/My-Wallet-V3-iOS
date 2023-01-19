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
                    enabledCurrenciesService: enabledCurrenciesService
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
                    name: entry.account.name,
                    balance: balance ?? .zero(currency: currency)
                )
            }
        self.init(balances: balances)
    }
}
