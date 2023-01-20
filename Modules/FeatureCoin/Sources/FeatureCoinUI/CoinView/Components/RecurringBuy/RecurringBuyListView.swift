import BlockchainComponentLibrary
import BlockchainNamespace
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI

struct RecurringBuyListView: View {

    private typealias L01n = LocalizationConstants.Coin.RecurringBuy

    @BlockchainApp var app
    @Environment(\.context) var context

    let buys: [RecurringBuy]?

    var body: some View {
        VStack {
            if buys == nil {
                loading()
            }
            if let buys = buys, buys.isEmpty {
                card()
            }
            if let buys = buys, buys.isNotEmpty {
                SectionHeader(title: L01n.Header.recurringBuys)
                    .padding([.top], 8.pt)
                ForEach(buys) { buy in
                    rowForRecurringBuy(buy)
                    if buy != buys.last {
                        PrimaryDivider()
                    }
                }
            }
        }
    }

    @ViewBuilder func rowForRecurringBuy(_ buy: RecurringBuy) -> some View {
        TableRow(
            leading: {
                if let currency = CryptoCurrency(code: buy.asset) {
                    Icon.walletBuy
                        .color(.white)
                        .circle(backgroundColor: currency.color)
                        .frame(width: 24)
                } else {
                    EmptyView()
                }
            },
            title: buy.amount + " \(buy.recurringBuyFrequency)",
            byline: L01n.Row.frequency + buy.nextPaymentDate
        )
        .padding([.leading, .trailing], 16.pt)
        .contentShape(Rectangle())
        .onTapGesture {
            app.post(
                event: blockchain.ux.asset.recurring.buy.summary[].ref(to: context),
                context: [
                    blockchain.ux.asset.recurring.buy.summary.id: buy.id
                ]
            )
        }
    }

    @ViewBuilder func card() -> some View {
        AlertCard(
            title: L01n.LearnMore.title,
            message: L01n.LearnMore.description,
            footer: {
                SmallSecondaryButton(title: L01n.LearnMore.action) {
                    Task(priority: .userInitiated) {
                        if let url = try? await app.get(blockchain.app.configuration.asset.recurring.buy.learn.more.url) as URL {
                            app.post(
                                event: blockchain.ux.asset.recurring.buy.visit.website[].ref(to: context),
                                context: [blockchain.ux.asset.recurring.buy.visit.website.url[]: url]
                            )
                        }
                    }
                }
            }
        )
        .padding(.init(top: 24,
                       leading: Spacing.padding2,
                       bottom: 0.0,
                       trailing: Spacing.padding2))
    }

    @ViewBuilder func loading() -> some View {
        AlertCard(
            title: L01n.LearnMore.title,
            message: L01n.LearnMore.description
        )
        .padding(.init(top: 24, leading: 24, bottom: 0.0, trailing: 24))
        .disabled(true)
        .redacted(reason: .placeholder)
    }
}

struct RecurringBuyListView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringBuyListView(
            buys: [
                .init(
                    id: "123",
                    recurringBuyFrequency: "Once a Week",
                    nextPaymentDate: "Next Monday",
                    paymentMethodType: "Cash Wallet",
                    amount: "$20.00",
                    asset: "Bitcoin"
                )
            ]
        )
    }
}
