// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct EarnSummaryView: View {

    struct SheetModel {
        let title: String
        let description: String
    }

    let id = blockchain.ux.earn.portfolio.product.asset.summary

    var product: EarnProduct { try! context[blockchain.user.earn.product.id].decode() }
    var currency: CryptoCurrency { try! context[blockchain.user.earn.product.asset.id].decode() }

    @BlockchainApp var app
    @Environment(\.context) var context

    @StateObject var object = Object()

    public init() {}

    public var body: some View {
        if #available(iOS 15, *) {
            main
                .superAppNavigationBar(
                    title: {
                        navigationTitleView(
                            title: L10n.summaryTitle.interpolating(currency.code, product.title),
                            iconUrl: currency.logoURL
                        )
                    },
                    trailing: { dismiss() },
                    scrollOffset: nil
                )
                .navigationBarHidden(true)
        } else {
            main
                .primaryNavigation(
                    leading: {
                        AsyncMedia(url: currency.logoURL)
                            .frame(width: 24.pt, height: 24.pt)
                    },
                    title: L10n.summaryTitle.interpolating(currency.code, product.title),
                    trailing: { dismiss() }
                )
        }
    }

    var main: some View {
        VStack {
            if let model = object.model {
                Loaded(model).id(model)
            } else {
                BlockchainProgressView()
            }
        }
        .onAppear { object.start(on: app, in: context) }
    }

    @MainActor @ViewBuilder
    func navigationTitleView(title: String?, iconUrl: URL?) -> some View {
        if let url = iconUrl {
            AsyncMedia(
                url: url,
                content: { media in
                    media.cornerRadius(12)
                },
                placeholder: {
                    Color.semantic.muted
                        .opacity(0.3)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(.circular)
                        )
                        .clipShape(Circle())
                }
            )
            .resizingMode(.aspectFit)
            .frame(width: 24.pt, height: 24.pt)
        }

        Text(title ?? "")
            .typography(.body2)
            .foregroundColor(.WalletSemantic.title)
    }

    @MainActor @ViewBuilder
    func dismiss() -> some View {
        IconButton(icon: .closeCirclev3) {
            $app.post(event: id.article.plain.navigation.bar.button.close.tap)
        }
        .frame(width: 24.pt)
    }
}

extension EarnSummaryView {

    struct Loaded: View {

        let id = blockchain.ux.earn.portfolio.product.asset.summary

        @BlockchainApp var app
        @Environment(\.context) var context

        let my: L_blockchain_user_earn_product_asset.JSON

