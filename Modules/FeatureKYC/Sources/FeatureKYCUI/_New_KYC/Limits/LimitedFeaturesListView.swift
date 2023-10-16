// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import PlatformKit
import SwiftUI

extension URL {

    static let customerSupport: URL = "https://support.blockchain.com/hc/en-us/articles/4410561005844"
}

enum LimitedFeaturesListRoute: NavigationRoute {

    case viewTiers

    @ViewBuilder
    func destination(in store: Store<LimitedFeaturesListState, LimitedFeaturesListAction>) -> some View {
        switch self {
        case .viewTiers:
            TiersStatusView(
                store: store.scope(
                    state: \.kycTiers,
                    action: LimitedFeaturesListAction.tiersStatusViewAction
                )
            )
        }
    }
}

struct LimitedFeaturesListState: Equatable, NavigationState {
    var route: RouteIntent<LimitedFeaturesListRoute>?
    var features: [LimitedTradeFeature]
    var kycTiers: KYC.UserTiers
}

enum LimitedFeaturesListAction: Equatable, NavigationAction {
    case route(RouteIntent<LimitedFeaturesListRoute>?)
    case viewTiersTapped
    case verify
    case supportCenterLinkTapped
    case tiersStatusViewAction(TiersStatusViewAction)
}

struct LimitedFeaturesListReducer: Reducer {

    typealias State = LimitedFeaturesListState
    typealias Action = LimitedFeaturesListAction

    let openURL: (URL) -> Void
    let presentKYCFlow: (KYC.Tier) -> Void

    var body: some Reducer<State, Action> {
        Scope(state: \LimitedFeaturesListState.kycTiers, action: /LimitedFeaturesListAction.tiersStatusViewAction) {
            TiersStatusViewReducer(
                presentKYCFlow: presentKYCFlow
            )
        }
        Reduce { state, action in
            switch action {
            case .route(let route):
                state.route = route
                return .none

            case .viewTiersTapped:
                return .enter(into: .viewTiers, context: .none)

            case .verify:
                presentKYCFlow(.verified)
                return .none

            case .supportCenterLinkTapped:
                openURL(.customerSupport)
                return .none

            case .tiersStatusViewAction(let action):
                switch action {
                case .close:
                    return Effect.send(.dismiss())

                default:
                    return .none
                }
            }
        }
    }
}

private typealias LocalizedStrings = LocalizationConstants.KYC.LimitsOverview

extension KYC.Tier {

    fileprivate var limitsOverviewTitle: String? {
        switch self {
        case .unverified:
            return LocalizedStrings.headerTitle_unverified
        default:
            return nil
        }
    }

    fileprivate var limitsOverviewMessage: String {
        switch self {
        case .unverified:
            return LocalizedStrings.headerMessage_unverified
        default:
            return LocalizedStrings.headerMessage_verified
        }
    }
}

struct LimitedFeaturesListView: View {

    let store: Store<LimitedFeaturesListState, LimitedFeaturesListAction>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            let latestApprovedTier = viewStore.kycTiers.latestApprovedTier
            let hasPendingState = viewStore.kycTiers.tiers.contains(
                where: { $0.state == .pending }
            )
            let tierForHeader = hasPendingState ? .unverified : latestApprovedTier
            ScrollView {
                VStack(alignment: .leading, spacing: .zero) {
                    LimitedFeaturesListHeader(kycTier: tierForHeader) {
                        viewStore.send(.viewTiersTapped)
                    }
                    .listRowInsets(.zero)
                    .padding(.bottom, Spacing.padding3)

                    Section(
                        header: SectionHeader(
                            title: LocalizedStrings.featureListHeader
                        ),
                        footer: LimitedFeaturesListFooter()
                            .onTapGesture {
                                viewStore.send(.supportCenterLinkTapped)
                            }
                    ) {
                        if latestApprovedTier > .unverified {
                            TierTradeLimitCell(tier: latestApprovedTier)
                            PrimaryDivider()
                        }
                        ForEach(viewStore.features) { feature in
                            LimitedTradeFeatureCell(feature: feature)
                            PrimaryDivider()
                        }
                    }
                    .textCase(nil) // to avoid default transformation to uppercase
                    .listRowInsets(.zero)
                }
            }
            .navigationRoute(in: store)
        }
    }
}

struct LimitedFeaturesListHeader: View {

    let kycTier: KYC.Tier
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding3) {
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                if let title = kycTier.limitsOverviewTitle {
                    Text(title)
                        .typography(.body2)
                }
                Text(kycTier.limitsOverviewMessage)
                    .typography(.paragraph1)
            }
            if kycTier.isUnverified {
                BlockchainComponentLibrary.PrimaryButton(
                    title: LocalizedStrings.headerCTA_unverified,
                    action: action
                )
            }
        }
        .padding(.horizontal, Spacing.padding3)
    }
}

struct LimitedFeaturesListFooter: View {

    var body: some View {
        Text(rich: LocalizedStrings.footerText)
            .typography(.caption1)
            .foregroundColor(.semantic.body)
            .padding(Spacing.padding3)
    }
}

struct LimitedFeaturesListView_Previews: PreviewProvider {

    static var previews: some View {
        LimitedFeaturesListView(
            store: Store(
                initialState: LimitedFeaturesListState(
                    features: [],
                    kycTiers: .init(tiers: [])
                ),
                reducer: {
                    LimitedFeaturesListReducer(
                        openURL: { _ in },
                        presentKYCFlow: { _ in }
                    )
                }
            )
        )
    }
}
