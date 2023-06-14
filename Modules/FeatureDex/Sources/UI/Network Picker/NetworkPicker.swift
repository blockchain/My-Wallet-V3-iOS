// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureDexDomain
import Foundation
import MoneyKit

public struct NetworkPicker: ReducerProtocol {
    public struct State: Equatable {
        var available: [EVMNetwork] = []
        var current: EVMNetwork?
    }

    public enum Action: Equatable {
        case onNetworkSelected(EVMNetwork)
        case onDismiss
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .onNetworkSelected:
                return .none
            case .onDismiss:
                return .none
            }
        }
    }
}
