// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
import Foundation
import SwiftUI
import UnifiedActivityDomain

public struct TradingDashboard: ReducerProtocol {
    let app: AppProtocol
    let assetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI
    let activityRepository: UnifiedActivityRepositoryAPI
    let custodialActivityRepository: CustodialActivityRepositoryAPI

    public enum Route: NavigationRoute {
        case showAllAssets
        case showAllActivity

        @ViewBuilder
        public func destination(in store: Store<State, Action>) -> some View {
            switch self {

            case .showAllAssets:
                AllAssetsSceneView(store: store.scope(
                    state: \.allAssetsState,
                    action: Action.allAssetsAction
                ))

            case .showAllActivity:
                AllActivitySceneView(store: store.scope(
                    state: \.allActivityState,
                    action: Action.allActivityAction
                ))
            }
        }
    }

    public enum Action: Equatable, NavigationAction, BindableAction {
        case route(RouteIntent<Route>?)
        case allAssetsAction(AllAssetsScene.Action)
        case assetsAction(DashboardAssetsSection.Action)
        case activityAction(DashboardActivitySection.Action)
        case allActivityAction(AllActivityScene.Action)
        case binding(BindingAction<TradingDashboard.State>)
    }

    public struct State: Equatable, NavigationState {
        public var title: String
        public var frequentActions: FrequentActions = .init(
            list: [],
            buttons: []
        )
        public var assetsState: DashboardAssetsSection.State = .init(presentedAssetsType: .custodial)
        public var allAssetsState: AllAssetsScene.State = .init(with: .custodial)
        public var allActivityState: AllActivityScene.State = .init(with: .custodial)
        public var activityState: DashboardActivitySection.State = .init(with: .custodial)
        public var route: RouteIntent<Route>?

        public init(title: String) {
            self.title = title
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \.assetsState, action: /Action.assetsAction) {
            DashboardAssetsSection(
                assetBalanceInfoRepository: assetBalanceInfoRepository,
                app: app
            )
        }

        Scope(state: \.allAssetsState, action: /Action.allAssetsAction) {
            AllAssetsScene(
                assetBalanceInfoRepository: assetBalanceInfoRepository,
                app: app
            )
        }

        Scope(state: \.activityState, action: /Action.activityAction) {
            DashboardActivitySection(
                app: app,
                activityRepository: activityRepository,
                custodialActivityRepository: custodialActivityRepository
            )
        }

        Scope(state: \.allActivityState, action: /Action.allActivityAction) {
            AllActivityScene(
                activityRepository: activityRepository,
                custodialActivityRepository: custodialActivityRepository,
                app: app
            )
        }

        Reduce { state, action in
            switch action {
            case .route(let routeIntent):
                state.route = routeIntent
                return .none
            case .assetsAction(let action):
                switch action {
                case .onAllAssetsTapped:
                    state.route = .enter(into: .showAllAssets)
                    return .none
                default:
                    return .none
                }
            case .allAssetsAction:
                return .none
            case .allActivityAction(let action):
                switch action {
                case .onCloseTapped:
                    state.route = nil
                    return .none
                default:
                    return .none
                }
            case .binding:
                return .none
            case .activityAction(let action):
                switch action {
                case .onAllActivityTapped:
                    state.route = .enter(into: .showAllActivity)
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}
