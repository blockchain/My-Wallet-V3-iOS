// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Dependencies
import FeatureDexDomain
import MoneyKit
import NetworkKit
import ToolKit

public protocol AvailableChainsServiceAPI {
    func availableChains() -> AnyPublisher<[Chain], NetworkError>
    func availableEvmChains() -> AnyPublisher<[EVMNetwork], UX.Error>
}

final class AvailableChainsService: AvailableChainsServiceAPI {

    private struct Key: Hashable {}

    @Dependency(\.chainsClient) var client
    private let currenciesService: EnabledCurrenciesServiceAPI
    private lazy var cache: CachedValueNew<Key, [Chain], NetworkError> = CachedValueNew(
        cache: InMemoryCache(
            configuration: .default(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache(),
        fetch: { [client] _ in
            client.chains()
        }
    )

    init(currenciesService: EnabledCurrenciesServiceAPI) {
        self.currenciesService = currenciesService
    }

    func availableChains() -> AnyPublisher<[Chain], NetworkError> {
        cache.get(key: Key())
    }

    func availableEvmChains() -> AnyPublisher<[EVMNetwork], UX.Error> {
        availableChains()
            .map { [currenciesService] chains -> [EVMNetwork] in
                chains.compactMap { chain -> EVMNetwork? in
                    currenciesService
                        .allEnabledEVMNetworks
                        .first(where: { $0.networkConfig.chainID == chain.chainId })
                }
            }
            .mapError(UX.Error.init(error:))
            .eraseToAnyPublisher()
    }
}

public struct AvailableChainsServiceAPIDependencyKey: DependencyKey {
    public static var liveValue: AvailableChainsServiceAPI = AvailableChainsService(
        currenciesService: EnabledCurrenciesService.default
    )

    public static var previewValue: AvailableChainsServiceAPI = AvailableChainsService(
        currenciesService: EnabledCurrenciesService.default
    )

    public static var testValue: AvailableChainsServiceAPI = AvailableChainsService(
        currenciesService: EnabledCurrenciesService.default
    )
}

extension DependencyValues {
    public var availableChainsService: AvailableChainsServiceAPI {
        get { self[AvailableChainsServiceAPIDependencyKey.self] }
        set { self[AvailableChainsServiceAPIDependencyKey.self] = newValue }
    }
}
