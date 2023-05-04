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
                client
                    .allowance(request: Self.request(with: key, service: currenciesService))
                    .map { response in
                        Self.output(with: key, response)
                    }
                    .eraseError()
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetch(address: String, currency: CryptoCurrency) -> AnyPublisher<DexAllowanceOutput, Error> {
        cache.get(key: Key(address: address, currency: currency))
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
}

struct DexAllowanceRepositoryDependencyKey: DependencyKey {
    static var liveValue: DexAllowanceRepositoryAPI = DexAllowanceRepository(
        client: Client(
            networkAdapter: DIKit.resolve(),
            requestBuilder: DIKit.resolve()
        ),
        currenciesService: DIKit.resolve()
    )

    static var previewValue: DexAllowanceRepositoryAPI = DexAllowanceRepositoryPreview()

    static var testValue: DexAllowanceRepositoryAPI { previewValue }
}

extension DependencyValues {
    public var dexAllowanceRepository: DexAllowanceRepositoryAPI {
        get { self[DexAllowanceRepositoryDependencyKey.self] }
        set { self[DexAllowanceRepositoryDependencyKey.self] = newValue }
    }
}

fileprivate final class DexAllowanceRepositoryPreview: DexAllowanceRepositoryAPI {
    func fetch(
        address: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<DexAllowanceOutput, Error> {
        .just(DexAllowanceOutput(currency: currency, address: address, allowance: "1"))
    }
}
