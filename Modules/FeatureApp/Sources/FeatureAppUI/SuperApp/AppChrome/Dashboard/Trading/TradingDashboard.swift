// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureAnnouncementsDomain
import FeatureAnnouncementsUI
import FeatureAppDomain
import FeatureDashboardDomain
import FeatureDashboardUI
import FeatureTopMoversCryptoUI
import FeatureWithdrawalLocksDomain
import Foundation
import MoneyKit
import SwiftUI
import UnifiedActivityDomain

public struct TradingDashboard: ReducerProtocol {
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.tradingGetStartedCryptoBuyAmmountsService) var tradingGetStartedCryptoBuyAmmountsService

    let app: AppProtocol
    let assetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI
    let activityRepository: UnifiedActivityRepositoryAPI
    let custodialActivityRepository: CustodialActivityRepositoryAPI
    let withdrawalLocksRepository: WithdrawalLocksRepositoryAPI

    public enum Action: BindableAction {
        case prepare
        case fetchGetStartedCryptoBuyAmmounts
        case onFetchGetStartedCryptoBuyAmmounts(TaskResult<[TradingGetStartedAmmountValue]>)
        case context(Tag.Context)
        case allAssetsAction(AllAssetsScene.Action)
        case assetsAction(DashboardAssetsSection.Action)
        case activityAction(DashboardActivitySection.Action)
        case allActivityAction(AllActivityScene.Action)
        case announcementsAction(FeatureAnnouncements.Action)
        case topMoversAction(TopMoversSection.Action)
        case binding(BindingAction<TradingDashboard.State>)
        case balanceFetched(Result<BalanceInfo, BalanceInfoError>)
    }

    public struct State: Equatable {
        var context: Tag.Context?
        public var tradingBalance: BalanceInfo?
        public var getStartedBuyCryptoAmmounts: [TradingGetStartedAmmountValue] = []
        public var assetsState: DashboardAssetsSection.State = .init(presentedAssetsType: .custodial)
        public var allAssetsState: AllAssetsScene.State = .init(with: .custodial)
        public var allActivityState: AllActivityScene.State = .init(with: .custodial)
        public var activityState: DashboardActivitySection.State = .init(with: .custodial)
        public var announcementsState: FeatureAnnouncements.State = .init()
        public var topMoversState: TopMoversSection.State = .init(presenter: .dashboard)
    }

    struct FetchBalanceId: Hashable {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Scope(state: \State.assetsState, action: /Action.assetsAction) { () -> DashboardAssetsSection in
            DashboardAssetsSection(
                assetBalanceInfoRepository: assetBalanceInfoRepository,
                withdrawalLocksRepository: withdrawalLocksRepository,
                app: app
            )
        }

        Scope(state: \.allAssetsState, action: /Action.allAssetsAction) { () -> AllAssetsScene in
            AllAssetsScene(
                assetBalanceInfoRepository: assetBalanceInfoRepository,
                app: app
            )
        }

        Scope(state: \.topMoversState, action: /Action.topMoversAction) { () -> TopMoversSection in
            TopMoversSection(
                app: app,
                topMoversService: resolve()
            )
        }

        Scope(state: \.activityState, action: /Action.activityAction) { () -> DashboardActivitySection in
            DashboardActivitySection(
                app: app,
                activityRepository: activityRepository,
                custodialActivityRepository: custodialActivityRepository
            )
        }

        Scope(state: \.allActivityState, action: /Action.allActivityAction) { () -> AllActivityScene in
            AllActivityScene(
                activityRepository: activityRepository,
                custodialActivityRepository: custodialActivityRepository,
                app: app
            )
        }

        Scope(state: \.announcementsState, action: /Action.announcementsAction) { () -> FeatureAnnouncements in
            FeatureAnnouncements(
                app: app,
                mainQueue: mainQueue,
                mode: .trading,
                service: resolve()
            )
        }

        Reduce { state, action in
            switch action {
            case .context(let context):
                state.context = context
                return .none
            case .prepare:
                return .run { send in
                    let stream = app
                        .stream(
                            blockchain.ux.dashboard.total.trading.balance.info,
                            as: BalanceInfo.self
                        )
                    for await balanceValue in stream {
                        do {
                            let value = try balanceValue.get()
                            await send(Action.balanceFetched(.success(value)))
                        } catch {
                            error.localizedDescription.peek()
                            await send(Action.balanceFetched(.failure(.unableToRetrieve)))
                        }
                    }
                }
                .cancellable(id: FetchBalanceId.self, cancelInFlight: true)

            case .balanceFetched(.success(let info)):
                state.tradingBalance = info
                if let balance = state.tradingBalance?.balance, balance.isZero {
                    return EffectTask(value: .fetchGetStartedCryptoBuyAmmounts)
                } else {
                    return .none
                }

            case .fetchGetStartedCryptoBuyAmmounts:
                return .task(priority: .userInitiated) {
                    await Action.onFetchGetStartedCryptoBuyAmmounts(
                        TaskResult { try await tradingGetStartedCryptoBuyAmmountsService.cryptoBuyAmmounts() }
                    )
                }

            case .onFetchGetStartedCryptoBuyAmmounts(.success(let amounts)):
                state.getStartedBuyCryptoAmmounts = amounts
                return .none

            case .onFetchGetStartedCryptoBuyAmmounts(.failure):
                return .none

            case .balanceFetched(.failure):
                // TODO: handle error?
                // what do we do in an error, hide balance? display something?
                return .none
            case .assetsAction:
                 return .none
            case .allAssetsAction:
                return .none
            case .topMoversAction:
                return .none
            case .announcementsAction:
                return .none
            case .allActivityAction(let action):
                switch action {
                case .onCloseTapped:
                    return .none
                default:
                    return .none
                }
            case .binding:
                return .none
            case .activityAction(let action):
                switch action {
                case .onAllActivityTapped:
                    return .fireAndForget { [context = state.context] in
                    if let context {
                        app.post(event: blockchain.ux.user.activity.all, context: context + [
                            blockchain.ux.user.activity.all.model: PresentedAssetType.custodial
                        ])
                      }
                    }
                default:
                    return .none
                }
            }
        }
    }
}
