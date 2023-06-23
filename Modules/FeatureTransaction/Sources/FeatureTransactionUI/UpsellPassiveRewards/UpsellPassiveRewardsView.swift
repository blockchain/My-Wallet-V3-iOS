//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import BlockchainUI

public struct UpsellPassiveRewardsView: View {
    @BlockchainApp var app
    @Environment(\.context) var context
    @State var swappedCurrency: CryptoCurrency? = .bitcoin
    @State private var url: URL?
    @State private var rate: Double?

    var rateDisplayString: String {
        let rateNumber =  NSNumber(value: rate ?? 0)
        return percentageFormatter.string(from: rateNumber) ?? "0%"
    }

    var percentageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 1
        return formatter
    }

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
            if let swappedCurrency {
                subscribe($rate, to: blockchain.user.earn.product["savings"].asset[swappedCurrency.code].rates.rate)
            }
        }
        .batch {
            if let url {
                set(blockchain.ux.upsell.after.successful.swap.learn.more.paragraph.button.small.minimal.tap.then.launch.url, to: url)
            }
            set(blockchain.ux.upsell.after.successful.swap.maybe.later.paragraph.row.tap.then.close, to: true)
            set(blockchain.ux.upsell.after.successful.swap.start.earning.paragraph.row.tap.then.close, to: true)
            set(blockchain.ux.upsell.after.successful.swap.start.earning.paragraph.row.tap.then.emit, to: blockchain.ux.home[AppMode.trading.rawValue].tab[blockchain.ux.earn].select)
        }
    }

    private var contentView: some View {
        VStack {
            ZStack(alignment: .bottomTrailing, content: {
                swappedCurrency?
                    .logo(size: 88.pt)
                Icon
                    .walletPercent
                    .medium()
                    .color(.semantic.light)
                    .circle(backgroundColor: .semantic.primary)
                    .background(
                        Circle()
                            .stroke(Color.semantic.light, lineWidth: 14)
                    )
            })
            .padding(.bottom, Spacing.padding3)

            Text("Put your \(swappedCurrency?.name ?? "") to work")
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.bottom, Spacing.padding1)

            Text("With Passive Rewards, you can earn up to \(rateDisplayString) on your \(swappedCurrency?.name ?? "")")
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.bottom, Spacing.padding3)


            SmallMinimalButton(title: "Learn More") {
                Task {
                    try await app.set(blockchain.ux.earn.discover.learn.id, to: "savings")
                    app.post(event: blockchain.ux.upsell.after.successful.swap.learn.more.paragraph.button.small.minimal.tap)
                }
            }

            Spacer()

            ctaButtons
        }
        .padding(Spacing.padding3)
    }

    private var ctaButtons: some View {
        VStack(spacing: Spacing.padding2) {
            PrimaryButton(title: "Start earning") {
                $app.post(event: blockchain.ux.upsell.after.successful.swap.start.earning.paragraph.row.tap)
            }
            
            PrimaryWhiteButton(title: "Maybe Later") {
                $app.post(event: blockchain.ux.upsell.after.successful.swap.maybe.later.paragraph.row.tap)
                app.state.set(blockchain.ux.upsell.after.successful.swap.maybe.later.timestamp, to: Date())
            }
        }
    }
}


struct UpsellPassiveRewardsView_Previews: PreviewProvider {
    static var previews: some View {
        UpsellPassiveRewardsView()
            .app(App.preview)
            .context([blockchain.ux.transaction.source.target.id: 1])
    }
}
