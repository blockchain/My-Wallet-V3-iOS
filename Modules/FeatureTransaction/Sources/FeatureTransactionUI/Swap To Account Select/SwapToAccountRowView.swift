// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import SwiftUI

struct SwapToAccountRowView: View {
    @BlockchainApp var app
    let store: StoreOf<SwapToAccountRow>
    @ObservedObject var viewStore: ViewStore<SwapToAccountRow.State, SwapToAccountRow.Action>
    init(store: StoreOf<SwapToAccountRow>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            SimpleBalanceRow(
                leadingTitle: viewStore.leadingTitle,
                trailingTitle: viewStore.trailingTitle,
                trailingDescription: viewStore.trailingDescriptionString,
                trailingDescriptionColor: viewStore.trailingDescriptionColor,
                inlineTagView: nil,
                action: {
                    viewStore.send(.onCryptoCurrencyTapped)
                },
                leading: {
                    viewStore.currency.logo(showNetworkLogo: !viewStore.isCustodial)
                }
            )

            if viewStore.isLastRow == false {
                PrimaryDivider()
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .sheet(isPresented: viewStore.binding(\.$showAccountSelect), content: {
            IfLetStore(
                store.scope(
                    state: \.swapSelectAccountState,
                    action: SwapToAccountRow.Action.onSelectAccountAction
                ),
                then: { store in
                    SwapSelectAccountView(store: store)
                }
            )
        })
        .bindings {
            subscribe(viewStore.binding(\.$price), to: blockchain.api.nabu.gateway.price.crypto[viewStore.currency.code].fiat.quote.value)
            subscribe(viewStore.binding(\.$delta), to: blockchain.api.nabu.gateway.price.crypto[viewStore.currency.code].fiat.delta.since.yesterday)
        }
    }
}
