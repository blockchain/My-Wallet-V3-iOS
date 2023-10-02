// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import DIKit
import Foundation

public final class ExternalTradingMigrationRepository {
    let client: ExternalTradingMigrationClientAPI
    unowned let app: AppProtocol

    public init(
        client: ExternalTradingMigrationClientAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.client = client
        self.app = app
    }

    public func register() async throws {
        try await app.register(
            napi: blockchain.api.nabu.gateway.user,
            domain: blockchain.api.nabu.gateway.user.external.brokerage.migration,
            repository: { _ in
                do {
                    let storedCache = try? await self.app.get(blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state, as: Tag.self)
                    guard let storedCache,
                          storedCache.migrationComplete
                    else {
                        let apiResponse = try? await self.client.fetchMigrationInfo().await()

                        if let state = apiResponse?.state.rawValue {
                            try await self.app.set(blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state, to: blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state[][state.lowercased()])
                        }

                        return AnyJSON(apiResponse)
                    }

                    return .empty
                } catch {
                    print(error)
                    return AnyJSON(error)
                }
            }
        )
    }
}

extension Tag {
    fileprivate var migrationComplete: Bool {
        self == blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state.not_available
        ||
        self == blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state.complete
    }
}
