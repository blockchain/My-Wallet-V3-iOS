// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct EarnProductNotEligibleView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let story: L & I_blockchain_ux_earn_type_hub_product_not_eligible

    public init(story: L & I_blockchain_ux_earn_type_hub_product_not_eligible) {
        self.story = story
    }

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                IconButton(
                    icon: .closeCirclev2,
                    action: {
                        $app.post(event: story.article.plain.navigation.bar.button.close.tap)
                    }
                )
                .frame(width: 24.pt, height: 24.pt)
            }
            Spacer()
            Icon.interestCircle
                .color(.semantic.title)
                .circle(backgroundColor: .semantic.light)
                .frame(width: 88.pt, height: 88.pt)
            Spacer()
                .frame(minHeight: 24.pt)
            Text(L10n.notEligibleTitle)
                .typography(.title2)
                .foregroundColor(.semantic.title)
                .padding(.bottom, 4.pt)
            Do {
                let product: EarnProduct = try context.decode(blockchain.user.earn.product.id)
                let currency: CryptoCurrency = try context.decode(blockchain.user.earn.product.asset.id)
                Text(L10n.notEligibleMessage.interpolating(product.title, currency.code))
                    .typography(.body1)
                    .foregroundColor(.semantic.text)
                    .padding(.bottom)
                    .fixedSize(horizontal: false, vertical: true)
            } catch: { _ in
                EmptyView()
            }
            Spacer()
                .frame(minHeight: 16.pt)
            MinimalButton(
                title: L10n.goBack,
                action: {
                    $app.post(event: story.go.back.paragraph.button.minimal.tap)
                }
            )
        }
        .multilineTextAlignment(.center)
        .padding(16.pt)
        .post(lifecycleOf: story.article.plain)
        .batch {
            set(story.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            set(story.go.back.paragraph.button.minimal.tap.then.close, to: true)
        }
    }
}
