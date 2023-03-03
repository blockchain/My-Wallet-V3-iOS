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

    @State private var display = true

    let buys: [RecurringBuy]?

    var body: some View {
        if display {
            VStack {
                SectionHeader(
                    title: L01n.Header.recurringBuys,
                    variant: .superapp
                )
                HStack {
                    VStack {
                        if buys == nil {
                            loading()
                        }
                        if let buys, buys.isEmpty {
                            card()
                        }
                        if let buys, buys.isNotEmpty {
                            VStack(spacing: 0) {
                                ForEach(buys) { buy in
                                    rowForRecurringBuy(buy)
                                    if buy != buys.last {
                                        PrimaryDivider()
                                    }
                                }
                            }
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, Spacing.padding2)
                    .background(Color.WalletSemantic.light)
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
        .tableRowBackground(Color.white)
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
        let title = L01n.LearnMore.title
        AlertCard(
            title: title,
            message: L01n.LearnMore.description,
            backgroundColor: Color.white,
            footer: {
                SmallSecondaryButton(title: L01n.LearnMore.action) {
                    Task(priority: .userInitiated) {
                        if let url = try? await app.get(blockchain.app.configuration.asset.recurring.buy.learn.more.url) as URL {
                            app.post(
                                event: blockchain.ux.asset.recurring.buy.visit.website[].ref(to: context),
                                context: [
                                    blockchain.ux.asset.recurring.buy.visit.website.url[]: url,
                                    blockchain.ux.asset.recurring.buy.visit.module.name: title
                                ]
                            )
                        }
                    }
                }
            },
            onCloseTapped: {
                withAnimation {
                    display = false
                }
            }
        )
    }

    @ViewBuilder func loading() -> some View {
        AlertCard(
            title: L01n.LearnMore.title,
            message: L01n.LearnMore.description
        )
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
