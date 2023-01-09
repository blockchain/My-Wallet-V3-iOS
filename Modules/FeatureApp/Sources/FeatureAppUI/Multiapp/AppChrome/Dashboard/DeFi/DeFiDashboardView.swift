// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureDashboardUI
import SwiftUI

@available(iOS 15, *)
struct DeFiDashboardView: View {
    @BlockchainApp var app

    let store: StoreOf<DeFiDashboard>

    @State var scrollOffset: CGFloat = 0
    @StateObject var scrollViewObserver = ScrollViewOffsetObserver()

    struct ViewState: Equatable {
        let actions: FrequentActions
        let balance: BalanceInfo?
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
                        isPercentageHidden: false
                    )
                    .padding([.top], Spacing.padding3)

                    FrequentActionsView(
                        actions: viewStore.actions
                    )
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

                    DashboardHelpSectionView()
                }
                .findScrollView { scrollView in
                    scrollViewObserver.didScroll = { offset in
                        DispatchQueue.main.async {
                            $scrollOffset.wrappedValue = offset.y
                        }
                    }
                    scrollView.delegate = scrollViewObserver
                }
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
                scrollOffset: $scrollOffset
            )
            .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
        }
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
