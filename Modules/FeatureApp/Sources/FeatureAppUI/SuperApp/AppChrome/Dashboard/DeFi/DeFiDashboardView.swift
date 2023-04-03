// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureAnnouncementsUI
import FeatureAppDomain
import FeatureDashboardUI
import Localization
import SwiftUI

@available(iOS 15, *)
struct DeFiDashboardView: View {
    @BlockchainApp var app

    let store: StoreOf<DeFiDashboard>

    @State var scrollOffset: CGPoint = .zero

    struct ViewState: Equatable {
        let actions: FrequentActions
        let balance: BalanceInfo?
        var isZeroBalance: Bool { balance?.balance.isZero ?? false }
        var isBalanceLoaded: Bool { balance != nil }
        init(state: DeFiDashboard.State) {
            self.actions = state.frequentActions
            self.balance = state.balance
        }
    }

    init(store: StoreOf<DeFiDashboard>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init
        ) { viewStore in
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.padding4) {

                    DashboardMainBalanceView(
                        info: .constant(viewStore.balance),
                        isPercentageHidden: viewStore.isZeroBalance
                    )
                    .padding([.top], Spacing.padding3)

                    FrequentActionsView(
                        actions: !viewStore.isBalanceLoaded || viewStore.isZeroBalance
                        ? viewStore.actions.zeroBalance
                        : viewStore.actions.withBalance,
                        topPadding: viewStore.isZeroBalance ? 0 : Spacing.padding3
                    )

                    FeatureAnnouncementsView(
                        store: store.scope(
                            state: \.announcementsState,
                            action: DeFiDashboard.Action.announcementsAction
                        )
                    )

                    DashboardAnnouncementsSectionView(
                        store: store.scope(
                            state: \.announcementState,
                            action: DeFiDashboard.Action.announcementAction
                        )
                    )

                    if viewStore.isZeroBalance {
                        DeFiDashboardToGetStartedView()
                    } else {
                        DashboardAssetSectionView(
                            store: store.scope(
                                state: \.assetsState,
                                action: DeFiDashboard.Action.assetsAction
                            )
                        )

                        DashboardActivitySectionView(
                            store: store.scope(
                                state: \.activityState,
                                action: DeFiDashboard.Action.activityAction
                            )
                        )
                    }

                    DashboardHelpSectionView()
                }
                .scrollOffset($scrollOffset)
                .task {
                    await viewStore.send(.fetchBalance).finish()
                }
                .padding(.bottom, 72.pt)
                .frame(maxWidth: .infinity)
            }
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                title: {
                    Text(viewStore.balance?.balanceTitle ?? "")
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                },
                trailing: { [app] in dashboardTrailingItem(app: app) },
                titleShouldFollowScroll: true,
                titleExtraOffset: Spacing.padding3,
                scrollOffset: $scrollOffset.y
            )
            .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
        }
    }
}

struct DeFiDashboardToGetStartedView: View {
    private typealias L10n = LocalizationConstants.SuperApp.Dashboard.GetStarted.Pkw
    @BlockchainApp var app

    var body: some View {
        VStack {
            ZStack {
                Color.semantic.background
                VStack(spacing: Spacing.padding3) {
                    Image("receive_crypto_icon")
                    Text(L10n.toGetStartedTitle)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                        .multilineTextAlignment(.center)
                    Text(L10n.toGetStartedSubtitle)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                        .multilineTextAlignment(.center)
                    PrimaryButton(
                        title: L10n.toGetStartedDepositCryptoButtonTitle,
                        action: { [app] in
                            app.post(
                                event: blockchain.ux.dashboard.empty.receive.paragraph.row.tap
                            )
                        }
                    )
                }
                .batch {
                    set(
                        blockchain.ux.dashboard.empty.receive.paragraph.row.event.select.then.emit,
                        to: blockchain.ux.frequent.action.receive
                    )
                }
                .padding([.vertical], Spacing.padding3)
                .padding([.horizontal], Spacing.padding2)
            }
            .cornerRadius(16.0, corners: .allCorners)
        }
        .padding(.horizontal, Spacing.padding2)
    }
}

// MARK: Provider

@available(iOS 15, *)
func provideDefiDashboard(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    DeFiDashboardView(
        store: store.scope(
            state: \.defiState.home,
            action: DashboardContent.Action.defiHome
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}
