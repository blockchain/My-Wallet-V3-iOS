// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import DIKit
import FeatureDashboardUI
import FeatureDexUI
import FeatureNFTUI
import FeatureStakingUI
import SwiftUI

@available(iOS 15, *)
struct DashboardContentView: View {

    @BlockchainApp var app
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
                .onReceive(
                    app.on(blockchain.ux.home[viewStore.appMode.rawValue].tab.select).receive(on: DispatchQueue.main),
                    perform: { event in
                        do {
                            $app.post(event: blockchain.ux.home.return.home)
                            try viewStore.send(
                                DashboardContent.Action.select(
                                    event.reference.context.decode(blockchain.ux.home.tab.id)
                                )
                            )
                        } catch {
                            app.post(error: error)
                        }
                    }
                )
                .task { await viewStore.send(.onAppear).finish() }
                .overlay(alignment: .bottom) {
                    VStack {
                        Spacer()
                        VStack {
                            BottomBar(
                                selectedItem: viewStore.binding(get: \.selectedTab, send: DashboardContent.Action.select),
                                items: bottomBarItems(for: viewStore.tabs)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 10, y: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .background {
                            LinearGradient(
                                colors: [Color.semantic.light, Color.semantic.light.opacity(0.0)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .ignoresSafeArea()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
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
            introspectTabBarController { controller in
                controller.tabBar.alpha = 0.0
                controller.tabBar.isHidden = true
            }
        }
    }
}

// MARK: Common Nav Bar Items

@ViewBuilder
func dashboardLeadingItem(app: AppProtocol) -> some View {
    IconButton(icon: .userv2.color(.semantic.title).small()) {
        app.post(
            event: blockchain.ux.user.account.entry.paragraph.button.icon.tap,
            context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
        )
    }
    .batch {
        set(blockchain.ux.user.account.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.user.account)
    }
    .identity(blockchain.ux.user.account.entry)
}

@ViewBuilder
func dashboardTrailingItem(app: AppProtocol) -> some View {
    IconButton(icon: .viewfinder.color(.semantic.title).small()) {
        app.post(
            event: blockchain.ux.scan.QR.entry.paragraph.button.icon.tap,
            context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
        )
    }
    .batch {
        set(blockchain.ux.scan.QR.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.scan.QR)
    }
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
        case blockchain.ux.prices where appMode == .trading:
            provideTradingPricesTab(
                tab: tab,
                store: store
            )
        case blockchain.ux.prices where appMode == .pkw:
            provideDefiPricesTab(
                tab: tab,
                store: store
            )
        case blockchain.ux.currency.exchange.dex where appMode == .pkw:
            provideDefiDexTab(
                tab: tab,
                store: store
            )
        case blockchain.ux.earn where appMode == .trading:
            provideTradingEarnTab(
                tab: tab,
                store: store
            )
        case blockchain.ux.nft.collection where appMode == .pkw:
            provideNftTab(
                tab: tab
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

// MARK: Provider

@available(iOS 15, *)
func provideTradingPricesTab(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    PricesSceneView(
        store: store.scope(
            state: \.tradingState.prices,
            action: DashboardContent.Action.tradingPrices
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}

@available(iOS 15, *)
func provideNftTab(
    tab: Tab
) -> some View {
    AssetListSceneView(
        store: .init(
            initialState: .empty,
            reducer: assetListReducer,
            environment: .init(
                assetProviderService: DIKit.resolve()
            )
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}

@available(iOS 15, *)
func provideTradingEarnTab(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    EarnDashboardView()
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}

@available(iOS 15, *)
func provideDefiPricesTab(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    PricesSceneView(
        store: store.scope(
            state: \.defiState.prices,
            action: DashboardContent.Action.defiPrices
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}

@available(iOS 15, *)
func provideDefiDexTab(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    DexDashboardView(
        store: store.scope(
            state: \.defiState.dex,
            action: DashboardContent.Action.defiDex
        )
    )
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}
