//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ComposableArchitecture
import MoneyKit

public struct NetworkPicker: ReducerProtocol {
    public struct State: Equatable {
        var availableNetworks: [EVMNetwork] = [EVMNetwork.init(networkConfig: .ethereum, nativeAsset: .ethereum),
                                                EVMNetwork.init(networkConfig: .bitcoin, nativeAsset: .bitcoin)]
        var selectedNetwork: EVMNetwork? = EVMNetwork.init(networkConfig: .bitcoin, nativeAsset: .bitcoin)
    }

    public enum Action: Equatable {
        case onNetworkSelected(EVMNetwork)
        case onDismiss
    }

    public var body: some ReducerProtocol<State,Action> {
        Reduce { state, action in
            switch action {
            case .onNetworkSelected:
                return .none
            case .onDismiss:
                return .none
            }
        }
    }
}
