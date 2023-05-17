// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation
import SwiftUI

public struct SwapFromAccountSelectView: View {
    let store: StoreOf<SwapFromAccountSelect>
    @ObservedObject var viewStore: ViewStore<SwapFromAccountSelect.State, SwapFromAccountSelect.Action>
    public init(store: StoreOf<SwapFromAccountSelect>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                cryptoAssetsSection
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .onAppear {
                viewStore.send(.onAppear)
            }
            .superAppNavigationBar(
                title: {
                    Text(LocalizationConstants.Swap.swapFrom)
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
            LazyVStack(spacing: 0) {
                if viewStore.isLoading {
                    loadingSection
                } else {
                    ForEachStore(
                        store.scope(
                            state: \.swapAccountRows,
                            action: SwapFromAccountSelect.Action.accountRow(id:action:)
                        )
                    ) { rowStore in
                        SwapFromAccountRowView(store: rowStore)
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
}
