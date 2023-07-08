// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import Extensions
import MoneyKit
import ToolKit

final class BalanceRepository: DelegatedCustodyBalanceRepositoryAPI {

    private struct Key: Hashable {}

    var app: AppProtocol

    var balances: AnyPublisher<DelegatedCustodyBalances, Error> {
        cachedValue.get(key: Key())
    }

    var balancesStream: AnyPublisher<Result<DelegatedCustodyBalances, Error>, Never> {
        cachedValue.stream(key: Key())
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
                    .combineLatest(
                        fiatCurrencyService.fiatCurrency.eraseError(),
                        unifiedBalanceMock(app: app).eraseError()
                    )
                    .flatMap { [client, enabledCurrenciesService] authenticationData, fiatCurrency, unifiedBalanceMock in
                        client.balance(
                            guidHash: authenticationData.guidHash,
                            sharedKeyHash: authenticationData.sharedKeyHash,
                            fiatCurrency: fiatCurrency,
                            currencies: nil
                        )
                        .map { [enabledCurrenciesService] response in
                            DelegatedCustodyBalances(
                                response: response,
                                fiatCurrency: fiatCurrency,
                                mock: unifiedBalanceMock,
                                enabledCurrenciesService: enabledCurrenciesService
                            )
                        }
                        .eraseError()
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

struct UnifiedBalanceMockConfig: Codable, Hashable {
    let code: String
}

private func unifiedBalanceMock(app: AppProtocol) -> AnyPublisher<UnifiedBalanceMockConfig?, Never> {
    var isEnabled: AnyPublisher<Bool, Never> {
        app.publisher(
            for: blockchain.app.configuration.unified.balances.mock.is.enabled,
            as: Bool.self
        )
        .map(\.value)
        .replaceNil(with: false)
        .prefix(1)
        .eraseToAnyPublisher()
    }
    var config: AnyPublisher<UnifiedBalanceMockConfig?, Never> {
        app.publisher(
            for: blockchain.app.configuration.unified.balances.mock.config,
            as: UnifiedBalanceMockConfig.self
        )
        .map(\.value)
        .prefix(1)
        .eraseToAnyPublisher()
    }
    guard BuildFlag.isInternal  else {
        return .just(nil)
    }
    return isEnabled.flatMapIf(then: config, else: .just(nil))
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
        .map { code, account -> [(any Tag.Event, Any?)] in
            [
                (blockchain.user.pkw.asset[code].balance.amount, account.total.storeAmount),
                (blockchain.user.pkw.asset[code].balance.currency, account.total.currency.code),
                (blockchain.user.pkw.asset[code].ids, Array(account.wallets.keys))
            ]
            + account
                .wallets
                .map { id, balance -> [(any Tag.Event, Any?)] in
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
