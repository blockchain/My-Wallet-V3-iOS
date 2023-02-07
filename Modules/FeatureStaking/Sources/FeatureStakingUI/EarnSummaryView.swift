// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct EarnSummaryView: View {

    let id = blockchain.ux.earn.portfolio.product.asset.summary

    @BlockchainApp var app
    @Environment(\.context) var context

    @StateObject var object = Object()

    public init() { }

    public var body: some View {
        VStack {
            if let model = object.model {
                Loaded(model).id(model)
            } else {
                BlockchainProgressView()
            }
        }
        .onAppear { object.start(on: app, in: context) }
    }
}

extension EarnSummaryView {

    struct Loaded: View {

        let id = blockchain.ux.earn.portfolio.product.asset.summary

        @BlockchainApp var app
        @Environment(\.context) var context

        let my: L_blockchain_user_earn_product_asset.JSON

        var product: EarnProduct { try! context[blockchain.user.earn.product.id].decode() }
        var currency: CryptoCurrency { try! context[blockchain.user.earn.product.asset.id].decode() }

        init(_ json: L_blockchain_user_earn_product_asset.JSON) {
            self.my = json
        }

        @State var exchangeRate: MoneyValue?
        @State var tradingBalance: MoneyValue?
        @State var isWithdrawDisabled: Bool = false
        @State var learnMore: URL?

        private var isSuperAppEnabled: Bool {
            app.remoteConfiguration.yes(if: blockchain.app.configuration.app.superapp.v1.is.enabled)
        }

        var body: some View {
            VStack(alignment: .leading) {
                balance
                PrimaryDivider()
                content
                HStack {
                    SecondaryButton(title: L10n.withdraw) {
                        $app.post(event: id.withdraw.paragraph.button.small.secondary.tap)
                    }
                    .disabled(my.limit.withdraw.is.disabled ?? false)
                    PrimaryButton(title: L10n.add) {
                        $app.post(
                            event: id.add.paragraph.button.primary.tap,
                            context: [
                                blockchain.ui.type.action.then.enter.into.detents: [
                                    blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                                ]
                            ]
                        )
                    }
                }
                .padding([.leading, .trailing])
            }
            .padding(.top)
            .binding(
                .subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value),
                .subscribe($learnMore, to: blockchain.ux.earn.portfolio.product.asset.summary.learn.more.url),
                .subscribe($tradingBalance, to: blockchain.user.trading[currency.code].account.balance.available)
            )
            .batch(
                .set(id.add.paragraph.button.primary.tap, to: action),
                .set(id.withdraw.paragraph.button.small.secondary.tap.then.emit, to: $app[product.withdraw(currency)]),
                .set(id.learn.more.paragraph.button.small.secondary.tap.then.launch.url, to: learnMore),
                .set(id.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            )
            .batch(
                isSuperAppEnabled
                ? .set(id.view.activity.paragraph.row.tap.then.enter.into, to: blockchain.ux.user.activity.all)
                : .set(id.view.activity.paragraph.row.tap.then.emit, to: blockchain.ux.home.tab[blockchain.ux.user.activity].select)
            )
            .primaryNavigation(
                leading: {
                    AsyncMedia(url: currency.logoURL)
                        .frame(width: 32.pt, height: 32.pt)
                },
                title: L10n.summaryTitle.interpolating(currency.code, product.title),
                trailing: {
                    IconButton(icon: .closeCirclev2) {
                        $app.post(event: id.article.plain.navigation.bar.button.close.tap)
                    }
                    .frame(width: 24.pt)
                }
            )
        }

        var action: L_blockchain_ui_type_action.JSON {
            var action = L_blockchain_ui_type_action.JSON(.empty)
            let isNotZeroOrDust = tradingBalance.isNotZeroOrDust(using: exchangeRate)
            if isNotZeroOrDust == true {
                action.then.emit = product.deposit(currency)
            } else {
                action.then.enter.into = my.is.eligible == true
                    ? blockchain.ux.earn.discover.product.asset.no.balance[].ref(to: context)
                    : blockchain.ux.earn.discover.product.not.eligible[].ref(to: context)
                action.policy.discard.`if` = isNotZeroOrDust
            }
            return action
        }

