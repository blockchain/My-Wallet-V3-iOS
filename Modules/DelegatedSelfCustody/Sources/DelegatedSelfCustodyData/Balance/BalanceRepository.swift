// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import MoneyKit
import ToolKit

final class BalanceRepository: DelegatedCustodyBalanceRepositoryAPI {

    private struct Key: Hashable {}

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
        client: AccountDataClientAPI,
        authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        fiatCurrencyService: DelegatedCustodyFiatCurrencyServiceAPI
    ) {
        self.client = client
        self.authenticationDataRepository = authenticationDataRepository
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService

        let cache: AnyCache<Key, DelegatedCustodyBalances> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 180)
        ).eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [authenticationDataRepository, fiatCurrencyService, client, enabledCurrenciesService] _ in
                authenticationDataRepository.authenticationData
                    .eraseError()
                    .zip(fiatCurrencyService.fiatCurrency.eraseError())
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
                        DelegatedCustodyBalances(response: response, enabledCurrenciesService: enabledCurrenciesService)
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
}