        var dayFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day]
            formatter.unitsStyle = .short
            return formatter
        }()

        var product: EarnProduct { try! context[blockchain.user.earn.product.id].decode() }
        var currency: CryptoCurrency { try! context[blockchain.user.earn.product.asset.id].decode() }

        init(_ json: L_blockchain_user_earn_product_asset.JSON) {
            self.my = json
        }

        @State var exchangeRate: MoneyValue?
        @State var tradingBalance: MoneyValue?
        @State var pkwBalance: MoneyValue?
        @State var earningBalance: MoneyValue?
        @State var pendingWithdrawal: Bool = false
        @State var isWithdrawDisabled: Bool = false
        @State var learnMore: URL?
        @State var sheetModel: SheetModel?

        private var isSuperAppEnabled: Bool {
            app.remoteConfiguration.yes(if: blockchain.app.configuration.app.superapp.v1.is.enabled)
        }

        var body: some View {
            VStack(spacing: .zero) {
                Do {
                    try balance(value: my.account.balance(MoneyValue.self))
                } catch: { _ in
                    EmptyView()
                }
                content
                buttons
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .bindings {
                subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
                subscribe($learnMore, to: blockchain.ux.earn.portfolio.product.asset.summary.learn.more.url)
                subscribe($tradingBalance, to: blockchain.user.trading[currency.code].account.balance.available)
                subscribe($pkwBalance, to: blockchain.user.pkw.asset[currency.code].balance)
                subscribe($earningBalance, to: blockchain.user.earn.product[product.value].asset[currency.code].account.earning)
            }
            .bindings {
                subscribe($pendingWithdrawal, to: blockchain.user.earn.product[product.value].asset[currency.code].limit.withdraw.is.pending)
            }
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
            .bottomSheet(
                isPresented: .init(get: {
                    sheetModel != nil
                }, set: { _ in
                    sheetModel = nil
                })
            ) {
                sheet()
            }
        }

        @ViewBuilder var buttons: some View {
            ZStack {
                HStack(spacing: Spacing.padding1) {
                    SecondaryButton(
                        title: L10n.withdraw,
                        leadingView: { Icon.walletSend.frame(width: 10, height: 14) },
                        action: {
                            $app.post(event: id.withdraw.paragraph.button.small.secondary.tap)
                        }
                    )
                    .disabled(
                        pendingWithdrawal
                        || my.limit.withdraw.is.disabled ?? false
                        || (product == .active && earningBalance?.isZero ?? false)
                    )
                    SecondaryButton(
                        title: L10n.add,
                        leadingView: { Icon.walletReceive.frame(width: 10, height: 14) },
                        action: {
                            $app.post(
                                event: id.add.paragraph.button.primary.tap,
                                context: [
                                    blockchain.ui.type.action.then.enter.into.detents: [
                                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                                    ]
                                ]
                            )
                        }
                    )
                    .disabled(!(my.is.eligible ?? false))
                }
                .padding(Spacing.padding3)
            }
            .background(
                BottomSheetBackgroundShape()
                    .foregroundColor(.semantic.background)
                    .ignoresSafeArea()
            )
        }

        var action: L_blockchain_ui_type_action.JSON {
            var action = L_blockchain_ui_type_action.JSON(.empty)
            let isTradingNotZeroOrDust = tradingBalance.isNotZeroOrDust(using: exchangeRate) ?? false
            let isPkwNotZeroOrDust = pkwBalance.isNotZeroOrDust(using: exchangeRate) ?? false
            if isTradingNotZeroOrDust || isPkwNotZeroOrDust {
                action.then.emit = product.deposit(currency)
            } else {
                action.then.enter.into = my.is.eligible == true
                    ? blockchain.ux.earn.discover.product.asset.no.balance[].ref(to: context)
                    : blockchain.ux.earn.discover.product.not.eligible[].ref(to: context)
                action.policy.discard.if = isTradingNotZeroOrDust || isPkwNotZeroOrDust
            }
            return action
        }

        @ViewBuilder func balance(value: MoneyValue) -> some View {
            VStack(spacing: Spacing.padding1) {
                Do {
                    try Text(value.convert(using: exchangeRate.or(throw: "No exchange rate")).displayString)
                        .typography(.title1)
                } catch: { _ in
                    EmptyView()
                }
                Text(value.displayString).typography(.body2).foregroundColor(.semantic.text)
            }
            .padding(.top, Spacing.padding4)
            .padding(.bottom, Spacing.padding1)
        }

        @ViewBuilder func rowQuoted(
            title: String,
            value: MoneyValue?,
            info: SheetModel? = nil
        ) -> some View {
            if let value {
                if let info {
                    TableRow(
                        title: TableRowTitle(title),
                        inlineTitleButton: IconButton(
                            icon: .information.micro(),
                            action: {
                                sheetModel = info
                            }
                        ),
                        trailingTitle: TableRowTitle(value.quotedDisplayString(using: exchangeRate)),
                        trailingByline: TableRowByline(value.displayString)
                    )
                    .frame(minHeight: 80.pt)
                    .backport
                    .listDivider()
                } else {
                    TableRow(
                        title: TableRowTitle(title),
                        trailingTitle: TableRowTitle(value.quotedDisplayString(using: exchangeRate)),
                        trailingByline: TableRowByline(value.displayString)
                    )
                    .frame(minHeight: 80.pt)
                    .backport
                    .listDivider()
                }
            } else {
                EmptyView()
            }
        }

        @ViewBuilder func row(
            title: String,
            trailingTitle: String,
            info: SheetModel? = nil
        ) -> some View {
            if let info {
                TableRow(
                    title: TableRowTitle(title),
                    inlineTitleButton: IconButton(
                        icon: .information.micro(),
                        action: {
                            sheetModel = info
                        }
                    ),
                    trailingTitle: TableRowTitle(trailingTitle)
                )
                .frame(minHeight: 80.pt)
                .backport
                .listDivider()
            } else {
                TableRow(
                    title: TableRowTitle(title),
                    trailingTitle: TableRowTitle(trailingTitle)
                )
                .frame(minHeight: 80.pt)
                .backport
                .listDivider()
            }
        }

        @ViewBuilder var content: some View {
            List {
                Section {
                    if product == .active, let quote = exchangeRate?.displayString {
                        row(
                            title: L10n.price.interpolating(currency.displayCode),
                            trailingTitle: quote
                        )
                    }
                    rowQuoted(
                        title: product == .active ? L10n.netEarnings : L10n.totalEarned,
                        value: try? my.account.total.rewards(MoneyValue.self),
                        info: product.totalEarnedSheetModel
                    )
                    if product == .active {
                        rowQuoted(
                            title: product.totalTitle,
                            value: try? my.account.balance(MoneyValue.self)
                            - my.account.pending.deposit(MoneyValue.self)
                            - my.account.pending.withdrawal(MoneyValue.self)
                            - my.account.bonding.deposits(MoneyValue.self)
                        )
                        if let bonding = try? my.account.bonding.deposits(MoneyValue.self), bonding.isPositive {
                            rowQuoted(
                                title: product == .staking ? L10n.bonding : L10n.onHold,
                                value: bonding,
                                info: product.onHoldSheetModel
                            )
                        }
                    } else if product == .staking {
                        if let rate = my.rates.rate {
                            row(
                                title: L10n.currentRate,
                                trailingTitle: percentageFormatter.string(from: NSNumber(value: rate)) ?? "0%",
                                info: product.rateSheetModel
                            )
                        }
                        row(
                            title: L10n.paymentFrequency,
                            trailingTitle: frequencyTitle(my.limit.reward.frequency),
                            info: product.frequencySheetModel
                        )
                    } else if product == .savings, let accrued = try? my.account.pending.interest(MoneyValue.self) {
                        rowQuoted(
                            title: L10n.accruedThisMonth,
                            value: accrued,
                            info: product.monthlyEarningsSheetModel
                        )
                    }
                }
                .listRowInsets(.zero)
                if product != .staking {
                    Section {
                        if let rate = my.rates.rate {
                            row(
                                title: product == .active ? L10n.estimatedAnnualRate : L10n.currentRate,
                                trailingTitle: percentageFormatter.string(from: NSNumber(value: rate)) ?? "0%",
                                info: product.rateSheetModel
                            )
                        }

                        if let trigger = try? my.rates.trigger.price(MoneyValue.self).displayString {
                            row(
                                title: L10n.triggerPrice,
                                trailingTitle: trigger,
                                info: product.triggerSheetModel
                            )
                        }

                        row(
                            title: L10n.paymentFrequency,
                            trailingTitle: frequencyTitle(my.limit.reward.frequency),
                            info: product.frequencySheetModel
                        )

                        if let nextPayment = product.nextPaymentDate {
                            row(
                                title: L10n.nextPayment,
                                trailingTitle: nextPayment
                            )
                        }

                        if let initialHoldPeriod = try? my.limit.lock.up.duration(Int.self),
                            initialHoldPeriod > 0,
                            let numberOfDays = dayFormatter.string(from: TimeInterval(initialHoldPeriod))
                        {
                            row(
                                title: L10n.initialHoldPeriod,
                                trailingTitle: numberOfDays,
                                info: product.initialHoldPeriodSheetModel
                            )
                        }
                    }
                    .listRowInsets(.zero)
                }
                footer
            }
            .listStyle(.insetGrouped)
            .listRowInsets(.zero)
        }

        func frequencyTitle(_ frequency: Tag?) -> String {
            let frequency = frequency ?? blockchain.user.earn.product.asset.limit.reward.frequency.monthly[]
            switch frequency {
            case blockchain.user.earn.product.asset.limit.reward.frequency.daily:
                return L10n.daily
            case blockchain.user.earn.product.asset.limit.reward.frequency.weekly:
                return L10n.weekly
            case blockchain.user.earn.product.asset.limit.reward.frequency.monthly:
                return L10n.monthly
            default:
                return ""
            }
        }

        @ViewBuilder var footer: some View {
            Group {
                if pendingWithdrawal {
                    Section {
                        TableRow(
                            leading: { Icon.pending.small().color(.semantic.text) },
                            title: TableRowTitle(L10n.PendingWithdrawal.title.interpolating(currency.displayCode)),
                            byline: TableRowByline(L10n.PendingWithdrawal.subtitle).foregroundColor(.semantic.primaryMuted),
                            trailing: { TableRowByline(L10n.PendingWithdrawal.date).foregroundColor(.semantic.muted) }
                        )
                    }
                    .listRowInsets(.zero)
                } else if let isDisabled = my.limit.withdraw.is.disabled, isDisabled, let disclaimer = product.withdrawDisclaimer {
                    Section {
                        AlertCard(
                            title: L10n.important,
                            message: disclaimer,
                            variant: .warning,
                            backgroundColor: .white
                        ) {
                            SmallSecondaryButton(title: L10n.learnMore) {
                                app.post(event: id.learn.more.paragraph.button.small.secondary.tap[].ref(to: context), context: context)
                            }
                        }
                    }
                    .listRowInsets(.zero)
                }
                if product == .active {
                    Section {
                        AlertCard(
                            title: L10n.important,
                            message: L10n.activeWithdrawDisclaimer,
                            variant: .warning,
                            backgroundColor: .white
                        ) {
                            SmallSecondaryButton(title: L10n.learnMore) {
                                app.post(event: id.learn.more.paragraph.button.small.secondary.tap[].ref(to: context), context: context)
                            }
                        }
                    }
                    .listRowInsets(.zero)
                }
            }
        }

        @ViewBuilder func sheet() -> some View {
            if let model = sheetModel {
                VStack(spacing: Spacing.padding3) {
                    HStack {
                        Text(model.title)
                            .typography(.body2)
                        Spacer()
                        Icon.closeCirclev2
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                sheetModel = nil
                            }
                    }
                    HStack(spacing: .zero) {
                        Text(model.description)
                            .multilineTextAlignment(.leading)
                            .typography(.body1)
                        Spacer()
                    }
                    PrimaryButton(title: L10n.gotIt) {
                        sheetModel = nil
                    }
                }
                .padding(.horizontal, Spacing.padding3)
            } else {
                EmptyView()
            }
        }
    }
}

