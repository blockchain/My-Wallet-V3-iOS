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

public struct PKWDashboard: ReducerProtocol {
    let app: AppProtocol
    let allCryptoAssetService: AllCryptoAssetsServiceAPI
    let activityRepository: UnifiedActivityRepositoryAPI

    public enum Route: NavigationRoute {
        case showAllAssets
        case showAllActivity

        @ViewBuilder
        public func destination(in store: Store<State, Action>) -> some View {
            switch self {

            case .showAllAssets:
                AllAssetsSceneView(store: store.scope(state: \.allAssetsState, action: Action.allAssetsAction))

            case .showAllActivity:
                AllActivitySceneView(store: store.scope(state: \.allActivityState, action: Action.allActivityAction))
            }
        }
    }

    public enum Action: Equatable, NavigationAction {
        case route(RouteIntent<Route>?)
        case assetsAction(DashboardAssetsSection.Action)
        case allAssetsAction(AllAssetsScene.Action)
        case activityAction(DashboardActivitySection.Action)
        case allActivityAction(AllActivityScene.Action)
    }

    public struct State: Equatable, NavigationState {
        public var title: String
        public var frequentActions: FrequentActions = .init(list: [], buttons: [])
        public var assetsState: DashboardAssetsSection.State = .init(presentedAssetsType: .nonCustodial)
        public var allAssetsState: AllAssetsScene.State = .init(with: .nonCustodial)
        public var allActivityState: AllActivityScene.State = .init()
        public var activityState: DashboardActivitySection.State = .init()
        public var route: RouteIntent<Route>?

        public init(title: String) {
            self.title = title
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.assetsState, action: /Action.assetsAction) {
            DashboardAssetsSection(
                allCryptoAssetService: allCryptoAssetService,
                app: app
            )
        }

        Scope(state: \.allAssetsState, action: /Action.allAssetsAction) {
            AllAssetsScene(
                allCryptoService: allCryptoAssetService,
                app: app
            )
        }

        Scope(state: \.allActivityState, action: /Action.allActivityAction) {
            AllActivityScene(activityRepository: activityRepository, app: app)
        }
        Scope(state: \.activityState, action: /Action.activityAction) {
            DashboardActivitySection(
                app: app,
                activityRepository: activityRepository
            )
        }

        Reduce { state, action in
            switch action {
            case .route(let routeIntent):
                state.route = routeIntent
                return .none
            case .allAssetsAction(let action):
                switch action {
                case .onCloseTapped:
                    state.route = nil
                    return .none
                default:
                    return .none
                }
            case .activityAction(let action):
                switch action {
                case .onAllActivityTapped:
                    state.route = .enter(into: .showAllActivity)
                default:
                    return .none
                }
                return .none
            case .assetsAction(let action):
                switch action {
                case .onAllAssetsTapped:
                    state.route = .navigate(to: .showAllAssets)
                    return .none
                default:
                    return .none
                }
            case .allActivityAction(let action):
                switch action {
                case .onCloseTapped:
                    state.route = nil
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}
