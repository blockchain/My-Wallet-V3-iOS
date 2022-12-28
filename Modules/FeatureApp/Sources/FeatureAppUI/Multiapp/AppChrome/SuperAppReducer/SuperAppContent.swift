// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Collections
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
import Foundation
import SwiftUI

struct SuperAppContent: ReducerProtocol {
    let app: AppProtocol

    struct State: Equatable {
        var headerState: MultiAppHeader.State = .init()
        var trading: DashboardContent.State = .init(appMode: .trading)
        var defi: DashboardContent.State = .init(appMode: .pkw)
    }

    enum Action {
        case onAppear
        case onDisappear
        case header(MultiAppHeader.Action)
        case trading(DashboardContent.Action)
        case defi(DashboardContent.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.headerState, action: /Action.header) {
            MultiAppHeader()
        }

        Scope(state: \.trading, action: /Action.trading) {
            DashboardContent()
        }

        Scope(state: \.defi, action: /Action.defi) {
            DashboardContent()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.headerState.totalBalance = "$100.000"
                return .fireAndForget {
                    app.state.set(blockchain.app.is.ready.for.deep_link, to: true)
                }
            case .onDisappear:
                return .fireAndForget {
                    app.state.set(blockchain.app.is.ready.for.deep_link, to: false)
                }
            case .header:
                return .none
            case .trading:
                return .none
            case .defi:
                return .none
            }
        }
    }
}
