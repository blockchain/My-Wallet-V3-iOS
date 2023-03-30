// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import DIKit
import FeatureDashboardUI
import FeatureDexUI

struct TradingTabsState: Equatable {
    var selectedTab: Tag.Reference = blockchain.ux.user.portfolio[].reference

    var home: TradingDashboard.State = .init()
    var prices: PricesScene.State = .init(appMode: .trading, topMoversState: .init(.init(presenter: .prices)))
}

@available(iOS 15, *)
struct DefiTabsState: Equatable {
    var selectedTab: Tag.Reference = blockchain.ux.user.portfolio[].reference

    var home: DeFiDashboard.State = .init()
    var prices: PricesScene.State = .init(appMode: .pkw)
    var dex: DexDashboard.State = .init()
}

@available(iOS 15, *)
struct DashboardContent: ReducerProtocol {
    @Dependency(\.app) var app

    struct State: Equatable {
        let appMode: AppMode
        var tabs: OrderedSet<Tab>?
        var selectedTab: Tag.Reference {
            switch appMode {
            case .pkw:
                return defiState.selectedTab
            case .trading, .universal:
                return tradingState.selectedTab
            }
        }

        // Tabs
        var tradingState: TradingTabsState = .init()
        var defiState: DefiTabsState = .init()
    }

    enum Action {
        case onAppear
        case tabs(OrderedSet<Tab>?)
        case frequentActions(FrequentActions?)
        case select(Tag.Reference)
        // Tabs
        case tradingHome(TradingDashboard.Action)
        case defiHome(DeFiDashboard.Action)
        case tradingPrices(PricesScene.Action)
        case defiPrices(PricesScene.Action)
        case defiDex(DexDashboard.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.tradingState.home, action: /Action.tradingHome) { () -> TradingDashboard in
            // TODO: DO NOT rely on DIKit...
            TradingDashboard(
                app: app,
                assetBalanceInfoRepository: DIKit.resolve(),
                activityRepository: DIKit.resolve(),
                custodialActivityRepository: DIKit.resolve(),
                withdrawalLocksRepository: DIKit.resolve()
            )
        }
        Scope(state: \.defiState.home, action: /Action.defiHome) { () -> DeFiDashboard in
            DeFiDashboard(
                app: app,
                assetBalanceInfoRepository: DIKit.resolve(),
                activityRepository: DIKit.resolve(),
                withdrawalLocksRepository: DIKit.resolve()
            )
        }
        Scope(state: \.tradingState.prices, action: /Action.tradingPrices) { () -> PricesScene in
            PricesScene(
                pricesSceneService: DIKit.resolve(),
                app: app,
                topMoversService: DIKit.resolve()
            )
        }
        Scope(state: \.defiState.prices, action: /Action.defiPrices) { () -> PricesScene in
            PricesScene(
                pricesSceneService: DIKit.resolve(),
                app: app,
                topMoversService: DIKit.resolve()
            )
        }
        Scope(state: \.defiState.dex, action: /Action.defiDex) { () -> DexDashboard in
            DexDashboard(
                app: app,
                balances: {
                    let service: DelegatedCustodyBalanceRepositoryAPI = DIKit.resolve()
                    return service.balances
                }
            )
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                let tabsEffect = Effect.run { [state] send in
                    switch state.appMode {
                    case .trading, .universal:
                        for await event in app.stream(blockchain.app.configuration.superapp.brokerage.tabs, as: TabConfig.self) {
                            await send(DashboardContent.Action.tabs(event.value?.tabs))
                        }
                    case .pkw:
                        for await event in app.stream(blockchain.app.configuration.superapp.defi.tabs, as: TabConfig.self) {
                            await send(DashboardContent.Action.tabs(event.value?.tabs))
                        }
                    }
                }
                let frequentActions = Effect.run { [state] send in
                    switch state.appMode {
                    case .trading, .universal:
                        for await event in app.stream(blockchain.app.configuration.superapp.brokerage.frequent.actions, as: FrequentActions.self) {
                            await send(DashboardContent.Action.frequentActions(event.value))
                        }
                    case .pkw:
                        for await event in app.stream(blockchain.app.configuration.superapp.defi.frequent.actions, as: FrequentActions.self) {
                            await send(DashboardContent.Action.frequentActions(event.value))
                        }
                    }
                }
                return Effect.merge(
                    tabsEffect,
                    frequentActions
                )
            case .tabs(let tabs):
                state.tabs = tabs
                return .none
            case .select(let tag):
                switch state.appMode {
                case .trading, .universal:
                    state.tradingState.selectedTab = tag
                case .pkw:
                    state.defiState.selectedTab = tag
                }
                return .none
            case .frequentActions(let actions):
                guard let actions else {
                    return .none
                }
                switch state.appMode {
                case .trading, .universal:
                    state.tradingState.home.frequentActions = actions
                case .pkw:
                    state.defiState.home.frequentActions = actions
                }
                return .none
            case .tradingHome, .defiHome:
                return .none
            case .tradingPrices, .defiPrices:
                return .none
            case .defiDex:
                return .none
            }
        }
    }
}
