//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import FeatureProductsDomain
import DIKit

public class AppLoaderService: ObservableObject {
    private let productsService: ProductsServiceAPI

    public init(
        productsService: ProductsServiceAPI = resolve()
    ) {
        self.productsService = productsService
    }

    public func loadAppDependencies() async throws -> Bool {
        let _ = try await productsService.fetchProducts().await()
        return true
    }
}
