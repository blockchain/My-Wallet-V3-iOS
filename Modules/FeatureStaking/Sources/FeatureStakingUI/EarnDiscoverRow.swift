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

    @State var balance: MoneyValue?
    @State var exchangeRate: MoneyValue?

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
            byline: { EarnRowByline(product: product) }
        )
        .background(Color.semantic.background)
        .disabled(balance.isNotZeroOrDust(using: exchangeRate).isNil)
        .opacity(isEligible ? 1 : 0.5)
        .binding(
            .subscribe($balance, to: blockchain.user.trading[currency.code].account.balance.available),
            .subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
        )
        .batch(
            .set(id.paragraph.row.tap, to: action)
        )
        .onTapGesture {
            $app.post(
                event: id.paragraph.row.tap,
                context: [
                    blockchain.ui.type.action.then.enter.into.detents: [
                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                    ],
                    blockchain.ui.type.action.then.enter.into.grabber.visible: true
                ]
            )
        }
        .tableRowChevron(true)
    }

    var action: L_blockchain_ui_type_action.JSON {
        var action = L_blockchain_ui_type_action.JSON(.empty)
        if !isEligible {
            action.then.enter.into = $app[blockchain.ux.earn.discover.product.not.eligible]
        } else if balance.isNotZeroOrDust(using: exchangeRate) == true {
            action.then.emit = product.deposit(currency)
        } else {
            action.then.enter.into = $app[blockchain.ux.earn.discover.product.asset.no.balance]
        }
        return action
    }
}
