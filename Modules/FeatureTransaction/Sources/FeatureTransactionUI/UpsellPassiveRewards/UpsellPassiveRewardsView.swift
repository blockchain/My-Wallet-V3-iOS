//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import BlockchainUI

public struct UpsellPassiveRewardsView: View {
    @BlockchainApp var app
    @Environment(\.context) var context
    @State var swappedCurrency: CryptoCurrency?
    @State private var url: URL?

    public init () {}

    public var body: some View {
        ZStack {
            Color
                .WalletSemantic
                .light
                .ignoresSafeArea()
            contentView
        }
        .bindings {
            subscribe($url, to: blockchain.ux.earn.discover.learn.more.url)
            subscribe($swappedCurrency , to: blockchain.ux.transaction.source.target.id)
        }
        .batch {
            set(blockchain.ux.upsell.after.successful.swap.learn.more.paragraph.button.small.minimal.tap.then.launch.url, to: url)
            set(blockchain.ux.upsell.after.successful.swap.maybe.later.paragraph.row.tap.then.close, to: true)
            set(blockchain.ux.upsell.after.successful.swap.start.earning.paragraph.row.tap.then.close, to: true)
            set(blockchain.ux.upsell.after.successful.swap.start.earning.paragraph.row.tap.then.navigate.to, to: blockchain.ux.user.rewards)
        }
    }

    private var contentView: some View {
        VStack {
            swappedCurrency?.logo(size: 88.pt)
                .padding(.bottom, Spacing.padding3)

            Text("Put your Asset \(swappedCurrency?.name ?? "") To Work")
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.bottom, Spacing.padding1)

            Text("With Passive Rewards, you can earn up to |X|% on your |ASSET|.")
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.bottom, Spacing.padding3)


            SmallMinimalButton(title: "Learn More") {
                Task {
                    try await app.set(blockchain.ux.earn.discover.learn.id, to: "staking")
                    app.post(event: blockchain.ux.upsell.after.successful.swap.learn.more.paragraph.button.small.minimal.tap)
                }
            }

            Spacer()

            ctaButtons
        }
        .padding(Spacing.padding2)
    }

    private var ctaButtons: some View {
        VStack(spacing: Spacing.padding2) {
            PrimaryButton(title: "Start earning") {
                $app.post(event: blockchain.ux.upsell.after.successful.swap.start.earning.paragraph.row.tap)
            }
            
            SecondaryButton(title: "Maybe Later") {
                $app.post(event: blockchain.ux.upsell.after.successful.swap.maybe.later.paragraph.row.tap)
                app.state.set(blockchain.ux.upsell.after.successful.swap.maybe.later.timestamp, to: Date())
            }
        }

        .padding(.bottom, Spacing.padding4)
    }
}

struct UpsellPassiveRewardsView_Previews: PreviewProvider {
    static var previews: some View {
        UpsellPassiveRewardsView()
    }
}
