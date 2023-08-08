// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import SwiftUI

struct SwapFromAccountRowView: View {
    @BlockchainApp var app
    let store: StoreOf<SwapFromAccountRow>
    @ObservedObject var viewStore: ViewStore<SwapFromAccountRow.State, SwapFromAccountRow.Action>
    init(store: StoreOf<SwapFromAccountRow>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        let _ = print("💪 body accountId \(viewStore.accountId)")
        let _ = print("🤗 \(viewStore.accountId) \(blockchain.coin.core.account[viewStore.accountId].balance.total.key().string)")
        VStack(spacing: 0) {
            SimpleBalanceRow(
                leadingTitle: viewStore.leadingTitle,
                trailingTitle: viewStore.trailingTitle,
                trailingDescription: viewStore.trailingDescriptionString,
                trailingDescriptionColor: viewStore.trailingDescriptionColor,
                inlineTagView: viewStore.networkTag,
                action: {
                    viewStore.send(.onAccountSelected)
                },
                leading: {
                    viewStore.currency?.logo()
                }
            )

            if viewStore.isLastRow == false {
                PrimaryDivider()
            }
        }
        .bindings(managing: update(_:)) {
            subscribe(viewStore.binding(\.$balance).print("🤔 \(viewStore.accountId)"), to: blockchain.coin.core.account[viewStore.accountId].balance.total)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    func update(_ update: Bindings.Update) {
        switch update {
        case .request(let binding):
            print("💪 request \(viewStore.accountId) \(binding.description)")

        case .updateError(_, let error):
            print("💪 update error \(error.localizedDescription)")

        case .update(let binding) :
            print("💪 update binding \(viewStore.accountId) \(binding.reference) \(binding.result)")

        case .didSynchronize(let binding):
            print("💪 \(viewStore.accountId) \(binding.description)")

        }
    }
}
