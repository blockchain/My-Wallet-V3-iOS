// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Localization
import SwiftUI

@available(iOS 15, *)
public struct PricesSceneView: View {
    @ObservedObject var viewStore: ViewStoreOf<PricesScene>
    let store: StoreOf<PricesScene>
    @BlockchainApp var app

    public init(store: StoreOf<PricesScene>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                searchBarSection
                segmentedControl
                    .padding(.top, Spacing.padding2)

                ScrollView {
                    if viewStore.filter == .tradable {
                        topMoversSection
                    }
                    pricesSection
                        .padding(.top, Spacing.padding2)
                }
                .padding(.top, Spacing.padding3)
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                trailing: { [app] in dashboardTrailingItem(app: app) },
                scrollOffset: nil
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        })
    }

    private var topMoversSection: some View {
        IfLetStore(self.store.scope(
            state: \.topMoversState,
            action: PricesScene.Action.topMoversAction
        )) { store in
            DashboardTopMoversSectionView(
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
        PrimarySegmentedControl(
            items: [
                .init(title: LocalizationConstants.SuperApp.Prices.Filter.all, identifier: PricesScene.Filter.all),
                .init(title: LocalizationConstants.SuperApp.Prices.Filter.favorites, identifier: PricesScene.Filter.favorites),
                .init(title: LocalizationConstants.SuperApp.Prices.Filter.tradable, identifier: PricesScene.Filter.tradable)
            ],
            selection: viewStore.binding(\.$filter),
            backgroundColor: Color.semantic.light
        )
    }

    private var pricesSection: some View {
            LazyVStack(spacing: 0) {
                if let searchResults = viewStore.searchResults {
                    if searchResults.isEmpty {
                        noResultsView
                    } else {
                        ForEach(searchResults) { info in
                            SimpleBalanceRow(
                                leadingTitle: info.leadingTitle,
                                leadingDescription: info.leadingDescription,
                                trailingTitle: info.trailingTitle,
                                trailingDescription: info.trailingDescription,
                                trailingDescriptionColor: info.trailingDescriptionColor,
                                inlineTagView: info.tag.flatMap { TagView(text: $0, variant: .outline) },
                                action: {
                                    viewStore.send(.set(\.$isSearching, false))
                                    viewStore.send(.onAssetTapped(info))
                                },
                                leading: {
                                    AsyncMedia(
                                        url: info.url
                                    )
                                    .resizingMode(.aspectFit)
                                    .frame(width: 24.pt, height: 24.pt)
                                }
                            )
                            if info.id != viewStore.searchResults?.last?.id {
                                Divider()
                                    .foregroundColor(.WalletSemantic.light)
                            }
                        }
                    }
                } else {
                    loadingSection
                }
            }
            .cornerRadius(16, corners: .allCorners)
            .padding(.horizontal, Spacing.padding2)
            .padding(.bottom, 72.pt)
    }

    private var loadingSection: some View {
        Group {
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
        }
    }

    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(LocalizationConstants.SuperApp.Prices.Search.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.white)
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
    .id(blockchain.ux.user.account.entry.description)
    .accessibility(identifier: blockchain.ux.user.account.entry.description)
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
    .id(blockchain.ux.scan.QR.entry.description)
    .accessibility(identifier: blockchain.ux.scan.QR.entry.description)
}

extension PricesRowData {

    var leadingTitle: String { currency.name }
    var leadingDescription: String { currency.displayCode }

    var trailingTitle: String? { price?.toDisplayString(includeSymbol: true) }
    var trailingDescription: String? { priceChangeString }
    var trailingDescriptionColor: Color? { priceChangeColor }

    var url: URL? { currency.logoURL }

    var tag: String? { networkName }
}
