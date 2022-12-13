// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import FeatureDashboardUI
import SwiftUI

struct TradingDashboardView: View {
    let store: StoreOf<TradingDashboard>

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
            PrimaryNavigationView {
                ScrollView {
                    VStack(spacing: Spacing.padding4) {
                        FrequentActionsView(
                            actions: viewStore.actions
                        )
                        DashboardAssetSectionView(
                            store: self.store.scope(
                                state: \.assetsState,
                                action: TradingDashboard.Action.assetsAction
                            )
                        )

//                        DashboardActivitySectionView(
//                            store: self.store.scope(state: \.activityState, action: TradingDashboard.Action.activityAction)
//                        )
                    }
                    .findScrollView { scrollView in
                        scrollView.showsVerticalScrollIndicator = false
                        scrollView.showsHorizontalScrollIndicator = false
                    }
                    .navigationRoute(in: store)
                    .padding(.bottom, Spacing.padding6)
                    .frame(maxWidth: .infinity)
                }
                .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
            }
        }
    }
}

// MARK: Provider

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
    .background(Color.semantic.light)
}
