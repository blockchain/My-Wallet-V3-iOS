// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Collections
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
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
        case prepare
        case refresh
        case onTotalBalanceFetched(TaskResult<TotalBalanceInfo>)
        case header(MultiAppHeader.Action)
        case trading(DashboardContent.Action)
        case defi(DashboardContent.Action)
    }

    private enum TotalBalanceFetchId { }

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
                return .fireAndForget {
                    app.state.set(blockchain.app.is.ready.for.deep_link, to: true)
                }
            case .prepare:
                let trackTradingCurrency = Effect.run { send in
                    for await _ in app.stream(blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self) {
                        await send(Action.refresh)
                    }
                }
                return .merge(
                    trackTradingCurrency
                )
            case .refresh:
                NotificationCenter.default.post(name: .dashboardPullToRefresh, object: nil)
                app.post(event: blockchain.ux.home.event.did.pull.to.refresh)
                return .task(priority: .userInitiated) {
                    await Action.onTotalBalanceFetched(
                        TaskResult { try await totalBalanceService.totalBalance() }
                    )
                }
                .cancellable(id: TotalBalanceFetchId.self)
            case .onTotalBalanceFetched(.success(let info)):
                state.headerState.totalBalance = info.total.toDisplayString(includeSymbol: true)
                return .none
            case .onTotalBalanceFetched(.failure):
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
            }
        }
    }
}
