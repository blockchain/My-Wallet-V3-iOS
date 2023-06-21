//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

@available(iOS 15.0, *)
public struct ProductRouterView: View {

    @BlockchainApp var app
    @Environment(\.scheduler) var scheduler
    @Environment(\.dismiss) var dismiss

    public init() {}

    @ViewBuilder
    public var body: some View {
        ScrollView {
            rows
        }
        .background(Color.WalletSemantic.light.ignoresSafeArea())
        .navigationTitle(L10n.ProductRouter.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var rows: some View {
        VStack(spacing: 0) {
            blockchainComSwapRow
            PrimaryDivider()
            dexSwapRow
        }
        .padding(.horizontal, Spacing.padding2)
        .batch {
            set(blockchain.ux.currency.exchange.router.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    @ViewBuilder
    private var blockchainComSwapRow: some View {
        Button(
            action: {
                $app.post(event: blockchain.ux.currency.exchange.router.blockchain.swap.paragraph.row.tap)
            },
            label: {
                TableRow(
                    leading: {
                        Icon.walletSwap.small()
                    },
                    title: TableRowTitle(L10n.ProductRouter.Swap.title),
                    byline: TableRowByline(L10n.ProductRouter.Swap.body),
                    footer: {
                        Image("logos-array-blockchain-com-swap", bundle: .module)
                            .padding(.leading, Spacing.padding5)
                    }
                )
                .background(Color.semantic.background)
                .tableRowChevron(true)
                .cornerRadius(Spacing.padding2, corners: [.topLeft, .topRight])
            }
        )
        .batch {
          set(blockchain.ux.currency.exchange.router.blockchain.swap.paragraph.row.tap.then.navigate.to, to: blockchain.ux.transaction["swap"])
        }
    }

    @ViewBuilder
    private var dexSwapRow: some View {
        Button(
            action: {
                let ux = blockchain.ux
                let dex = ux.currency.exchange.dex
                dismiss()
                // Takes user back home.
                $app.post(event: ux.home.return.home)
                // Switch tab to DEX.
                $app.post(event: ux.home[AppMode.pkw.rawValue].tab[dex].select)
            },
            label: {
                TableRow(
                    leading: {
                        Icon.coins.small()
                    },
                    title: .init(L10n.ProductRouter.Dex.title),
                    byline: .init(L10n.ProductRouter.Dex.body),
                    trailing: { TagView(text: L10n.ProductRouter.Dex.new, variant: .new) },
                    footer: {
                        Image("logos-array-dex-swap", bundle: .module)
                            .padding(.leading, Spacing.padding5)
                    }
                )
                .background(Color.semantic.background)
                .tableRowChevron(true)
                .cornerRadius(Spacing.padding2, corners: [.bottomLeft, .bottomRight])
            }
        )
    }
}

@available(iOS 15.0, *)
struct ProductRouterView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            ProductRouterView()
                .app(App.preview)
        }
    }
}
