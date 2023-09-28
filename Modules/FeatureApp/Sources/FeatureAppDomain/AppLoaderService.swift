// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import FeatureExternalTradingMigrationDomain
import FeatureProductsDomain
import Foundation

public class AppLoaderService: ObservableObject {
    private let productsService: ProductsServiceAPI
    private let externalTradingMigrationService: ExternalTradingMigrationServiceAPI
    private let app: AppProtocol

    public init(
        productsService: ProductsServiceAPI = resolve(),
        externalTradingMigrationService: ExternalTradingMigrationServiceAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.productsService = productsService
        self.app = app
        self.externalTradingMigrationService = externalTradingMigrationService
    }

    public func loadAppDependencies() async throws -> Bool {
        do {
            async let fetchProducts = productsService.fetchProducts().await()
            async let fetchMigrationInfo = externalTradingMigrationService.fetchMigrationInfo()
            let _ : [Any?] = try await [fetchProducts, fetchMigrationInfo]
            return true
        }
        catch let error {
            app.post(error: error)
            return true
        }
    }
}
