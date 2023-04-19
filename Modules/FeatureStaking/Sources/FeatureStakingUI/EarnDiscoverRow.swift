// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
struct EarnDiscoverRow: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let id: L & I_blockchain_ux_earn_type_hub_product_asset

    @State var tradingBalance: MoneyValue?
    @State var pkwBalance: MoneyValue?
    @State var exchangeRate: MoneyValue?
    @State var isNew: Bool = false

    let product: EarnProduct
    let currency: CryptoCurrency
    let isEligible: Bool

    var body: some View {
        TableRow(
            leading: {
                AsyncMedia(url: currency.logoURL)
                    .frame(width: 24.pt)
            },
            title: TableRowTitle(currency.name),
            byline: { EarnRowByline(product: product, variant: .full) },
            trailing: {
                if isNew {
                    TagView(text: L10n.new, variant: .new)
                }
            }
        )
        .background(Color.semantic.background)
        .disabled(
            tradingBalance.isNotZeroOrDust(using: exchangeRate).isNil
            && pkwBalance.isNotZeroOrDust(using: exchangeRate).isNil
        )
        .opacity(isEligible ? 1 : 0.5)
        .bindings {
            subscribe($tradingBalance, to: blockchain.user.trading[currency.code].account.balance.available)
            subscribe($pkwBalance, to: blockchain.user.pkw.asset[currency.code].balance)
            subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
        }
        .bindings {
            subscribe($isNew, to: id.is.new)
        }
        .batch {
            set(id.paragraph.row.tap, to: action)
        }
        .onTapGesture {
            $app.post(
                event: id.paragraph.row.tap,
                context: [
                    blockchain.ui.type.action.then.enter.into.detents: [
                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                    ]
                ]
            )
        }
        .tableRowChevron(true)
    }

    var action: L_blockchain_ui_type_action.JSON {
        var action = L_blockchain_ui_type_action.JSON(.empty)
        let tradingIsNotZeroOrDust = tradingBalance.isNotZeroOrDust(using: exchangeRate) ?? false
        let pkwIsNotZeroOrDust = pkwBalance.isNotZeroOrDust(using: exchangeRate) ?? false
        if !isEligible {
            action.then.enter.into = $app[blockchain.ux.earn.discover.product.not.eligible]
        } else if tradingIsNotZeroOrDust || pkwIsNotZeroOrDust {
            action.then.emit = product.deposit(currency)
        } else {
            action.then.enter.into = $app[blockchain.ux.earn.discover.product.asset.no.balance]
        }
        return action
    }
}
