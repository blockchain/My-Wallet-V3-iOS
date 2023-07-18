// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ERC20Kit
import EthereumKit
import MoneyKit
import PlatformKit
import ToolKit

/// A repository in charge of getting ERC-20 token accounts associated with a given ethereum account address, providing value caching.
final class ERC20BalancesRepository: ERC20BalancesRepositoryAPI {

    // MARK: - Internal Types

    /// An ERC-20 token accounts key, used as cache index and network request parameter.
    struct ERC20TokenAccountsKey: Hashable {

        /// EVM account public key.
        let address: String
        /// EVM network.
        let network: EVMNetworkConfig
    }

    // MARK: - Private Properties

    private let cachedValue: CachedValueNew<
        ERC20TokenAccountsKey,
        ERC20TokenAccounts,
        Error
    >

    // MARK: - Setup

    /// Creates an ERC-20 token accounts repository, with a preset cache that flushes on logout and has a 90 seconds refresh interval.
    ///
    /// - Parameters:
    ///   - client:                   An ERC-20 account client.
    ///   - enabledCurrenciesService: An enabled currencies service.
    convenience init(
        client: ERC20BalancesClientAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        let refreshControl = PeriodicCacheRefreshControl(refreshInterval: 60)
        let cache = InMemoryCache<ERC20TokenAccountsKey, ERC20TokenAccounts>(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: refreshControl
        )
        .eraseToAnyCache()

        self.init(client: client, cache: cache, enabledCurrenciesService: enabledCurrenciesService)
    }

    /// Creates an ERC-20 token accounts repository.
    ///
    /// - Parameters:
    ///   - client:                   An ERC-20 account client.
    ///   - cache:                    A cache.
    ///   - enabledCurrenciesService: An enabled currencies service.
    init(
        client: ERC20BalancesClientAPI,
        cache: AnyCache<ERC20TokenAccountsKey, ERC20TokenAccounts>,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        let mapper = ERC20TokenAccountsMapper(enabledCurrenciesService: enabledCurrenciesService)

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { key -> AnyPublisher<ERC20TokenAccounts, Error> in
                switch key.network {
                case .ethereum:
                    return Deferred {
                        client.ethereumTokensBalances(for: key.address)
                    }
                    .retry(1)
                    .map(mapper.toDomain)
                    .eraseError()
                    .eraseToAnyPublisher()
                default:
                    return Deferred {
                        client.evmTokensBalances(for: key.address, network: key.network)
                    }
                    .retry(1)
                    .map { response -> EVMBalancesResponse.Item? in
                        response
                            .results
                            .first(where: {
                                $0.address.caseInsensitiveCompare(key.address) == .orderedSame
                            })
                    }
                    .map { $0?.balances ?? [] }
                    .map(mapper.toDomain)
                    .eraseError()
                    .eraseToAnyPublisher()
                }
            }
        )
    }

    // MARK: - Internal Methods

    func tokens(
        for address: String,
        network: EVMNetworkConfig,
        forceFetch: Bool
    ) -> AnyPublisher<ERC20TokenAccounts, Error> {
        cachedValue.get(
            key: createKey(address: address, network: network),
            forceFetch: forceFetch
        )
    }

    private func createKey(
        address: String,
        network: EVMNetworkConfig
    ) -> ERC20TokenAccountsKey {
        ERC20TokenAccountsKey(address: address.lowercased(), network: network)
    }
}
