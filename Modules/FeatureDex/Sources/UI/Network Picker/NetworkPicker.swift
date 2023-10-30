// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import FeatureDexDomain
import Foundation
import MoneyKit

public struct NetworkPicker: Reducer {
    @Dependency(\.dexService) var dexService
    @Dependency(\.mainQueue) var mainQueue

    public struct State: Equatable {
        init(currentNetwork: String? = nil) {
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

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .publisher {
                    dexService.availableChainsService
                        .availableEvmChains()
                        .replaceError(with: [])
                        .receive(on: mainQueue)
                        .map(Action.onAvailableNetworksFetched)
                }
            case .onAvailableNetworksFetched(let networks):
                state.availableNetworks = networks
                return .none
            case .onNetworkSelected(let network):
                state.currentNetwork = network.networkConfig.networkTicker
                return .none
            case .onDismiss:
                return .none
            }
        }
    }
}
