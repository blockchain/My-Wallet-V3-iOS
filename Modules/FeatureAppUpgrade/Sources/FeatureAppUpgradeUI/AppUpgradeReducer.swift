// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum AppUpgradeAction: Equatable {
    case skip
}

public struct AppUpgradeReducer: ReducerProtocol {

    public typealias State = AppUpgradeState
    public typealias Action = AppUpgradeAction

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .skip:
                return .none
            }
        }
    }
}
