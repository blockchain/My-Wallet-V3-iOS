//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

struct ProductRouterView: View {

    @BlockchainApp var app
    @Environment(\.scheduler) var scheduler
    @Environment(\.dismiss) var dismiss

    private var router = blockchain.ux.currency.exchange.router

    @ViewBuilder
    var body: some View {
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
            set(router.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    @ViewBuilder
    private var blockchainComSwapRow: some View {
        Button(
            action: {
                $app.post(event: router.blockchain.swap.paragraph.row.tap)
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
            set(router.blockchain.swap.paragraph.row.tap.then.navigate.to, to: blockchain.ux.transaction["swap"])}
    }

    @ViewBuilder
    private var dexSwapRow: some View {
        Button(
            action: {
                $app.post(event: router.dex.paragraph.row.tap)
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
        .batch {
            set(router.dex.paragraph.row.tap.then.close, to: true)
            set(
                router.dex.paragraph.row.tap.then.emit,
                to: blockchain.ux.home[AppMode.pkw.rawValue].tab[blockchain.ux.currency.exchange.dex].select
            )
        }
    }
}

struct ProductRouterView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            ProductRouterView()
                .app(App.preview)
        }
    }
}
