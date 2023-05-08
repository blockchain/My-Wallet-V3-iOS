// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation
import Localization
import SwiftUI

public struct SwapSelectAccountView: View {
    let store: StoreOf<SwapSelectAccount>
    @ObservedObject var viewStore: ViewStore<SwapSelectAccount.State, SwapSelectAccount.Action>
    public init(store: StoreOf<SwapSelectAccount>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                accountsSection
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                title: {
                    Text(String(
                        format: LocalizationConstants.Swap.selectAccount,
                        viewStore.currency.code
                    ))
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

    private var accountsSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEachStore(
                    store.scope(
                        state: \.accountRows,
                        action: SwapSelectAccount.Action.accountRow(id:action:)
                    )
                ) { rowStore in
                    SwapSelectAccountRowView(store: rowStore)
                }
            }
            .cornerRadius(16, corners: .allCorners)
            .padding(.horizontal, Spacing.padding2)
        }
    }
}
