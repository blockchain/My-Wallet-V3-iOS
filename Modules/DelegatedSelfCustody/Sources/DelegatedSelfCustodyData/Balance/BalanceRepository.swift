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
                    .handleEvents(receiveOutput: { result in
                        Task {
                            try await app.batch(
                                updates: result.balances.map { balance -> [(any Tag.Event, Any?)] in
                                    [
                                        (blockchain.user.pkw[balance.currency.code].balance.amount, balance.balance.storeAmount),
                                        (blockchain.user.pkw[balance.currency.code].balance.currency, balance.currency.code)
                                    ]
                                }
                                .flatMap { $0 }
                            )
                        }
                    })
                    .eraseToAnyPublisher()
            }
        )
    }
}
