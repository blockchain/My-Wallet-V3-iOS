// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Foundation
import MoneyKit
import ToolKit

protocol AccountRepositoryAPI: DelegatedCustodyAccountRepositoryAPI {

    var accounts: AnyPublisher<[Account], Error> { get }
}

final class AccountRepository: AccountRepositoryAPI {

    private struct Key: Hashable {}

    private let assetSupportService: AssetSupportService
    private let derivationService: DelegatedCustodyDerivationServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let cachedValue: CachedValueNew<Key, [Account], Error>

    init(
        assetSupportService: AssetSupportService,
        derivationService: DelegatedCustodyDerivationServiceAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.assetSupportService = assetSupportService
        self.derivationService = derivationService
        self.enabledCurrenciesService = enabledCurrenciesService

        let cache: AnyCache<Key, [Account]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                assetSupportService
                    .supportedDerivations()
                    .flatMap { supportedAssets -> AnyPublisher<[Account], Error> in
                        supportedAssets
                            .compactMap { asset -> AnyPublisher<Account, Error>? in
                                guard let cryptoCurrency = CryptoCurrency(
                                    code: asset.currencyCode,
                                    service: enabledCurrenciesService
                                ) else {
                                    return nil
                                }
                                return derivationService.getKeys(path: asset.derivationPath)
                                    .map { keys in
                                        Account(
                                            coin: cryptoCurrency,
                                            derivationPath: asset.derivationPath,
                                            style: asset.style,
                                            publicKey: keys.publicKey,
                                            privateKey: keys.privateKey
                                        )
                                    }
                                    .eraseToAnyPublisher()
                            }
                            .zip()
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    var accounts: AnyPublisher<[Account], Error> {
        cachedValue.get(key: Key())
    }

    var delegatedCustodyAccounts: AnyPublisher<[DelegatedCustodyAccount], Error> {
        cachedValue.get(key: Key())
            .map { accounts -> [DelegatedCustodyAccount] in
                accounts
            }
            .eraseToAnyPublisher()
    }
}
