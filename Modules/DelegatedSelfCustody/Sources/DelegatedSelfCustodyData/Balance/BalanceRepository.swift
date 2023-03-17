// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import MoneyKit
import ToolKit

final class BalanceRepository: DelegatedCustodyBalanceRepositoryAPI {

    private struct Key: Hashable {}

    var app: AppProtocol

    var balances: AnyPublisher<DelegatedCustodyBalances, Error> {
        cachedValue.get(key: Key())
    }

    private let client: AccountDataClientAPI
    private let authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: DelegatedCustodyFiatCurrencyServiceAPI
    private let cachedValue: CachedValueNew<
        Key,
        DelegatedCustodyBalances,
        Error
    >

    init(
        app: AppProtocol,
        client: AccountDataClientAPI,
        authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        fiatCurrencyService: DelegatedCustodyFiatCurrencyServiceAPI
    ) {
        self.app = app
        self.client = client
        self.authenticationDataRepository = authenticationDataRepository
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService

        let cache: AnyCache<Key, DelegatedCustodyBalances> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 120)
        ).eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [authenticationDataRepository, fiatCurrencyService, client, enabledCurrenciesService] _ in
                authenticationDataRepository.authenticationData
                    .eraseError()
                    .combineLatest(fiatCurrencyService.fiatCurrency.eraseError())
                    .flatMap { [client] authenticationData, fiatCurrency in
                        client.balance(
                            guidHash: authenticationData.guidHash,
                            sharedKeyHash: authenticationData.sharedKeyHash,
                            fiatCurrency: fiatCurrency,
                            currencies: nil
                        )
                        .eraseError()
                    }
                    .map { [enabledCurrenciesService] response in
                        DelegatedCustodyBalances(
                            response: response,
                            enabledCurrenciesService: enabledCurrenciesService
                        )
                    }
                    .handleEvents(receiveOutput: { balances in
                        Task {
                            try await app.batch(
                                updates: buildEvents(balances)
                            )
                        }
                    })
                    .eraseToAnyPublisher()
            }
        )
    }
}

private func buildEvents(_ balances: DelegatedCustodyBalances) -> [(any Tag.Event, Any?)] {
    typealias Account = (total: MoneyValue, wallets: [String: MoneyValue])

    let accounts = balances.balances
        .reduce(into: [String: Account]()) { result, balance in
            let code = balance.currency.code
            var account = result[code] ?? (total: .zero(currency: balance.currency), wallets: [:])

            guard let total = try? account.total + balance.balance else {
                return
            }

            account.total = total
            account.wallets[String(balance.index)] = balance.balance

            result[balance.currency.code] = account
        }

    let events = accounts
        .map { (code, account) -> [(any Tag.Event, Any?)] in
            [
                (blockchain.user.pkw.asset[code].balance.amount, account.total.storeAmount),
                (blockchain.user.pkw.asset[code].balance.currency, account.total.currency.code),
                (blockchain.user.pkw.asset[code].ids, Array(account.wallets.keys))
            ]
            + account
                .wallets
                .map { (id, balance) -> [(any Tag.Event, Any?)] in
                    [
                        (blockchain.user.pkw.asset[code].wallet[id].balance.amount, balance.storeAmount),
                        (blockchain.user.pkw.asset[code].wallet[id].balance.currency, balance.currency.code)
                    ]
                }
                .flatMap { $0 }
        }
        .flatMap { $0 }

    return events + [(blockchain.user.pkw.currencies, Array(accounts.keys))]
}
