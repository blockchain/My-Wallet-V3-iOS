// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProductsDomain
import ToolKit

public final class ProductsRepository: ProductsRepositoryAPI {

    private enum CacheKey: Hashable {
        case products
    }

    private let cachedProducts: CachedValueNew<CacheKey, Set<ProductValue>, NabuNetworkError>

    public init(client: ProductsClientAPI) {
        let cache: AnyCache<CacheKey, Set<ProductValue>> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        self.cachedProducts = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client
                    .fetchProductsData()
                    .map { $0.values.compacted().set }
                    .eraseToAnyPublisher()
            }
        )
    }

    public func fetchProducts() -> AnyPublisher<Set<ProductValue>, NabuNetworkError> {
        cachedProducts.get(key: CacheKey.products)
    }

    public func streamProducts() -> AnyPublisher<Result<Set<ProductValue>, NabuNetworkError>, Never> {
        cachedProducts.stream(key: CacheKey.products)
    }
}
