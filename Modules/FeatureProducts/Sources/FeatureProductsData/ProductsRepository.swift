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
                    .compactMap { result in
                        switch result {
                        case .value(let value, _):
                            return value
                        case .error(let error, _):
                            app.post(error: error)
                            if  case FetchResult.Error.keyDoesNotExist = error {
                                return nil
                            }
                            return false
                        }
                    }
                    .flatMap { isExternalTrading -> AnyPublisher<Set<ProductValue>, Nabu.Error> in
                        app.post(
                            event: blockchain.app.will.fetch.products,
                            context: [blockchain.user.is.external.brokerage: isExternalTrading]
                        )
                        return client
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
