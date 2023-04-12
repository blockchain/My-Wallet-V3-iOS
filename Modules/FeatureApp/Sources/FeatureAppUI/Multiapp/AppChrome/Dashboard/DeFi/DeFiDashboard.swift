// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureAppDomain
import FeatureDashboardDomain
import FeatureDashboardUI
import FeatureWithdrawalLocksDomain
import Foundation
import MoneyKit
import SwiftUI
import UnifiedActivityDomain

public struct DeFiDashboard: ReducerProtocol {
    let app: AppProtocol
    let assetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI
    let activityRepository: UnifiedActivityRepositoryAPI
    let withdrawalLocksRepository: WithdrawalLocksRepositoryAPI

    public enum Action: Equatable {
        case fetchBalance
        case balanceFetched(Result<BalanceInfo, BalanceInfoError>)
        case assetsAction(DashboardAssetsSection.Action)
        case announcementAction(DashboardAnnouncementsSection.Action)
        case allAssetsAction(AllAssetsScene.Action)
        case activityAction(DashboardActivitySection.Action)
        case allActivityAction(AllActivityScene.Action)
    }

    public struct State: Equatable {
        public var balance: BalanceInfo?
        public var frequentActions: FrequentActions = .init(
            withBalance: .init(
                list: [],
                buttons: []
            ),
            zeroBalance: .init(
                list: [],
                buttons: []
            )
        )
        public var assetsState: DashboardAssetsSection.State = .init(presentedAssetsType: .nonCustodial)
        public var allAssetsState: AllAssetsScene.State = .init(with: .nonCustodial)
        public var allActivityState: AllActivityScene.State = .init(with: .nonCustodial)
        public var activityState: DashboardActivitySection.State = .init(with: .nonCustodial)
        public var announcementState: DashboardAnnouncementsSection.State = .init()
    }

    struct FetchBalanceId: Hashable {}

    public var body: some ReducerProtocol<State, Action> {
        Scope<State, Action, DashboardAssetsSection>(state: \.assetsState, action: /Action.assetsAction) {
            DashboardAssetsSection(
                assetBalanceInfoRepository: assetBalanceInfoRepository,
                withdrawalLocksRepository: withdrawalLocksRepository,
                app: app
            )
        }

        Scope<State, Action, AllAssetsScene>(state: \.allAssetsState, action: /Action.allAssetsAction) {
            AllAssetsScene(
                assetBalanceInfoRepository: assetBalanceInfoRepository,
                app: app
            )
        }

        Scope<State, Action, AllActivityScene>(state: \.allActivityState, action: /Action.allActivityAction) {
            AllActivityScene(
                activityRepository: activityRepository,
                custodialActivityRepository: resolve(),
                app: app
            )
        }

        Scope<State, Action, DashboardActivitySection>(state: \.activityState, action: /Action.activityAction) {
            DashboardActivitySection(
                app: app,
                activityRepository: activityRepository,
                custodialActivityRepository: resolve()
            )
        }

        Scope<State, Action, DashboardAnnouncementsSection>(state: \.announcementState, action: /Action.announcementAction) {
            DashboardAnnouncementsSection(
                app: app,
                recoverPhraseProviding: resolve()
            )
        }

        Reduce { state, action in
            switch action {
            case .fetchBalance:
                return .run { send in
                    for await balanceValue in app.stream(blockchain.ux.dashboard.total.defi.balance, as: BalanceInfo.self) {
                        if let value = balanceValue.value {
                            await send(Action.balanceFetched(.success(value)))
                        }
                    }
                }
            case .balanceFetched(.success(let info)):
                state.balance = info
                return .none
            case .balanceFetched(.failure):
                return .none
            case .allAssetsAction(let action):
                switch action {
                default:
                    return .none
                }
            case .activityAction(let action):
                switch action {
                case .onAllActivityTapped:
                    return .none
                default:
                    return .none
                }
            case .assetsAction(let action):
                switch action {
                case .onAllAssetsTapped:
                    return .none
                default:
                    return .none
                }
            case .announcementAction:
                return .none
            case .allActivityAction(let action):
                switch action {
                case .onCloseTapped:
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}
