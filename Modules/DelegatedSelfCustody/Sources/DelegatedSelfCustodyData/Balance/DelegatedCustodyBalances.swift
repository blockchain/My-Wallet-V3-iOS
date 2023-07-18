// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DelegatedSelfCustodyDomain
import MoneyKit

extension DelegatedCustodyBalances {
    init(
        response: BalanceResponse,
        fiatCurrency: FiatCurrency,
        mock: UnifiedBalanceMockConfig?,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        var balances = response.currencies
            .compactMap { entry -> DelegatedCustodyBalances.Balance? in
                guard let currency = CryptoCurrency(
                    code: entry.ticker,
                    service: enabledCurrenciesService
                ) else {
                    return nil
                }
                let balance: CryptoValue? = entry.amount
                    .flatMap { CryptoValue.create(minor: $0.amount, currency: currency) }

                let fiatBalance: FiatValue? = entry.price
                    .flatMap { FiatValue.create(major: "\($0)", currency: fiatCurrency) }
                    .flatMap { balance?.convert(using: $0) }

                return Balance(
                    index: entry.account.index,
                    name: entry.account.name ?? "",
                    balance: balance?.moneyValue ?? MoneyValue.zero(currency: currency),
                    fiatBalance: fiatBalance?.moneyValue
                )
            }
        if let mock = mockBalance(mock, enabledCurrenciesService) {
            balances.append(mock)
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
        let sorted = balances.sorted(by: { lhs, rhs in
            switch (lhs.fiatBalance, rhs.fiatBalance) {
            case (.none, .none):
                return false
            case (.none, .some):
                return false
            case (.some, .none):
                return true
            case (.some(let lhs), .some(let rhs)):
                return (try? lhs > rhs) ?? false
            }
        })
        self.init(
            balances: sorted,
            networks: networks
        )
    }
}

private func mockBalance(
    _ value: UnifiedBalanceMockConfig?,
    _ service: EnabledCurrenciesServiceAPI
) -> DelegatedCustodyBalances.Balance? {
    guard
        let value,
        let currency = CryptoCurrency(code: value.code, service: service) else {
        return nil
    }
    return DelegatedCustodyBalances.Balance(
        index: 0,
        name: "(Mock) DeFi Wallet",
        balance: .create(majorBigInt: 123, currency: .crypto(currency)),
        fiatBalance: nil
    )
}
