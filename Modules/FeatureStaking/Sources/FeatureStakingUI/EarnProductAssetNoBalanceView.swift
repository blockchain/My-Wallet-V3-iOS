// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct EarnProductAssetNoBalanceView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let story: L & I_blockchain_ux_earn_type_hub_product_asset_no_balance

    public init(story: L & I_blockchain_ux_earn_type_hub_product_asset_no_balance) {
        self.story = story
    }

    public var body: some View {
        Do {
            let currency: CryptoCurrency = try context.decode(blockchain.user.earn.product.asset.id)
            VStack {
                HStack {
                    Spacer()
                    IconButton(
                        icon: .closeCirclev2,
                        action: {
                            $app.post(event: story.article.plain.navigation.bar.button.close.tap)
                        }
                    )
                    .frame(width: 24.pt)
                }
                Spacer()
                AsyncMedia(url: currency.logoURL)
                    .frame(width: 88.pt, height: 88.pt)
                Spacer()
                    .frame(minHeight: 24.pt)
                Text(L10n.noBalanceTitle.interpolating(currency.code))
                    .typography(.title2)
                    .foregroundColor(.semantic.title)
                    .padding(.bottom, 4.pt)
                Text(L10n.noBalanceMessage.interpolating(currency.code))
                    .typography(.body1)
                    .foregroundColor(.semantic.text)
                    .padding(.bottom)
                Spacer()
                    .frame(minHeight: 24.pt)
                PrimaryButton(
                    title: "Buy \(currency.code)",
                    action: {
                        $app.post(event: story.buy.paragraph.button.primary.tap)
                    }
                )
                .padding(.bottom, 16.pt)
                MinimalButton(
                    title: "Receive \(currency.code)",
                    action: {
                        $app.post(
                            event: story.receive.paragraph.button.minimal.tap,
                            context: [
                                blockchain.ux.asset.id: currency.code,
                                blockchain.coin.core.account.id: currency.code,
                                blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                            ]
                        )
                    }
                )
            }
            .multilineTextAlignment(.center)
            .batch {
                set(story.article.plain.navigation.bar.button.close.tap.then.close, to: true)
                set(story.buy.paragraph.button.primary.tap.then.emit, to: blockchain.ux.asset[currency.code].buy)
                set(
                    story.receive.paragraph.button.minimal.tap.then.enter.into,
                    to: blockchain.ux.currency.receive.address
                )
            }
        } catch: { _ in
            EmptyView()
        }
            .padding(16.pt)
            .post(lifecycleOf: story.article.plain)
    }
}

let percentageFormatter: NumberFormatter = with(NumberFormatter()) { formatter in
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 1
}
