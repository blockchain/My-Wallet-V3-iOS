// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureProductsDomain
import Foundation

public class AppLoaderService: ObservableObject {
    private let productsService: ProductsServiceAPI

    public init(
        productsService: ProductsServiceAPI = resolve()
    ) {
        self.productsService = productsService
    }

    public func loadAppDependencies() async throws -> Bool {
        _ = try await productsService.fetchProducts().await()
        return true
    }
}
