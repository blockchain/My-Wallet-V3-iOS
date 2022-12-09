// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import FeatureDashboardUI
import SwiftUI

struct PKWDashboardView: View {
    let store: StoreOf<PKWDashboard>

    struct ViewState: Equatable {
        let title: String
        let actions: FrequentActions
        init(state: PKWDashboard.State) {
            title = state.title
            actions = state.frequentActions
        }
    }

    init(store: StoreOf<PKWDashboard>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init
        ) { viewStore in
            ScrollView {
                VStack(spacing: Spacing.padding4) {
                    FrequentActionsView(
                        actions: viewStore.actions
                    )
                    DashboardAssetSectionView(store: store.scope(
                        state: \.assetsState,
                        action: PKWDashboard.Action.assetsAction
                    ))

                    DashboardActivitySectionView(
                        store: self.store.scope(state: \.activityState, action: PKWDashboard.Action.activityAction)
                    )
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

// MARK: Provider

func provideDefiDashboard(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    PKWDashboardView(
        store: store.scope(
            state: \.defiState.home,
            action: DashboardContent.Action.defiHome
        )
    )
    .tabItem {
        Label(
            title: {
                Text(tab.name.localized())
                    .typography(.micro)
            },
            icon: { tab.icon.image }
        )
    }
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}
