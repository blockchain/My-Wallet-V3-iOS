// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import FeatureDexDomain
import Foundation
import MoneyKit

public struct NetworkPicker: ReducerProtocol {
    @Dependency(\.dexService) var dexService
    @Dependency(\.app) var app

    private var tag = blockchain.ux.currency.exchange.dex.network.picker

    public struct State: Equatable {
        public init(currentNetwork: String? = nil) {
            self.currentNetwork = currentNetwork
        }
        var availableNetworks: [EVMNetwork] = []
        var currentNetwork: String?
    }

    public enum Action: Equatable {
        case onAppear
        case onNetworkSelected(EVMNetwork)
        case onDismiss
        case onAvailableNetworksFetched([EVMNetwork])
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return dexService.availableNetworks()
                    .map(\.success)
                    .replaceNil(with: [])
                    .eraseToEffect(Action.onAvailableNetworksFetched)

            case .onAvailableNetworksFetched(let networks):
                state.availableNetworks = networks
                return .none

            case .onNetworkSelected(let network):
                state.currentNetwork = network.networkConfig.networkTicker
                return .run { _ in
                    try await app.set(
                        tag.selected.network.ticker,
                        to: network.networkConfig.networkTicker
                    )
                    try await app.set(
                        tag.selected.network.ticker.entry.paragraph.row.tap.then.close,
                        to: true
                    )
                    app.post(
                        event: tag.selected.network.ticker.entry.paragraph.row.tap
                    )
                }
            case .onDismiss:
                return .run { _ in
                    try await app.set(
                        tag.selected.network.ticker.article.plain.navigation.bar.button.close.tap.then.close,
                        to: true
                    )
                    app.post(event: tag.selected.network.ticker.article.plain.navigation.bar.button.close.tap)
                }
            }
        }
    }
}
