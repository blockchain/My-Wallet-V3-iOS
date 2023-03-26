// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import FeatureTopMoversCryptoDomain
import FeatureTopMoversCryptoUI
import Foundation

public struct BuyEntry: ReducerProtocol {
    var app: AppProtocol
    var topMoversService: TopMoversServiceAPI

    public init(app: AppProtocol, topMoversService: TopMoversServiceAPI) {
        self.app = app
        self.topMoversService = topMoversService
    }

    public struct State: Equatable {
        var topMoversState = TopMoversSection.State(presenter: .accountPicker)
        public init() {}
    }

    public enum Action {
        case topMoversAction(TopMoversSection.Action)
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.topMoversState, action: /Action.topMoversAction) { () -> TopMoversSection in
            TopMoversSection(
                app: app,
                topMoversService: topMoversService
            )
        }
        EmptyReducer()
    }
}
