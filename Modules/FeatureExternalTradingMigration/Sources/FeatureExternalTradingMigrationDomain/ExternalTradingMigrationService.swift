// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation

public protocol ExternalTradingMigrationServiceAPI {
    func fetchMigrationInfo() async throws -> ExternalTradingMigrationInfo?
    func startMigration() async throws
}

public final class ExternalTradingMigrationService: ExternalTradingMigrationServiceAPI, ObservableObject {
    private let repository: ExternalTradingMigrationRepositoryAPI
    private let app: AppProtocol

    public init(
        app: AppProtocol,
        repository: ExternalTradingMigrationRepositoryAPI
    ) {
        self.repository = repository
        self.app = app
    }

    public func fetchMigrationInfo() async throws -> ExternalTradingMigrationInfo? {
        let lastKnownState = try? await app.get(blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state, as: Tag.self)

        if let lastKnownState, lastKnownState.migrationComplete {
            return nil
        }

        let response = try await repository.fetchMigrationInfo()

        try await app.set(blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state, to: blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state[][response.state.rawValue.lowercased()])

        return response
    }

    public func startMigration() async throws {
        try await repository.startMigration()
    }
}

extension Tag {
    fileprivate var migrationComplete: Bool {
        self == blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state.not_available
        ||
        self == blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state.complete
    }
}
