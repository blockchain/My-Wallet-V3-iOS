// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import BlockchainUI
import FeatureProductsDomain
import Foundation

public class AppLoaderService: ObservableObject {
    private let productsService: ProductsServiceAPI
    private let app: AppProtocol

    public init(
        productsService: ProductsServiceAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.productsService = productsService
        self.app = app
    }

    public func loadAppDependencies() async throws -> Bool {
        do {
            try await productsService.fetchProducts().await()
            return true
        }
        catch let error {
            app.post(error: error)
            return true
        }
    }
}
