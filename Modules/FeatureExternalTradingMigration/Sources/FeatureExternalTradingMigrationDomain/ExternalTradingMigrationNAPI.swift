// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import DIKit
import Foundation

public final class ExternalTradingMigrationNAPI {
    let service: ExternalTradingMigrationServiceAPI
    unowned let app: AppProtocol

    public init(
        service: ExternalTradingMigrationServiceAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.service = service
        self.app = app
    }
    

    public func register() async throws {
        var refresh = L_blockchain_namespace_napi_napi_policy.JSON()
        refresh.invalidate.on = [
            blockchain.user.event.did.update[]
        ]

        try await app.register(
            napi: blockchain.api.nabu.gateway.user,
            domain: blockchain.api.nabu.gateway.user.external.brokerage.migration,
            policy: refresh,
            repository: { [app, service] _ in
                var json = L_blockchain_api_nabu_gateway_user_external_brokerage_migration.JSON()
                if let response = try? await service.fetchMigrationInfo() {
                    json.state = blockchain.api.nabu.gateway.user.external.brokerage.migration.state[][response.state.rawValue.lowercased()]
                } else {
                    json.state = try? await app.get(blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state, as: Tag.self)

                    let state =  try? await app.get(blockchain.api.nabu.gateway.user.external.brokerage.migration.last.known.state, as: Tag.self)
                }

                return json.toJSON()
            }
        )
    }
}
