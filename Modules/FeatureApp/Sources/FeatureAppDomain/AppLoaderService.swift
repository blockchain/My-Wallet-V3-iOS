// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import FeatureExternalTradingMigrationDomain
import FeatureProductsDomain
import Foundation

enum AppLoaderServiceError: Error {
    case userIsBlocked
}

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
            try await load()
            return true
        }
        catch {
            app.post(error: error)
            return false
        }
    }

    private func load() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                for await isBlocked in self.app.stream(blockchain.user.is.blocked, as: Bool.self) {
                    guard let isBlocked = isBlocked.value else { continue }
                    if isBlocked {
                        throw AppLoaderServiceError.userIsBlocked
                    } else {
                        return
                    }
                }
            }

            group.addTask {
                async let fetchProducts = self.productsService.fetchProducts().await()
                async let fetchMigrationInfo = self.externalTradingMigrationService.fetchMigrationInfo()
                let _: [Any?] = try await [fetchProducts, fetchMigrationInfo]
            }
            
            try await group.waitForAll()
        }
    }
}
