// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import ComposableNavigation
import Errors
import Localization
import PlatformKit
import SwiftUI
import UIComponentsKit

private typealias Events = AnalyticsEvents.New.KYC

struct TradingLimitsState: Equatable {
    var loading: Bool = false
    var userTiers: KYC.UserTiers?
    var featuresList: LimitedFeaturesListState = .init(
        features: [],
        kycTiers: .init(tiers: [])
    )
    var unlockTradingState: UnlockTradingState?
}

enum TradingLimitsAction: Equatable {
    case close
    case fetchLimits
    case didFetchLimits(Result<KYCLimitsOverview, Nabu.Error>)
    case listAction(LimitedFeaturesListAction)
    case unlockTrading(UnlockTradingAction)
}

struct TradingLimitsReducer: Reducer {

    typealias State = TradingLimitsState
    typealias Action = TradingLimitsAction

    let close: () -> Void
    let openURL: (URL) -> Void
    /// the passed-in tier is the tier the user whishes to upgrade to
    let presentKYCFlow: (KYC.Tier) -> Void
    let fetchLimitsOverview: () -> AnyPublisher<KYCLimitsOverview, Nabu.Error>
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>

    init(
        close: @escaping () -> Void,
        openURL: @escaping (URL) -> Void,
        presentKYCFlow: @escaping (KYC.Tier) -> Void,
        fetchLimitsOverview: @escaping () -> AnyPublisher<KYCLimitsOverview, Nabu.Error>,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.close = close
        self.openURL = openURL
        self.presentKYCFlow = presentKYCFlow
        self.fetchLimitsOverview = fetchLimitsOverview
        self.analyticsRecorder = analyticsRecorder
        self.mainQueue = mainQueue
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .close:
                let currentTier = state.unlockTradingState?.currentUserTier
                if let currentTier {
                    analyticsRecorder.record(
                        event: Events.tradingLimitsDismissed(
                            tier: currentTier.rawValue
                        )
                    )
                }
                close()
                return .none

            case .fetchLimits:
                state.loading = true
                return .publisher {
                    fetchLimitsOverview()
                        .receive(on: mainQueue)
                        .map { .didFetchLimits(.success($0)) }
                        .catch { .didFetchLimits(.failure($0)) }
                }

            case .didFetchLimits(let result):
                state.loading = false
                if case .success(let overview) = result {
                    state.userTiers = overview.tiers
                    state.featuresList = .init(
                        features: overview.features,
                        kycTiers: overview.tiers
                    )
                    let currentTier = overview.tiers.latestApprovedTier
                    state.unlockTradingState = UnlockTradingState(
                        currentUserTier: currentTier
                    )
                    analyticsRecorder.record(
                        event: Events.tradingLimitsViewed(
                            tier: currentTier.rawValue
                        )
                    )
                } else {
                    state.featuresList = .init(
                        features: [],
                        kycTiers: .init(tiers: [])
                    )
                }
                return .none

            default:
                return .none
            }
        }
        .ifLet(\TradingLimitsState.unlockTradingState, action: /TradingLimitsAction.unlockTrading) {
            UnlockTradingReducer(
                dismiss: close,
                unlock: presentKYCFlow,
                analyticsRecorder: analyticsRecorder
            )
        }
        Scope(state: \TradingLimitsState.featuresList, action: /TradingLimitsAction.listAction) {
            LimitedFeaturesListReducer(
                openURL: openURL,
                presentKYCFlow: presentKYCFlow
            )
        }
    }
}

struct TradingLimitsView: View {

    typealias LocalizedStrings = LocalizationConstants.KYC.LimitsOverview

    let store: Store<TradingLimitsState, TradingLimitsAction>
    @ObservedObject private var viewStore: ViewStore<TradingLimitsState, TradingLimitsAction>

    init(store: Store<TradingLimitsState, TradingLimitsAction>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        let canUpgradeTier = viewStore.userTiers?.canCompleteVerified == true
        let pageTitle = canUpgradeTier ? LocalizedStrings.upgradePageTitle : LocalizedStrings.pageTitle
        ModalContainer(title: pageTitle, onClose: { viewStore.send(.close) }, content: {
            VStack {
                if viewStore.loading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewStore.featuresList.features.isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: Spacing.padding2) {
                            Text(LocalizedStrings.emptyPageMessage)
                                .typography(.body2)
                                .multilineTextAlignment(.center)
                            BlockchainComponentLibrary.PrimaryButton(
                                title: LocalizedStrings.emptyPageRetryButton
                            ) {
                                viewStore.send(.fetchLimits)
                            }
                        }
                        .padding(Spacing.padding3)
                        Spacer()
                    }
                } else if canUpgradeTier {
                    IfLetStore(
                        store.scope(
                            state: \.unlockTradingState,
                            action: TradingLimitsAction.unlockTrading
                        ),
                        then: UnlockTradingView.init(store:),
                        else: {
                            LimitedFeaturesListView(
                                store: store.scope(
                                    state: \.featuresList,
                                    action: TradingLimitsAction.listAction
                                )
                            )
                        }
                    )
                } else {
                    LimitedFeaturesListView(
                        store: store.scope(
                            state: \.featuresList,
                            action: TradingLimitsAction.listAction
                        )
                    )
                }
            }
            .onAppear {
                viewStore.send(.fetchLimits)
            }
        })
    }
}

struct TradingLimitsView_Previews: PreviewProvider {

    static var previews: some View {
        TradingLimitsView(
            store: Store(initialState: TradingLimitsState()) {
                TradingLimitsReducer(
                    close: {},
                    openURL: { _ in },
                    presentKYCFlow: { _ in },
                    fetchLimitsOverview: {
                        let overview = KYCLimitsOverview(
                            tiers: KYC.UserTiers(tiers: []),
                            features: []
                        )
                        return .just(overview)
                    },
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            }
        )
    }
}
