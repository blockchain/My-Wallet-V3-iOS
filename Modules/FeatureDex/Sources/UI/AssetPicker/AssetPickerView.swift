// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureDexDomain
import MoneyKit
import SwiftUI

public struct AssetPickerView: View {

    let store: StoreOf<AssetPicker>
    @ObservedObject var viewStore: ViewStoreOf<AssetPicker>

    init(store: StoreOf<AssetPicker>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    @ViewBuilder
    public var body: some View {
        VStack(spacing: Spacing.padding3) {
            searchBarSection
            transactionInProgressCard
            ScrollView {
                assetsSection
            }
        }
        .padding(.horizontal, Spacing.padding2)
        .background(Color.semantic.light.ignoresSafeArea())
        .superAppNavigationBar(
            leading: { EmptyView() },
            title: { navigationTitle },
            trailing: { trailingItem },
            scrollOffset: nil
        )
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    @ViewBuilder
    private var navigationTitle: some View {
        Text("Select Token")
            .typography(.body2)
            .foregroundColor(.semantic.title)
    }

    @ViewBuilder
    private var trailingItem: some View {
        IconButton(icon: .closeCirclev3.color(.black)) {
            viewStore.send(.onDismiss)
        }
        .frame(width: 20, height: 20)
    }

    private var searchBarSection: some View {
        WithViewStore(store) { viewStore in
            SearchBar(
                text: viewStore.binding(\.$searchText),
                isFirstResponder: viewStore.binding(\.$isSearching),
                cancelButtonText: "Cancel",
                placeholder: "Search"
            )
        }
        .frame(height: 48)
        .padding(.top, Spacing.padding3)
    }

    @ViewBuilder
    private var assetsSection: some View {
        if viewStore.isSearching, viewStore.searchText.isNotEmpty {
            section(
                data: viewStore.searchResults,
                sectionTitle: nil,
                showEmptyState: true
            )
        } else {
            VStack(spacing: Spacing.padding1) {
                section(
                    data: viewStore.balances,
                    sectionTitle: L10n.AssetPicker.yourAssets,
                    showEmptyState: false
                )
                section(
                    data: viewStore.tokens,
                    sectionTitle: L10n.AssetPicker.allTokens,
                    showEmptyState: false
                )
            }
        }
    }

    @ViewBuilder
    private func section(
        data: [AssetPicker.RowData],
        sectionTitle: String?,
        showEmptyState: Bool
    ) -> some View {
        if data.isNotEmpty {
            VStack(spacing: 0) {
                if let sectionTitle {
                    sectionHeader(sectionTitle)
                }
                LazyVStack(spacing: 0) {
                    ForEach(data) { RowData in
                        row(data: RowData)
                        if RowData.id != data.last?.id {
                            PrimaryDivider()
                        }
                    }
                }
                .cornerRadius(16, corners: .allCorners)
            }
        } else if showEmptyState {
            noResultsView
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func sectionHeader(_ value: String) -> some View {
        HStack {
            Text(value)
                .typography(.body2)
                .foregroundColor(.semantic.body)
            Spacer()
        }
        .padding(.bottom, Spacing.padding1)
    }

    @ViewBuilder
    private func row(
        data: AssetPicker.RowData
    ) -> some View {
        AssetPickerView.Cell(
            data: data,
            action: {
                viewStore.send(.set(\.$isSearching, false))
                viewStore.send(.onAssetTapped(data))
            }
        )
    }

    @ViewBuilder
    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(L10n.AssetPicker.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.semantic.background)
        .cornerRadius(16, corners: .allCorners)
    }

    @ViewBuilder
    private var transactionInProgressCard: some View {
        if viewStore.networkTransactionInProgressCard {
            AlertCard(
                title: L10n.TransactionInProgress.title,
                message: L10n.TransactionInProgress.body
                    .interpolating(viewStore.currentNetwork.networkConfig.name),
                variant: .default,
                isBordered: false,
                backgroundColor: .semantic.background,
                onCloseTapped: {
                    viewStore.send(.didTapCloseInProgressCard)
                }
            )
        }
    }
}

struct AssetPickerView_Previews: PreviewProvider {

    private static var app = App.preview.withPreviewData()

    static var previews: some View {
        AssetPickerView(
            store: Store(
                initialState: AssetPicker.State(
                    balances: AssetPickerView_Cell_Previews.balances,
                    tokens: AssetPickerView_Cell_Previews.tokens,
                    currentNetwork: .init(networkConfig: .ethereum, nativeAsset: .ethereum),
                    searchText: "",
                    isSearching: false
                ),
                reducer: AssetPicker()
            )
        )
        .app(app)
    }
}
