// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
struct EarnPortfolioRow: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let id: L & I_blockchain_ux_earn_type_hub_product_asset

    let product: EarnProduct
    let currency: CryptoCurrency

    @State var balance: MoneyValue?

    var body: some View {
        TableRow(
            leading: {
                currency.logo(size: 24.pt)
            },
            title: TableRowTitle(currency.name),
            byline: { EarnRowByline(product: product) },
            trailing: {
                if let balance {
                    balance.quoteView(alignment: .trailing)
                } else {
                    ProgressView()
                }
            }
        )
        .background(Color.semantic.background)
        .bindings {
            subscribe($balance, to: blockchain.user.earn.product.asset.account.balance)
        }
        .batch {
            set(id.paragraph.row.tap.then.enter.into, to: $app[blockchain.ux.earn.portfolio.product.asset.summary])
        }
        .onTapGesture {
            $app.post(event: id.paragraph.row.tap)
        }
    }
}

struct EarnRowByline: View {

    let product: EarnProduct
    @State var rate: Double?

    var body: some View {
        HStack {
            if let rate {
                Text(percentageFormatter.string(from: NSNumber(value: rate)) ?? "0%")
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            }
            TagView(
                text: product.title,
                variant: .outline
            )
        }
        .bindings {
            subscribe($rate, to: blockchain.user.earn.product.asset.rates.rate)
        }
    }
}
