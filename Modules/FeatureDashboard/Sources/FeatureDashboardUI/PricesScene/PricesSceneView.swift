// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import ComposableArchitecture
import FeatureDashboardDomain
import FeatureProductsDomain
import FeatureTopMoversCryptoUI
import Localization
import SwiftUI

public struct PricesSceneView: View {
    @ObservedObject var viewStore: ViewStoreOf<PricesScene>
    let store: StoreOf<PricesScene>
    @BlockchainApp var app
    @State var isTradingEnabled = true

    public init(store: StoreOf<PricesScene>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                searchBarSection
                segmentedControl
                    .padding(.top, Spacing.padding2)
                List {
                    if viewStore.filter == .tradable, !viewStore.isSearching {
                        Section {
                            topMoversSection
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: -20, leading: 0, bottom: 0, trailing: 0))
                        .textCase(nil)
                    }

                    Section {
                        pricesSection
                    }
                    .listRowBackground(Color.semantic.background)
                    .listRowInsets(.zero)
                    .textCase(nil)
                }
                .environment(\.defaultMinListHeaderHeight, 0)
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                trailing: { [app] in dashboardTrailingItem(app: app) },
                scrollOffset: nil
            )
            .task {
                await viewStore.send(.onAppear).finish()
            }
            .bindings {
                subscribe($isTradingEnabled, to: blockchain.api.nabu.gateway.user.products.product[ProductIdentifier.useTradingAccount].is.eligible)
            }
        })
    }

    private var topMoversSection: some View {
        IfLetStore(store.scope(
            state: \.topMoversState,
            action: PricesScene.Action.topMoversAction
        )) { store in
            TopMoversSectionView(
                store: store
            )
            .padding(.horizontal, Spacing.padding2)
        }
    }

    private var searchBarSection: some View {
        SearchBar(
            text: viewStore.binding(\.$searchText),
            isFirstResponder: viewStore.binding(\.$isSearching),
            cancelButtonText: LocalizationConstants.SuperApp.Prices.Search.cancelButton,
            placeholder: LocalizationConstants.SuperApp.Prices.Search.searchPlaceholder
        )
        .frame(height: 48)
        .padding(.horizontal, Spacing.padding2)
        .padding(.top, Spacing.padding3)
    }

    private var segmentedControl: some View {
        let items: [PrimarySegmentedControl.Item] = isTradingEnabled ?
        [
            .init(title: LocalizationConstants.SuperApp.Prices.Filter.all, identifier: PricesScene.Filter.all),
            .init(title: LocalizationConstants.SuperApp.Prices.Filter.favorites, identifier: PricesScene.Filter.favorites),
            .init(title: LocalizationConstants.SuperApp.Prices.Filter.tradable, identifier: PricesScene.Filter.tradable)
        ] :
        [
            .init(title: LocalizationConstants.SuperApp.Prices.Filter.all, identifier: PricesScene.Filter.all),
            .init(title: LocalizationConstants.SuperApp.Prices.Filter.favorites, identifier: PricesScene.Filter.favorites)
        ]
        return PrimarySegmentedControl(
            items: items,
            selection: viewStore.binding(\.$filter),
            backgroundColor: Color.semantic.light
        )
    }

    struct Row: View {

        let info: PricesRowData

        var body: some View {
            if #available(iOS 16.0, *) {
                content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
            } else {
                content
            }
        }

        var content: some View {
            MoneyValue.one(currency: info.currency)
                .rowView(.delta) {
                    Text(info.currency.displayCode)
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)
                }
        }
    }

    @ViewBuilder private var pricesSection: some View {
        if let searchResults = viewStore.searchResults {
            if searchResults.isEmpty {
                noResultsView
            } else {
                ForEach(Array(searchResults.enumerated()), id: \.element) { i, info in
                    Row(info: info)
                        .onTapGesture {
                            viewStore.send(.set(\.$isSearching, false))
                            viewStore.send(.onAssetTapped(info))
                        }
                        .context([blockchain.ux.dashboard.is.hiding.balance: false])
                        .listRowInsets(i == searchResults.count ? .init(top: 0, leading: 0, bottom: 44, trailing: 0) : .zero)
                }
            }
        } else {
            loadingSection.redacted(reason: .placeholder)
        }
    }

    private var trailingIconTrendingIcon: (Icon, Color) {
        (Icon.fireFilled, Color.WalletSemantic.warningMuted)
    }

    @ViewBuilder private var loadingSection: some View {
        MoneyValue.one(currency: CryptoCurrency.bitcoin)
            .rowView(.delta)
        MoneyValue.one(currency: CryptoCurrency.ethereum)
            .rowView(.delta)
        MoneyValue.one(currency: CryptoCurrency.bitcoinCash)
            .rowView(.delta)
    }

    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(LocalizationConstants.SuperApp.Prices.Search.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.semantic.background)
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
    .id(blockchain.ux.user.account.entry.description)
    .accessibility(identifier: blockchain.ux.user.account.entry.description)
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
    .id(blockchain.ux.scan.QR.entry.description)
    .accessibility(identifier: blockchain.ux.scan.QR.entry.description)
}
