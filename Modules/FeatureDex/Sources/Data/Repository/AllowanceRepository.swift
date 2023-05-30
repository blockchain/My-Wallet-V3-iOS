// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Dependencies
import DIKit
import Errors
import FeatureDexDomain
import MoneyKit
import ToolKit

final class DexAllowanceRepository: DexAllowanceRepositoryAPI {

    private struct Key: Hashable {
        let address: String
        let currency: CryptoCurrency
    }

    private let currenciesService: EnabledCurrenciesServiceAPI
    private let client: AllowanceClientAPI
    private let cache: CachedValueNew<Key, DexAllowanceOutput, Error>

    init(
        client: AllowanceClientAPI,
        currenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.client = client
        self.currenciesService = currenciesService

        self.cache = CachedValueNew(
            cache: InMemoryCache(
                configuration: .onLoginLogoutTransaction(),
                refreshControl: PeriodicCacheRefreshControl(refreshInterval: 3)
            ).eraseToAnyCache(),
            fetch: { [client, currenciesService] key in
                Self.makeRequest(client, currenciesService, key)
            }
        )
    }

    func fetch(address: String, currency: CryptoCurrency) -> AnyPublisher<DexAllowanceOutput, Error> {
        cache.get(key: Key(address: address, currency: currency))
    }

    func poll(address: String, currency: CryptoCurrency) -> AnyPublisher<DexAllowanceOutput, Error> {
        Deferred { [client, currenciesService] in
            Self.makeRequest(client, currenciesService, Key(address: address, currency: currency))
        }
        .poll(
            until: \.isOK,
            delay: .seconds(5)
        )
    }

    private static func request(with key: Key, service: EnabledCurrenciesServiceAPI) -> DexAllowanceRequest {
        let network = service.network(for: key.currency)
        return DexAllowanceRequest(
            addressOwner: key.address,
            currency: key.currency.assetModel.kind.erc20ContractAddress ?? Constants.nativeAssetAddress,
            network: network?.networkConfig.networkTicker ?? ""
        )
    }

    private static func output(with key: Key, _ response: DexAllowanceResponse) -> DexAllowanceOutput {
        DexAllowanceOutput(
            currency: key.currency,
            address: key.address,
            allowance: response.result.allowance
        )
    }

    private static func makeRequest(
        _ client: AllowanceClientAPI,
        _ currenciesService: EnabledCurrenciesServiceAPI,
        _ key: Key
    ) -> AnyPublisher<DexAllowanceOutput, Error> {
        client
            .allowance(request: request(with: key, service: currenciesService))
            .map { response in
                output(with: key, response)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }
}

public struct DexAllowanceRepositoryDependencyKey: DependencyKey {
    public static var liveValue: DexAllowanceRepositoryAPI = DexAllowanceRepository(
        client: Client(
            networkAdapter: DIKit.resolve(),
            requestBuilder: DIKit.resolve()
        ),
        currenciesService: DIKit.resolve()
    )

    public static var previewValue: DexAllowanceRepositoryAPI = DexAllowanceRepositoryPreview(allowance: "1")

    public static var testValue: DexAllowanceRepositoryAPI { previewValue }

    public static var noAllowance: DexAllowanceRepositoryAPI = DexAllowanceRepositoryPreview(allowance: "0")
}

extension DependencyValues {
    public var dexAllowanceRepository: DexAllowanceRepositoryAPI {
        get { self[DexAllowanceRepositoryDependencyKey.self] }
        set { self[DexAllowanceRepositoryDependencyKey.self] = newValue }
    }
}

final class DexAllowanceRepositoryPreview: DexAllowanceRepositoryAPI {

    let allowance: String

    init(allowance: String) {
        self.allowance = allowance
    }

    func fetch(
        address: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<DexAllowanceOutput, Error> {
        .just(DexAllowanceOutput(currency: currency, address: address, allowance: allowance))
    }

    func poll(address: String, currency: CryptoCurrency) -> AnyPublisher<DexAllowanceOutput, Error> {
        .just(DexAllowanceOutput(currency: currency, address: address, allowance: allowance))
    }
}
