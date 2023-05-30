// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import SwiftUI

public struct AssetPickerView: View {

    let store: StoreOf<AssetPicker>
    @BlockchainApp var app

    public init(store: StoreOf<AssetPicker>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                searchBarSection
                ScrollView {
                    assetsSection
                        .padding(.top, Spacing.padding2)
                }
                .padding(.top, Spacing.padding1)
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                leading: { EmptyView() },
                title: { navigationTitle(viewStore) },
                trailing: { trailingItem(viewStore) },
                scrollOffset: nil
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        })
    }

    @ViewBuilder func navigationTitle(
        _ viewStore: ViewStoreOf<AssetPicker>
    ) -> some View {
        Text("Select Token")
            .typography(.body2)
            .foregroundColor(.semantic.title)
    }

    @ViewBuilder func trailingItem(
        _ viewStore: ViewStoreOf<AssetPicker>
    ) -> some View {
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
        .padding(.horizontal, Spacing.padding2)
        .padding(.top, Spacing.padding3)
    }

    private var assetsSection: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isSearching, viewStore.searchText.isNotEmpty {
                section(viewStore, data: viewStore.searchResults, sectionTitle: nil, showEmptyState: true)
            } else {
                VStack(spacing: 0) {
                    balancesSection(viewStore)
                    tokensSection(viewStore)
                }
            }
        }
        .padding(.horizontal, Spacing.padding2)
    }

    private func balancesSection(_ viewStore: ViewStoreOf<AssetPicker>) -> some View {
        section(viewStore, data: viewStore.balances, sectionTitle: "Your Assets", showEmptyState: false)
    }

    private func tokensSection(_ viewStore: ViewStoreOf<AssetPicker>) -> some View {
        section(viewStore, data: viewStore.tokens, sectionTitle: "All tokens", showEmptyState: false)
    }

    @ViewBuilder
    private func section(
        _ viewStore: ViewStoreOf<AssetPicker>,
        data: [AssetRowData],
        sectionTitle: String?,
        showEmptyState: Bool
    ) -> some View {
        if data.isNotEmpty {
            VStack(spacing: 0) {
                if let sectionTitle {
                    sectionHeader(sectionTitle)
                }
                LazyVStack(spacing: 0) {
                    ForEach(data) { assetRowData in
                        row(viewStore, data: assetRowData)
                        if assetRowData.id != data.last?.id {
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
    func sectionHeader(_ value: String) -> some View {
        HStack {
            Text(value)
                .typography(.body2)
                .foregroundColor(.semantic.body)
            Spacer()
        }
        .padding(.vertical, Spacing.padding1)
    }

    private func row(
        _ viewStore: ViewStoreOf<AssetPicker>,
        data: AssetRowData
    ) -> some View {
        AssetPickerCellView(
            data: data,
            action: {
                viewStore.send(.set(\.$isSearching, false))
                viewStore.send(.onAssetTapped(data))
            }
        )
    }

    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(L10n.AssetPicker.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
    }
}

struct AssetPickerView_Previews: PreviewProvider {

    private static var app = App.preview.withPreviewData()

    static var previews: some View {
        AssetPickerView(
            store: Store(
                initialState: AssetPicker.State(
                    balances: [.init(value: .one(currency: .ethereum))],
                    tokens: [.bitcoin, .ethereum],
                    searchText: "",
                    isSearching: false
                ),
                reducer: AssetPicker()
            )
        )
        .app(app)
    }
}
