// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol ProductsRepositoryAPI {

    func fetchProducts() -> AnyPublisher<Set<ProductValue>, NabuNetworkError>
    func streamProducts() -> AnyPublisher<Result<Set<ProductValue>, NabuNetworkError>, Never>
}
