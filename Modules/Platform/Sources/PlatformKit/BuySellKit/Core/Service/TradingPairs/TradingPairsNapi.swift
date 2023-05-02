// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import Foundation

public final class TradingPairsNAPI {
    let client: TradingPairsClientAPI
    unowned let app: AppProtocol

    public init(
        client: TradingPairsClientAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.client = client
        self.app = app
    }

    public func register() async throws {
        try await app.register(
            napi: blockchain.api.nabu.gateway.trading,
            domain: blockchain.api.nabu.gateway.trading.swap.pairs,
            repository: { _ in
                self.client.tradingPairs()
                    .map(AnyJSON.init)
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
            }
        )
    }
}