        var balance: some View {

            func header(title string: String, value moneyValue: MoneyValue) -> some View {
                VStack(alignment: .leading) {
                    Text(string)
                        .typography(.caption1)
                        .foregroundColor(.semantic.title)
                    Do {
                        try Text(moneyValue.convert(using: exchangeRate.or(throw: "No exchange rate")).displayString)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                    } catch: { _ in
                        EmptyView()
                    }
                    Text(moneyValue.displayString)
                        .typography(.caption2)
                        .foregroundColor(.semantic.text)
                }
            }

            return HStack(alignment: .center) {
                Do {
                    try header(
                        title: L10n.balance,
                        value: my.account.balance(MoneyValue.self)
                    )
                    Spacer()
                    let rewards = try my.account.total.rewards(MoneyValue.self)
                    PrimaryDivider()
                        .frame(height: 60.pt)
                    header(
                        title: product == .active ? L10n.netEarnings : L10n.totalEarned,
                        value: rewards
                    )
                    Spacer()
                } catch: { _ in
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing])
        }

        var content: some View {
            ScrollView {
                VStack {
                    Do {
                        try TableRow(
                            title: TableRowTitle(L10n.price.interpolating(currency.displayCode)),
                            trailingTitle: TableRowTitle(exchangeRate.or(throw: "No exchange rate").displayString)
                        )
                        PrimaryDivider()
                    } catch: { _ in
                        EmptyView()
                    }
                    Do {
                        let amount = try my.account.balance(MoneyValue.self)
                            - my.account.pending.deposit(MoneyValue.self)
                            - my.account.pending.withdrawal(MoneyValue.self)
                            - my.account.bonding.deposits(MoneyValue.self)
                        try TableRow(
                            title: TableRowTitle(product.totalTitle),
                            trailingTitle: TableRowTitle(amount.convert(using: exchangeRate.or(throw: "No exchange rate")).displayString),
                            trailingByline: TableRowByline(amount.displayString)
                        )
                        PrimaryDivider()
                    } catch: { _ in
                        EmptyView()
                    }
                    Do {
                        let bonding = try my.account.bonding.deposits(MoneyValue.self)
                        if bonding.isPositive {
                            try TableRow(
                                title: TableRowTitle(product == .staking ? L10n.bonding : L10n.onHold),
                                trailingTitle: TableRowTitle(
                                    bonding.convert(using: exchangeRate.or(throw: "No exchange rate")).displayString
                                ),
                                trailingByline: TableRowByline(bonding.displayString)
                            )
                            PrimaryDivider()
                        }
                    } catch: { _ in
                        EmptyView()
                    }
                    if let rate = my.rates.rate {
                        TableRow(
                            title: TableRowTitle(L10n.currentRate),
                            trailingTitle: TableRowTitle(
                                percentageFormatter.string(from: NSNumber(value: rate)) ?? "0%"
                            )
                        )
                        PrimaryDivider()
                    }
                    if let triggerPrice = my.rates.trigger.price {
                        Do {
                            try TableRow(
                                title: TableRowTitle(L10n.triggerPrice),
                                trailingTitle: TableRowTitle(
                                    triggerPrice(MoneyValue.self).displayString
                                )
                            )
                            PrimaryDivider()
                        } catch: { _ in
                            EmptyView()
                        }
                    }
                    if let frequency = my.limit.reward.frequency {
                        TableRow(
                            title: TableRowTitle(L10n.paymentFrequency),
                            trailing: {
                                switch frequency {
                                case blockchain.user.earn.product.asset.limit.reward.frequency.daily:
                                    TableRowTitle(L10n.daily)
                                case blockchain.user.earn.product.asset.limit.reward.frequency.weekly:
                                    TableRowTitle(L10n.weekly)
                                case blockchain.user.earn.product.asset.limit.reward.frequency.monthly:
                                    TableRowTitle(L10n.monthly)
                                case _:
                                    EmptyView()
                                }
                            }
                        )
                        PrimaryDivider()
                    }
                    TableRow(title: L10n.viewActivity)
                        .tableRowChevron(true)
                        .background(Color.semantic.background)
                        .onTapGesture {
                            app.post(event: id.view.activity.paragraph.row.tap[].ref(to: context), context: context)
                        }
                    PrimaryDivider()
                }
                if let isDisabled = my.limit.withdraw.is.disabled, isDisabled, let disclaimer = product.withdrawDisclaimer {
                    AlertCard(
                        title: L10n.important,
                        message: disclaimer
                    ) {
                        SmallSecondaryButton(title: L10n.learnMore) {
                            app.post(event: id.learn.more.paragraph.button.small.secondary.tap[].ref(to: context), context: context)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

extension Optional where Wrapped == MoneyValue {
    func isNotZeroOrDust(using exchangeRate: MoneyValue?) -> Bool? {
        guard let tradingBalance = self, let exchangeRate else { return nil }
        let quote = tradingBalance.convert(using: exchangeRate)
        return !(tradingBalance.isZero || quote.isDust)
    }
}

extension EarnSummaryView {

    @MainActor
    class Object: ObservableObject {

        @Published var model: L_blockchain_user_earn_product_asset.JSON?

        @MainActor
        func start(on app: AppProtocol, in context: Tag.Context) {
            app.publisher(for: blockchain.user.earn.product.asset[].ref(to: context, in: app), as: L_blockchain_user_earn_product_asset.JSON.self)
                .compactMap(\.value)
                .receive(on: DispatchQueue.main)
                .assign(to: &$model)
        }
    }
}

extension EarnActivity: View {

    static let dateFormatter: DateFormatter = with(DateFormatter()) { formatter in
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
    }

    public var body: some View {
        TableRow(
            leading: {
                switch type {
                case .deposit:
                    Icon.deposit.color(.semantic.dark).circle().frame(width: 20.pt)
                case .withdraw:
                    Icon.pending.color(.semantic.dark).circle().frame(width: 20.pt)
                default:
                    Icon.question.color(.semantic.dark).circle().frame(width: 20.pt)
                }
            },
            title: TableRowTitle(currency.code),
            trailing: {
                VStack(alignment: .trailing) {
                    TableRowByline(value.displayString)
                    Text(My.dateFormatter.string(from: date.insertedAt))
                        .typography(.caption1)
                        .foregroundColor(.semantic.text)
                }
            }
        )
    }
}

struct EarnSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        EarnSummaryView()
            .context(
                [
                    blockchain.ux.earn.portfolio.product.id: "staking",
                    blockchain.ux.earn.portfolio.product.asset.id: "ETH",
                    blockchain.user.earn.product.id: "staking",
                    blockchain.user.earn.product.asset.id: "ETH"
                ]
            )
            .app(App.preview)
            .previewDisplayName("Loading")
        EarnSummaryView.Loaded(preview)
            .context(
                [
                    blockchain.ux.earn.portfolio.product.id: "staking",
                    blockchain.ux.earn.portfolio.product.asset.id: "ETH",
                    blockchain.user.earn.product.id: "staking",
                    blockchain.user.earn.product.asset.id: "ETH"
                ]
        )
        .app(App.preview)
        .previewDisplayName("Loaded")
    }

    static let preview: L_blockchain_user_earn_product_asset.JSON = {
        var preview = L_blockchain_user_earn_product_asset.JSON(.empty)
        preview.rates.rate = 0.055
        preview.account.balance[] = MoneyValue.create(minor: "500000000000000000", currency: .crypto(.ethereum))
        preview.account.bonding.deposits[] = MoneyValue.create(minor: "20000000000000000", currency: .crypto(.ethereum))
        preview.account.locked[] = MoneyValue.create(minor: "0", currency: .crypto(.ethereum))
        preview.account.total.rewards[] = MoneyValue.create(minor: "10000000000000000", currency: .crypto(.ethereum))
        preview.account.unbonding.withdrawals[] = MoneyValue.create(minor: "0", currency: .crypto(.ethereum))
        preview.limit.days.bonding = 5
        preview.limit.days.unbonding = 0
        preview.limit.withdraw.is.disabled = true
        preview.limit.reward.frequency = blockchain.user.earn.product.asset.limit.reward.frequency.daily[]
        preview.activity = []
        return preview
    }()
}

extension EarnProduct {

    public func id(_ asset: Currency) -> String {
        switch self {
        case .staking:
            return "CryptoStakingAccount.\(asset.code)"
        case .savings:
            return "CryptoInterestAccount.\(asset.code)"
        case .active:
            return "CryptoActiveRewardsAccount.\(asset.code)"
        default:
            return asset.code
        }
    }

    func deposit(_ asset: Currency) -> Tag.Event {
        switch self {
        case .staking:
            return blockchain.ux.asset[asset.code].account[id(asset)].staking.deposit
        case .savings:
            return blockchain.ux.asset[asset.code].account[id(asset)].rewards.deposit
        case .active:
            return blockchain.ux.asset[asset.code].account[id(asset)].active.rewards.deposit
        default:
            return blockchain.ux.asset[asset.code]
        }
    }

    func withdraw(_ asset: Currency) -> Tag.Event {
        switch self {
        case .savings:
            return blockchain.ux.asset[asset.code].account[id(asset)].rewards.withdraw
        case .active:
            return blockchain.ux.asset[asset.code].account[id(asset)].active.rewards.withdraw
        default:
            return blockchain.ux.asset[asset.code]
        }
    }

    var totalTitle: String {
        switch self {
        case .staking:
            return L10n.totalStaked
        case .active:
            return L10n.totalSubscribed
        default:
            return L10n.totalDeposited
        }
    }

    var withdrawDisclaimer: String? {
        switch self {
        case .staking:
            return L10n.stakingWithdrawDisclaimer
        case .active:
            return L10n.activeWithdrawDisclaimer
        default:
            return nil
        }
    }
}
