// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation

public struct SwapSelectAccountRowView: View {
    @BlockchainApp var app
    let store: StoreOf<SwapSelectAccountRow>
    @ObservedObject var viewStore: ViewStore<SwapSelectAccountRow.State, SwapSelectAccountRow.Action>
    init(store: StoreOf<SwapSelectAccountRow>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        VStack(spacing: 0) {
            PrimaryRow(
                title: viewStore.label ?? "",
                subtitle: viewStore.leadingDescription,
                leading: {
                    iconView(for: viewStore.currency)
                },
                action: {
                    viewStore.send(.onAccountTapped)
                }
            )

            if viewStore.isLastRow == false {
                PrimaryDivider()
            }
        }
        .bindings {
            subscribe(viewStore.binding(\.$label), to: blockchain.coin.core.account[viewStore.accountId].label)
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

                if let networkLogo = viewStore.networkLogo,
                   viewStore.currency.name != viewStore.networkName, viewStore.appMode == .pkw
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
