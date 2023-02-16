//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI
import UIComponentsKit

public struct ProductRouterView: View {

    @BlockchainApp var app
    @Environment(\.scheduler) var scheduler

    public init() { }

    public var body: some View {
        scrollView
            .navigationTitle("Select an option")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                SectionHeader(
                    title: "Choose how you’d like to swap",
                    variant: .regular
                )
                rows
            }
        }
        .background(Color.WalletSemantic.light.ignoresSafeArea())
    }

    private var rows: some View {
        Group {
            blockchainComSwapRow
            PrimaryDivider()
            dexSwapRow
        }
        .padding(.horizontal, Spacing.padding2)
        .batch(
            .set(blockchain.ux.currency.exchange.router.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        )
    }

    private var blockchainComSwapRow: some View {
        Button(
            action: { [app] in
                Task {
                    app.post(event: blockchain.ux.currency.exchange.router.article.plain.navigation.bar.button.close.tap)
                    try await scheduler.sleep(for: .milliseconds(300))
                    app.post(event: blockchain.ux.frequent.action.swap)
                }
            },
            label: {
                TableRow(
                    leading: {
                        Icon.walletSwap.small()
                    },
                    title: .init("Blockchain.com Swap"),
                    byline: .init("Cross-chain, limited token pairs"),
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
    }

    private var dexSwapRow: some View {
        Button(
            action: { [app] in
                app.post(
                    event: blockchain.ux.currency.exchange.router.article.plain.navigation.bar.button.close.tap
                )
                app.post(
                    event: blockchain.ux.home[AppMode.pkw.rawValue].tab[blockchain.ux.prices].select
                )
            },
            label: {
                TableRow(
                    leading: {
                        Icon.coins.small()
                    },
                    title: .init("DEX Swap"),
                    byline: .init("Single-chain, thousands of tokens on Ethereum"),
                    trailing: { TagView(text: "New", variant: .new) },
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

struct ProductRouterView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            ProductRouterView()
        }
    }
}
