// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation
import SwiftUI

public struct SwapToAccountSelectView: View {
    let store: StoreOf<SwapToAccountSelect>
    @ObservedObject var viewStore: ViewStore<SwapToAccountSelect.State, SwapToAccountSelect.Action>
    public init(store: StoreOf<SwapToAccountSelect>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                searchBarSection
                if viewStore.hasAccountSegmentedControl {
                    segmentedAccountControl
                }
                cryptoAssetsSection
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .onAppear {
                viewStore.send(.onAppear)
            }
            .superAppNavigationBar(
                title: {
                    Text(LocalizationConstants.Swap.swapTo)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                },
                trailing: {
                    IconButton(icon: .closev2.circle().small()) {
                        viewStore.send(.onCloseTapped)
                    }
                },
                scrollOffset: nil
            )
        })
    }

    private var cryptoAssetsSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewStore.isLoading {
                    loadingSection
                } else {
                    if viewStore.searchResults.isEmpty {
                        noResultsView
                    } else {
                        ForEachStore(
                            store.scope(
                                state: \.searchResults,
                                action: SwapToAccountSelect.Action.accountRow(id:action:)
                            )
                        ) { rowStore in
                            SwapToAccountRowView(store: rowStore)
                        }
                    }
                }
            }
            .cornerRadius(16, corners: .allCorners)
            .padding(.horizontal, Spacing.padding2)
        }
    }

    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(LocalizationConstants.SuperApp.AllAssets.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    private var loadingSection: some View {
        Group {
            redactedBalanceRow
            PrimaryDivider()
            redactedBalanceRow
            PrimaryDivider()
            redactedBalanceRow
        }
    }

    private var redactedBalanceRow: some View {
        SimpleBalanceRow(
            leadingTitle: "Placeholder",
            leadingDescription: "Placeholder",
            trailingTitle: "Placeholder",
            trailingDescription: nil,
            leading: {}
        )
        .redacted(reason: .placeholder)
    }

    private var searchBarSection: some View {
        SearchBar(
            text: viewStore.binding(\.$searchText),
            isFirstResponder: viewStore.binding(\.$isSearching),
            cancelButtonText: LocalizationConstants.SuperApp.AllAssets.cancelButton,
            placeholder: LocalizationConstants.SuperApp.AllAssets.searchPlaceholder
        )
        .frame(height: 48)
        .padding(.horizontal, Spacing.padding2)
        .padding(.vertical, Spacing.padding3)
    }

    private var segmentedAccountControl: some View {
        LargeSegmentedControl(
            items: [
                LargeSegmentedControl.Item(
                    title: NonLocalizedConstants.defiWalletTitle,
                    identifier: blockchain.ux.asset.account.swap.segment.filter.defi[]
                ),
                LargeSegmentedControl.Item(
                    title: LocalizationConstants.SuperApp.trading,
                    icon: Icon.blockchain,
                    identifier: blockchain.ux.asset.account.swap.segment.filter.trading[]
                )
            ], selection: viewStore.binding(\.$controlSelection)
        )
        .padding(.horizontal, Spacing.padding3)
    }
}
