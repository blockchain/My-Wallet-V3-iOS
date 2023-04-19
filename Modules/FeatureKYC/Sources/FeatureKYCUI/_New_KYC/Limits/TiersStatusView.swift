// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import PlatformKit
import SwiftUI
import UIComponentsKit

private typealias LocalizedStrings = LocalizationConstants.KYC
private typealias LimitsFeatureStrings = LocalizedStrings.LimitsOverview.Feature

enum TiersStatusViewAction: Equatable {
    case close
    case tierTapped(KYC.Tier)
}

struct TiersStatusViewEnvironment {
    let presentKYCFlow: (KYC.Tier) -> Void
}

let tiersStatusViewReducer: Reducer<
    KYC.UserTiers,
    TiersStatusViewAction,
    TiersStatusViewEnvironment
> = .init { state, action, environment in
    switch action {
    case .tierTapped(let tier):
        guard tier > state.latestApprovedTier else {
            return .none
        }
        return .fireAndForget {
            environment.presentKYCFlow(tier)
        }

    default:
        return .none
    }
}

struct TiersStatusView: View {

    let store: Store<KYC.UserTiers, TiersStatusViewAction>
    @ObservedObject private var viewStore: ViewStore<KYC.UserTiers, TiersStatusViewAction>

    init(store: Store<KYC.UserTiers, TiersStatusViewAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ModalContainer(title: LocalizedStrings.LimitsStatus.pageTitle, onClose: { viewStore.send(.close) }, content: {
            let displayableTiers = viewStore.tiers
                .filter {
                    // We only want to show Silver and Gold.
                    $0.tier > .unverified && $0.tier <= .verified
                }
                .sorted(by: { $0.tier > $1.tier })

            PrimaryDivider()

            ScrollView {
                VStack(alignment: .leading, spacing: .zero) {
                    Section {
                        ForEach(displayableTiers, id: \.tier) { userTier in
                            TierStatusCell(userTier: userTier)
                                .onTapGesture {
                                    viewStore.send(.tierTapped(userTier.tier))
                                }
                            PrimaryDivider()
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
        })
    }
}

struct TierStatusCell: View {

    let userTier: KYC.UserTier

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.padding2) {
            Image("icon-verified", bundle: .module)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .accentColor(userTier.tier.accentColor)
                .foregroundColor(userTier.tier.accentColor)
            VStack(alignment: .leading, spacing: Spacing.padding2) {
                VStack(alignment: .leading, spacing: Spacing.baseline) {
                    Text(userTier.tier.limitsTitle)
                        .typography(.body2)
                    Text(userTier.tier.limitsMessage)
                        .typography(.paragraph1)
                    Text(userTier.tier.limitsDetails)
                        .typography(.caption1)
                    if let note = userTier.tier.limitsNote {
                        Text(note)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                    }
                }
                if userTier.state == .pending {
                    TagView(text: LocalizedStrings.accountInManualReviewBadge, variant: .infoAlt, size: .large)
                } else if userTier.tier.isVerified, userTier.state == .none {
                    TagView(text: LocalizedStrings.mostPopularBadge, variant: .success, size: .large)
                }
            }
            Spacer()
            if userTier.state == .none || userTier.state == .pending {
                Icon.chevronRight
                    .color(.semantic.muted)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(Spacing.padding3)
        .frame(maxWidth: .infinity, minHeight: 80)
    }
}

struct SwiftUIView_Previews: PreviewProvider {

    static var previews: some View {
        TiersStatusView(
            store: .init(
                initialState: .init(
                    tiers: [
                        .init(tier: .verified, state: .pending)
                    ]
                ),
                reducer: tiersStatusViewReducer,
                environment: TiersStatusViewEnvironment(
                    presentKYCFlow: { _ in }
                )
            )
        )
    }
}
