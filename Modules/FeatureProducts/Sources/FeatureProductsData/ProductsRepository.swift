// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import Errors
import FeatureProductsDomain
import ToolKit

public final class ProductsRepository: ProductsRepositoryAPI {

    private enum CacheKey: Hashable {
        case products
    }

    private let cachedProducts: CachedValueNew<CacheKey, Set<ProductValue>, NabuNetworkError>

    public init(app: AppProtocol, client: ProductsClientAPI) {
        let cache: AnyCache<CacheKey, Set<ProductValue>> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        self.cachedProducts = CachedValueNew(
            cache: cache,
            fetch: { [app] _ in
                app.publisher(for: blockchain.user.is.external.brokerage, as: Bool.self)
                    .compactMap(\.value)
                    .flatMap { isExternalTrading -> AnyPublisher<Set<ProductValue>, Nabu.Error> in
                        client
                            .fetchProductsData(product: isExternalTrading ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY")
                            .map { $0.values.compacted().set }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    public func fetchProducts() -> AnyPublisher<Set<ProductValue>, Nabu.Error> {
        cachedProducts.get(key: CacheKey.products)
    }

    public func streamProducts() -> AnyPublisher<Result<Set<ProductValue>, Nabu.Error>, Never> {
        cachedProducts.stream(key: CacheKey.products)
    }
}
