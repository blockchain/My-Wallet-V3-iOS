// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import NetworkKit
import ToolKit

protocol FeesRepositoryAPI {
    var fees: AnyPublisher<StellarTransactionFee, Never> { get }
}

final class FeesRepository: FeesRepositoryAPI {

    private struct Key: Hashable {}

    private let client: FeesClientAPI
    private let cachedValue: CachedValueNew<
        Key,
        FeeResponse,
        NetworkError
    >

    var fees: AnyPublisher<StellarTransactionFee, Never> {
        cachedValue.get(key: Key())
            .map { StellarTransactionFee(regular: $0.regular, priority: $0.priority) }
            .replaceError(with: StellarTransactionFee.default)
            .eraseToAnyPublisher()
    }

    init(client: FeesClientAPI) {
        self.client = client

        let feeCache = InMemoryCache<Key, FeeResponse>(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: .minutes(1))
        )
        .eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: feeCache,
            fetch: { [client] _ in
                client.fees
            }
        )
    }
}

struct FeeResponse: Decodable, Hashable {
    let regular: Int
    let priority: Int
}

protocol FeesClientAPI {
    var fees: AnyPublisher<FeeResponse, NetworkError> { get }
}

final class FeesClient: FeesClientAPI {
    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    var fees: AnyPublisher<FeeResponse, NetworkError> {
        networkAdapter
            .perform(request: requestBuilder.get(path: "/mempool/fees/xlm")!)
    }

    init(networkAdapter: NetworkAdapterAPI, requestBuilder: RequestBuilder) {
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
    }
}
