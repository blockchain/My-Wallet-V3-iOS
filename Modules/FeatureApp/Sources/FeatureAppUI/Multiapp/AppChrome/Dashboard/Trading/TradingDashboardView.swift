// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureDashboardUI
import SwiftUI

@available(iOS 15, *)
struct TradingDashboardView: View {
    @BlockchainApp var app

    let store: StoreOf<TradingDashboard>

    @State var scrollOffset: CGFloat = 0
    @StateObject var scrollViewObserver = ScrollViewOffsetObserver()

    struct ViewState: Equatable {
        let title: String
        let actions: FrequentActions
        init(state: TradingDashboard.State) {
            self.title = state.title
            self.actions = state.frequentActions
        }
    }

    init(store: StoreOf<TradingDashboard>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init
        ) { viewStore in
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.padding4) {
                    VStack {
                        Text("$274,456.75")
                            .typography(.title1)
                            .foregroundColor(.semantic.title)
                    }
                    .padding([.top], Spacing.padding3)

                    FrequentActionsView(
                        actions: viewStore.actions
                    )
                    DashboardAssetSectionView(
                        store: self.store.scope(
                            state: \.assetsState,
                            action: TradingDashboard.Action.assetsAction
                        )
                    )

                    DashboardActivitySectionView(
                        store: self.store.scope(state: \.activityState, action: TradingDashboard.Action.activityAction)
                    )
                }
                .findScrollView { scrollView in
                    scrollViewObserver.didScroll = { offset in
                        DispatchQueue.main.async {
                            $scrollOffset.wrappedValue = offset.y
                        }
                    }
                    scrollView.delegate = scrollViewObserver
                }
                .navigationRoute(in: store)
                .padding(.bottom, 72.pt)
                .frame(maxWidth: .infinity)
            }
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                title: {
                    Text("$274,456.75")
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
func provideTradingDashboard(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    TradingDashboardView(
        store: store.scope(
            state: \.tradingState.home,
            action: DashboardContent.Action.tradingHome
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}