extension Optional<MoneyValue> {
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

        private var cancellables: Set<AnyCancellable> = []

        @MainActor
        func start(on app: AppProtocol, in context: Tag.Context) {
            app.publisher(for: blockchain.user.earn.product.asset[].ref(to: context, in: app), as: L_blockchain_user_earn_product_asset.JSON.self)
                .compactMap(\.value)
                .receive(on: DispatchQueue.main)
                .assign(to: &$model)

            app.post(event: blockchain.ux.earn.summary.did.appear, context: context)
            app.on(
                blockchain.ux.transaction.event.execution.status.completed,
                blockchain.ux.transaction.event.execution.status.pending
            )
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { _ in
                    app.post(event: blockchain.ux.earn.summary.did.appear, context: context)
                }
            )
            .subscribe()
            .store(in: &cancellables)
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

extension MoneyValue {

    fileprivate func quotedDisplayString(using rate: MoneyValue?) -> String {
        guard let rate else {
            return displayString
        }

        return convert(using: rate).displayString
    }
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
        default:
            return nil
        }
    }

    var rateSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .staking:
            return .init(
                title: LocalizationConstants.Staking.InfoSheet.Rate.title,
                description: LocalizationConstants.Staking.InfoSheet.Rate.description
            )
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.Rate.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.Rate.description
            )
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.Rate.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.Rate.description
            )
        default:
            return nil
        }
    }

    var totalEarnedSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.Earnings.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.Earnings.description
            )
        default:
            return nil
        }
    }

    var onHoldSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.OnHold.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.OnHold.description
            )
        default:
            return nil
        }
    }

    var triggerSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.Trigger.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.Trigger.description
            )
        default:
            return nil
        }
    }

    var frequencySheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.Frequency.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.Frequency.description
            )
        default:
            return nil
        }
    }

    var initialHoldPeriodSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.HoldPeriod.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.HoldPeriod.description
            )
        default:
            return nil
        }
    }

    var monthlyEarningsSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.MonthlyEarnings.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.MonthlyEarnings.description
            )
        default:
            return nil
        }
    }

    var nextPaymentDate: String? {
        switch self {
        case .savings:
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.day = 1
            let month = components.month ?? 0
            components.month = month + 1
            components.calendar = .current
            let next = components.date ?? Date()
            return DateFormatter.long.string(from: next)
        default:
            return nil
        }
    }
}
