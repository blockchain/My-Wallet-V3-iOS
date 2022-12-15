// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import ComposableArchitecture
import SwiftUI

@available(iOS 15, *)
struct DashboardContentView: View {
    let store: StoreOf<DashboardContent>

    struct ViewState: Equatable {
        let appMode: AppMode
        let tabs: OrderedSet<Tab>?
        let selectedTab: Tag.Reference

        init(state: DashboardContent.State) {
            self.appMode = state.appMode
            self.tabs = state.tabs
            self.selectedTab = state.selectedTab
        }
    }

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            content: { viewStore in
                TabView(
                    selection: viewStore.binding(get: \.selectedTab, send: DashboardContent.Action.select),
                    content: {
                        tabViews(
                            using: viewStore.tabs,
                            store: store,
                            appMode: viewStore.appMode
                        )
                        .hideTabBar()
                    }
                )
                .task { await viewStore.send(.onAppear).finish() }
                .overlay(
                    VStack {
                        Spacer()
                        BottomBar(
                            selectedItem: viewStore.binding(get: \.selectedTab, send: DashboardContent.Action.select),
                            items: bottomBarItems(for: viewStore.tabs)
                        )
                        .cornerRadius(100)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 10, y: 5)
                        .padding(
                            EdgeInsets(
                                top: 0,
                                leading: 40,
                                bottom: 0,
                                trailing: 40
                            )
                        )
                    }
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        )
    }
}

extension View {
    @ViewBuilder
    fileprivate func hideTabBar() -> some View {
        if #available(iOS 16, *) {
            self.toolbar(.hidden, for: .tabBar)
                .toolbarBackground(.hidden, for: .tabBar)
        } else {
            self.introspectTabBarController { controller in
                controller.tabBar.alpha = 0.0
                controller.tabBar.isHidden = true
            }
        }
    }
}

// MARK: Common Nav Bar Items

@ViewBuilder
func dashboardLeadingItem(app: AppProtocol) -> some View {
    IconButton(icon: .userv2.color(.black).small()) {
        app.post(
            event: blockchain.ux.user.account.entry.paragraph.button.icon.tap,
            context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
        )
    }
    .batch(
        .set(blockchain.ux.user.account.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.user.account)
    )
    .identity(blockchain.ux.user.account.entry)
}

@ViewBuilder
func dashboardTrailingItem(app: AppProtocol) -> some View {
    IconButton(icon: .viewfinder.color(.black).small()) {
        app.post(
            event: blockchain.ux.scan.QR.entry.paragraph.button.icon.tap,
            context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
        )
    }
    .batch(
        .set(blockchain.ux.scan.QR.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.scan.QR)
    )
    .identity(blockchain.ux.scan.QR.entry)
}

// TODO: Consolidate and use SiteMap if possible

@available(iOS 15, *)
func tabViews(using tabs: OrderedSet<Tab>?, store: StoreOf<DashboardContent>, appMode: AppMode) -> some View {
    ForEach(tabs ?? []) { tab in
        switch tab.tag {
        case blockchain.ux.user.portfolio where appMode == .trading:
            provideTradingDashboard(
                tab: tab,
                store: store
            )
        case blockchain.ux.user.portfolio where appMode == .pkw:
            provideDefiDashboard(
                tab: tab,
                store: store
            )
        default:
            Color.red
                .tag(tab.ref)
                .id(tab.ref.description)
                .accessibilityIdentifier(tab.ref.description)
        }
    }
}

func bottomBarItems(for tabs: OrderedSet<Tab>?) -> [BottomBarItem<Tag.Reference>] {
    guard let tabs else {
        return []
    }
    return tabs.map(BottomBarItem<Tag.Reference>.create(from:))
}
