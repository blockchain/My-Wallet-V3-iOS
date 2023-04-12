// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Collections
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
import FeatureProductsDomain
import Foundation
import MoneyKit
import SwiftUI

struct SuperAppContent: ReducerProtocol {
    @Dependency(\.totalBalanceService) var totalBalanceService
    let app: AppProtocol

    struct State: Equatable {
        var headerState: MultiAppHeader.State = .init()
        var trading: DashboardContent.State = .init(appMode: .trading)
        var defi: DashboardContent.State = .init(appMode: .pkw)
    }

    enum Action {
        case onAppear
        case onDisappear
        case refresh
        case onTotalBalanceFetched(TaskResult<TotalBalanceInfo>)
        case onTradingModeEnabledFetched(Bool)
        case header(MultiAppHeader.Action)
        case trading(DashboardContent.Action)
        case defi(DashboardContent.Action)
    }

    private enum TotalBalanceFetchId {}

    var body: some ReducerProtocol<State, Action> {
        Scope<State, Action, MultiAppHeader>(state: \.headerState, action: /Action.header) {
            MultiAppHeader()
        }

        Scope<State, Action, DashboardContent>(state: \.trading, action: /Action.trading) {
            DashboardContent()
        }

        Scope<State, Action, DashboardContent>(state: \.defi, action: /Action.defi) {
            DashboardContent()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .fireAndForget {
                        app.state.set(blockchain.app.is.ready.for.deep_link, to: true)
                    },
                    .task {
                        let defaultingIsEnabled = (try? await app.get(blockchain.app.configuration.app.mode.defaulting.is.enabled, as: Bool.self)) ?? false
                        let tradingEnabled = (try? await app.get(
                            blockchain.api.nabu.gateway.products[ProductIdentifier.useTradingAccount].is.eligible,
                            as: Bool.self
                        )) ?? true
                        let shouldDisplayTrading = (defaultingIsEnabled && tradingEnabled) || !defaultingIsEnabled
                        return .onTradingModeEnabledFetched(shouldDisplayTrading)
                    }
                )
            case .refresh:
                NotificationCenter.default.post(name: .dashboardPullToRefresh, object: nil)
                app.post(event: blockchain.ux.home.event.did.pull.to.refresh)
                state.headerState.isRefreshing = true
                return .run { send in
                    for await total in totalBalanceService.totalBalance() {
                        await send(.onTotalBalanceFetched(TaskResult { try total.get() }))
                    }
                }
                .cancellable(id: TotalBalanceFetchId.self, cancelInFlight: true)

            case .onTotalBalanceFetched(.success(let info)):
                state.headerState.totalBalance = info.total.toDisplayString(includeSymbol: true)
                state.headerState.isRefreshing = false
                return .none

            case .onTotalBalanceFetched(.failure):
                state.headerState.isRefreshing = false
                return .none
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

            case .onTradingModeEnabledFetched(let enabled):
                state.headerState.tradingEnabled = enabled
                return .none
            }
        }
    }
}
