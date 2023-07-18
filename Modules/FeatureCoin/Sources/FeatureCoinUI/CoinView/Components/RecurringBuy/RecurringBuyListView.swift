import BlockchainComponentLibrary
import BlockchainNamespace
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI

public struct RecurringBuyListView: View {

    public enum Location: Codable, Hashable {
        case coin(asset: String)
        case dashboard(asset: String)

        var asset: String {
            switch self {
            case .coin(let asset):
                return asset
            case .dashboard(let asset):
                return asset
            }
        }

        var isDashboard: Bool {
            switch self {
            case .coin:
                return false
            case .dashboard:
                return true
            }
        }
    }

    private typealias L10n = LocalizationConstants.RecurringBuy

    @BlockchainApp var app
    @Environment(\.context) var context
    @Environment(\.scheduler) var scheduler

    var buys: [RecurringBuy]?
    @Binding var showsManageButton: Bool

    private let location: Location

    public init(
        buys: [RecurringBuy]?,
        location: Location,
        showsManageButton: Binding<Bool> = .constant(false)
    ) {
        self.buys = buys
        self.location = location
        self._showsManageButton = showsManageButton
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(
                    title: L10n.Header.recurringBuys,
                    variant: .superapp
                )
                if location.isDashboard {
                    Spacer()
                    Button {
                        app.post(
                            event: blockchain.ux.dashboard.recurring.buy.manage.entry.paragraph.button.minimal.tap,
                            context: [
                                blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                            ]
                        )
                    } label: {
                        Text(L10n.Header.seeAllButton)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.primary)
                    }
                    .opacity(showsManageButton ? 1.0 : 0.0)
                    .batch {
                        set(
                            blockchain.ux.dashboard.recurring.buy.manage.entry.paragraph.button.minimal.tap.then.enter.into,
                            to: blockchain.ux.dashboard.recurring.buy.manage
                        )
                    }
                }
            }
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
                                rowForRecurringBuy(
                                    buy,
                                    rowContext: [
                                        blockchain.ux.asset.id: buy.asset,
                                        blockchain.ux.asset.recurring.buy.summary.id: buy.id
                                    ]
                                )
                                if buy != buys.last {
                                    PrimaryDivider()
                                }
                            }
                        }
                        .cornerRadius(16)
                    }
                }
                .background(Color.semantic.light)
            }
        }
        .padding(.horizontal, Spacing.padding2)
    }

    @ViewBuilder func rowForRecurringBuy(_ buy: RecurringBuy, rowContext: Tag.Context) -> some View {
        TableRow(
            leading: {
                if let currency = CryptoCurrency(code: buy.asset) {
                    if location.isDashboard {
                        iconView(currency)
                    } else {
                        Icon.walletBuy
                            .color(.white)
                            .circle(backgroundColor: currency.color)
                            .frame(width: 24)
                    }
                } else {
                    EmptyView()
                }
            },
            title: buy.amount + " \(buy.recurringBuyFrequency)",
            byline: L10n.Row.frequency + buy.nextPaymentDateDescription
        )
        .tableRowBackground(Color.semantic.background)
        .onTapGesture {
            app.post(
                event: blockchain.ux.asset.recurring.buy.summary.entry.paragraph.row.select[].ref(to: rowContext),
                context: [
                    blockchain.ux.asset[buy.asset].recurring.buy.summary[buy.id].model: buy,
                    blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                ]
            )
        }
        .batch {
            set(
                blockchain.ux.asset.recurring.buy.summary.entry.paragraph.row.select.then.enter.into[].ref(to: rowContext),
                to: blockchain.ux.asset.recurring.buy.summary[].ref(to: rowContext)
            )
        }
    }

    @ViewBuilder func card() -> some View {
        TableRow(
            leading: {
                Icon.repeat
                    .circle(backgroundColor: .semantic.primary)
                    .with(length: 32.pt)
                    .iconColor(.white)
            },
            title: L10n.LearnMore.title,
            byline: L10n.LearnMore.description,
            trailing: {
                SmallSecondaryButton(title: L10n.LearnMore.action) { }.allowsHitTesting(false)
            }
        )
        .onTapGesture {
            Task {
                if await app.get(blockchain.ux.recurring.buy.onboarding.has.active.buys, or: false) {
                    app.state.set(blockchain.ux.transaction["buy"].action.show.recurring.buy, to: true)
                    if case .dashboard = location {
                        app.post(event: blockchain.ux.recurring.buy.onboarding.entry.paragraph.button.primary.tap)
                    } else {
                        app.post(event: blockchain.ux.asset[location.asset].buy)
                    }
                } else {
                    app.post(
                        event: blockchain.ux.recurring.buy.onboarding.entry.paragraph.row.select,
                        context: [
                            blockchain.ux.recurring.buy.onboarding.location: location,
                            blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                        ]
                    )
                }
            }
        }
        .batch {
            set(blockchain.ux.recurring.buy.onboarding.entry.paragraph.button.primary.tap.then.enter.into, to: blockchain.ux.transaction["buy"].select.target)
            set(blockchain.ux.recurring.buy.onboarding.entry.paragraph.row.select.then.enter.into, to: blockchain.ux.recurring.buy.onboarding)
        }
        .tableRowBackground(Color.semantic.background)
        .cornerRadius(16)
    }

    @ViewBuilder func loading() -> some View {
        AlertCard(
            title: L10n.LearnMore.title,
            message: L10n.LearnMore.description,
            backgroundColor: .semantic.background
        )
        .disabled(true)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder
    func iconView(_ currency: CryptoCurrency) -> some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncMedia(url: currency.assetModel.logoPngUrl, placeholder: { EmptyView() })
                .frame(width: 24.pt, height: 24.pt)
                .background(currency.color, in: Circle())
        }
    }
}

struct RecurringBuyListView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringBuyListView(
            buys: [
                .init(
                    id: "123",
                    recurringBuyFrequency: "Once a Week",
                    nextPaymentDate: Date(),
                    paymentMethodType: "Cash Wallet",
                    amount: "$20.00",
                    asset: "Bitcoin"
                )
            ],
            location: .coin(asset: "BTC"),
            showsManageButton: .constant(false)
        )
    }
}
