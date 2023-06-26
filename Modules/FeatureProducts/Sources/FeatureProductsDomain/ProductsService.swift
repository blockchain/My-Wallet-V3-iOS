// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import ToolKit

public enum ProductsServiceError: Error, Equatable {
    case network(NabuNetworkError)
}

public protocol ProductsServiceAPI {

    func fetchProducts() -> AnyPublisher<Set<ProductValue>, ProductsServiceError>
    func streamProducts() -> AnyPublisher<Result<Set<ProductValue>, ProductsServiceError>, Never>
}

public final class ProductsService: ProductsServiceAPI {

    private let repository: ProductsRepositoryAPI

    public init(
        repository: ProductsRepositoryAPI
    ) {
        self.repository = repository
    }

    public func fetchProducts() -> AnyPublisher<Set<ProductValue>, ProductsServiceError> {
        repository.fetchProducts()
            .mapError(ProductsServiceError.network)
            .eraseToAnyPublisher()
    }

    public func streamProducts() -> AnyPublisher<Result<Set<ProductValue>, ProductsServiceError>, Never> {
        repository.streamProducts()
            .map { result in result.mapError(ProductsServiceError.network) }
            .eraseToAnyPublisher()
    }
}
