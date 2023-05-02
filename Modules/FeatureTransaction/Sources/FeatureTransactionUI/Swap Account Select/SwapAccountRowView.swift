// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import SwiftUI

struct SwapAccountRowView: View {
    @BlockchainApp var app
    let store: StoreOf<SwapAccountRow>
    @ObservedObject var viewStore: ViewStore<SwapAccountRow.State, SwapAccountRow.Action>
    init(store: StoreOf<SwapAccountRow>) {
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
                inlineTagView: viewStore.networkTag,
                action: {
                    viewStore.send(.onAccountSelected)
                },
                leading: {
                    iconView(for: viewStore.currency)
                }
            )

            if viewStore.isLastRow == false {
                Divider()
                    .foregroundColor(.WalletSemantic.light)
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .bindings {
            subscribe(viewStore.binding(\.$balance), to: blockchain.coin.core.account[viewStore.assetCode].balance.total)
            subscribe(viewStore.binding(\.$networkLogo), to: blockchain.coin.core.account[viewStore.assetCode].network.logo)
            subscribe(viewStore.binding(\.$networkName), to: blockchain.coin.core.account[viewStore.assetCode].network.name)
        }
        .bindings {
            if let currency = viewStore.currency {
                subscribe(viewStore.binding(\.$price), to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
                subscribe(viewStore.binding(\.$delta), to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.delta.since.yesterday)
            }
        }
    }

    @MainActor
    @ViewBuilder
    func iconView(for currency: CryptoCurrency?) -> some View {
        if #available(iOS 15.0, *) {
            ZStack(alignment: .bottomTrailing) {
                AsyncMedia(url: currency?.assetModel.logoPngUrl, placeholder: { EmptyView() })
                    .frame(width: 24.pt, height: 24.pt)
                    .background(Color.WalletSemantic.light, in: Circle())

                if let currency = viewStore.currency, let networkLogo = viewStore.networkLogo,
                   currency.name != viewStore.networkName, viewStore.appMode == .pkw
                {
                    ZStack(alignment: .center) {
                        AsyncMedia(url: networkLogo, placeholder: { EmptyView() })
                            .frame(width: 12.pt, height: 12.pt)
                            .background(Color.WalletSemantic.background, in: Circle())
                        Circle()
                            .strokeBorder(Color.WalletSemantic.background, lineWidth: 1)
                            .frame(width: 13, height: 13)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}
