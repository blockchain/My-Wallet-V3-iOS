//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import Combine
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureCoinData
import FeatureCoinDomain
import FeatureCoinUI
import FeatureDashboardUI
import FeatureInterestUI
import FeatureKYCUI
import FeatureNFTUI
import FeatureStakingDomain
import FeatureTransactionDomain
import FeatureTransactionUI
import Localization
import MoneyKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

public struct CoinAdapterView: View {

    let app: AppProtocol
    let store: Store<CoinViewState, CoinViewAction>
    let cryptoCurrency: CryptoCurrency

    public init(
        cryptoCurrency: CryptoCurrency,
        app: AppProtocol = resolve(),
        userAdapter: UserAdapterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        assetInformationRepository: AssetInformationRepositoryAPI = resolve(),
        historicalPriceRepository: HistoricalPriceRepositoryAPI = resolve(),
        ratesRepository: RatesRepositoryAPI = resolve(),
        watchlistRepository: WatchlistRepositoryAPI = resolve(),
        recurringBuyProviderRepository: RecurringBuyProviderRepositoryAPI = resolve(),
        dismiss: @escaping () -> Void
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.app = app
        self.store = Store<CoinViewState, CoinViewAction>(
            initialState: .init(
                currency: cryptoCurrency
            ),
            reducer: coinViewReducer,
            environment: CoinViewEnvironment(
                app: app,
                kycStatusProvider: { [userAdapter] in
                    userAdapter.userState
                        .compactMap { result -> UserState.KYCStatus? in
                            guard case .success(let userState) = result else {
                                return nil
                            }
                            return userState.kycStatus
                        }
                        .map(FeatureCoinDomain.KYCStatus.init)
                        .eraseToAnyPublisher()
                },
                accountsProvider: { [fiatCurrencyService, coincore] in
                    fiatCurrencyService.displayCurrencyPublisher
                        .setFailureType(to: Error.self)
                        .flatMap { [coincore] fiatCurrency in
                            app.modePublisher()
                                .flatMap { _ in
                                    coincore.cryptoAccounts(
                                        for: cryptoCurrency,
                                        filter: app.currentMode.filter
                                    )
                                }
                                .map { accounts in
                                    accounts
                                        .filter { !($0 is ExchangeAccount) }
                                        .map { Account($0, fiatCurrency) }
                                }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                },
                recurringBuyProvider: {
                    app
                        .publisher(for: blockchain.app.configuration.recurring.buy.is.enabled)
                        .replaceError(with: false)
                        .flatMap { [recurringBuyProviderRepository] isRecurringBuyEnabled -> AnyPublisher<[FeatureCoinDomain.RecurringBuy], Error> in
                            guard isRecurringBuyEnabled else { return .just([]) }
                            return recurringBuyProviderRepository
                                .fetchRecurringBuysForCryptoCurrency(cryptoCurrency)
                                .map { $0.map(RecurringBuy.init) }
                                .eraseError()
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                },
                assetInformationService: AssetInformationService(
                    currency: cryptoCurrency,
                    repository: assetInformationRepository
                ),
                historicalPriceService: HistoricalPriceService(
                    base: cryptoCurrency,
                    displayFiatCurrency: fiatCurrencyService.displayCurrencyPublisher,
                    historicalPriceRepository: historicalPriceRepository
                ),
                earnRatesRepository: ratesRepository,
                explainerService: .init(app: app),
                watchlistService: WatchlistService(
                    base: cryptoCurrency,
                    watchlistRepository: watchlistRepository,
                    app: app
                ),
                dismiss: dismiss
            )
        )
    }

    public var body: some View {
        CoinView(store: store)
            .context([blockchain.ux.asset.id: cryptoCurrency.code])
            .app(app)
    }
}

public final class CoinViewObserver: Client.Observer {

    let app: AppProtocol
    let transactionsRouter: TransactionsRouterAPI
    let coincore: CoincoreAPI
    let kycRouter: KYCRouterAPI
    let defaults: UserDefaults
    let application: URLOpener
    let topViewController: TopMostViewControllerProviding
    let exchangeProvider: ExchangeProviding

    public init(
        app: AppProtocol,
        transactionsRouter: TransactionsRouterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        defaults: UserDefaults = .standard,
        application: URLOpener = resolve(),
        topViewController: TopMostViewControllerProviding = resolve(),
        exchangeProvider: ExchangeProviding = resolve()
    ) {
        self.app = app
        self.transactionsRouter = transactionsRouter
        self.coincore = coincore
        self.kycRouter = kycRouter
        self.defaults = defaults
        self.application = application
        self.topViewController = topViewController
        self.exchangeProvider = exchangeProvider
    }

    var observers: [BlockchainEventSubscription] {
        [
            activeRewardsDeposit,
            activeRewardsWithdraw,
            activity,
            buy,
            currencyExchangeSwap,
            earnSummaryDidAppear,
            exchangeDeposit,
            exchangeWithdraw,
            explainerReset,
            kyc,
            recurringBuyLearnMore,
            rewardsDeposit,
            rewardsWithdraw,
            select,
            sell,
            send,
            stakingDeposit,
            stakingWithdraw
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var select = app.on(blockchain.ux.asset.select.then.enter.into) { @MainActor [unowned self] event async throws in
        guard let action = event.action else { return }
        let destination = try action.data.decode(Tag.Reference.self)
        let cryptoCurrency = try destination.context.decode(blockchain.ux.asset.id) as CryptoCurrency
        let origin = try event.context.decode(blockchain.ux.asset.select.origin) as String
        app.state.transaction { state in
            state.set(blockchain.ux.asset.id, to: cryptoCurrency.code)
            state.set(blockchain.ux.asset[cryptoCurrency.code].select.origin, to: origin)
        }
    }

    lazy var buy = app.on(blockchain.ux.asset.buy, blockchain.ux.asset.account.buy) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .buy(cryptoAccount(for: .buy, from: event))
        )
    }

    lazy var sell = app.on(blockchain.ux.asset.sell, blockchain.ux.asset.account.sell) { @MainActor [unowned self] event in
        let account = try? await cryptoAccount(for: .sell, from: event)
        try? await app.set(blockchain.ux.transaction.source, to: AnyJSON(account))
        await transactionsRouter.presentTransactionFlow(
            to: .sell(account)
        )
    }

    lazy var send = app.on(blockchain.ux.asset.send, blockchain.ux.asset.account.send) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(cryptoAccount(for: .send, from: event), nil)
        )
    }

    lazy var currencyExchangeSwap = app.on(blockchain.ux.asset.account.currency.exchange) { @MainActor [unowned self] event in
        let account: CryptoAccount? = try? await cryptoAccount(for: .swap, from: event)
        if await DexFeature.isEnabled(app: app, cryptoCurrency: account?.asset) {
            try? await DexFeature.openCurrencyExchangeRouter(app: app, context: event.context + [blockchain.ux.transaction.source: AnyJSON(account)])
        } else {
            await transactionsRouter.presentTransactionFlow(to: .swap(account))
        }
    }

    lazy var rewardsWithdraw = app.on(blockchain.ux.asset.account.rewards.withdraw) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoInterestAccount:
            try await transactionsRouter.presentTransactionFlow(to: .interestWithdraw(account, targetWithdrawAccount(for: account)))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Withdrawing from rewards requires CryptoInterestAccount")
        }
    }

    lazy var rewardsDeposit = app.on(blockchain.ux.asset.account.rewards.deposit) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoInterestAccount:
            await transactionsRouter.presentTransactionFlow(to: .interestTransfer(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring to rewards requires CryptoInterestAccount")
        }
    }

    lazy var stakingDeposit = app.on(blockchain.ux.asset.account.staking.deposit) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoStakingAccount:
            await transactionsRouter.presentTransactionFlow(to: .stakingDeposit(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring to rewards requires CryptoInterestAccount")
        }
    }

    lazy var stakingWithdraw = app.on(blockchain.ux.asset.account.staking.withdraw) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoStakingAccount:
            try await transactionsRouter.presentTransactionFlow(to: .stakingWithdraw(account, targetWithdrawAccount(for: account)))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Withdrawing from rewards requires CryptoInterestAccount")
        }
    }

    lazy var activeRewardsDeposit = app.on(blockchain.ux.asset.account.active.rewards.deposit) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoActiveRewardsAccount:
            await transactionsRouter.presentTransactionFlow(to: .activeRewardsDeposit(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring to rewards requires CryptoActiveRewardsAccount")
        }
    }

    lazy var activeRewardsWithdraw = app.on(blockchain.ux.asset.account.active.rewards.withdraw) { @MainActor [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoActiveRewardsAccount:
            let balance = try await account.actionableBalance.stream().next()
            let target = try await CryptoActiveRewardsWithdrawTarget(
                targetWithdrawAccount(for: account),
                amount: balance
            )
            await transactionsRouter.presentTransactionFlow(to: .activeRewardsWithdraw(account, target))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring to rewards requires CryptoActiveRewardsAccount")
        }
    }

    lazy var exchangeWithdraw = app.on(blockchain.ux.asset.account.exchange.withdraw) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(
                cryptoAccount(for: .send, from: event),
                custodialAccount(CryptoTradingAccount.self, from: event)
            )
        )
    }

    lazy var exchangeDeposit = app.on(blockchain.ux.asset.account.exchange.deposit) { @MainActor [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(
                custodialAccount(CryptoTradingAccount.self, from: event),
                cryptoAccount(for: .send, from: event)
            )
        )
    }

    lazy var kyc = app.on(blockchain.ux.asset.account.require.KYC) { @MainActor [unowned self] _ async in
        kycRouter.start(tier: .verified, parentFlow: .coin)
    }

    lazy var activity = app.on(blockchain.ux.asset.account.activity) { @MainActor [unowned self] _ async in
        do {
            try await self.app.set(
                blockchain.ux.user.activity.all.entry.paragraph.row.tap.then.enter.into,
                to: blockchain.ux.user.activity.all
            )
            // present on top since activity is not a tab
            self.app.post(event: blockchain.ux.user.activity.all.entry.paragraph.row.tap)
        } catch {
            app.post(error: error)
        }
    }

    lazy var recurringBuyLearnMore = app.on(blockchain.ux.asset.recurring.buy.visit.website) { [application] event async throws in
        try application.open(event.context.decode(blockchain.ux.asset.recurring.buy.visit.website.url, as: URL.self))
    }

    lazy var explainerReset = app.on(blockchain.ux.asset.account.explainer.reset) { [defaults] _ in
        defaults.removeObject(forKey: blockchain.ux.asset.account.explainer(\.id))
    }

    lazy var earnSummaryDidAppear = app.on(blockchain.ux.earn.summary.did.appear) { @MainActor [unowned self] event async throws in

        var product: EarnProduct? = try? event.context[blockchain.user.earn.product.id].decode()
        var currency: CryptoCurrency? = try? event.context[blockchain.user.earn.product.asset.id].decode()

        guard let product, let currency else {
            return
        }

        switch product {
        case .active:
            guard let account = await cryptoRewardAccount(for: currency) else {
                return
            }
            let pendingWithdrawals = try await account.pendingWithdrawals.replaceError(with: []).stream().next()

            try await app.batch(
                updates: [(blockchain.user.earn.product.asset.limit.withdraw.is.pending, !pendingWithdrawals.isEmpty)],
                in: event.context
            )
        case .staking:
            guard let account = await cryptoStakingAccount(for: currency) else {
                return
            }
            let pendingWithdrawals = try await account.pendingWithdrawals.replaceError(with: []).stream().next()

            try await app.batch(
                updates: [(blockchain.user.earn.product.asset.limit.withdraw.is.pending, !pendingWithdrawals.isEmpty)],
                in: event.context
            )
        default:
            return
        }
    }

    func cryptoRewardAccount(for currency: CryptoCurrency) async -> CryptoActiveRewardsAccount? {
        try? await coincore.allAccounts(filter: .activeRewards)
            .map { group in
                group.accounts
                    .compactMap { account in
                        account as? CryptoActiveRewardsAccount
                    }
                    .first { account in
                        account.asset == currency
                    }
            }
            .stream()
            .next()
    }

    func cryptoStakingAccount(for currency: CryptoCurrency) async -> CryptoStakingAccount? {
        try? await coincore.allAccounts(filter: .staking)
            .map { group in
                group.accounts
                    .compactMap { account in
                        account as? CryptoStakingAccount
                    }
                    .first { account in
                        account.asset == currency
                    }
            }
            .stream()
            .next()
    }

    // swiftlint:disable first_where
    func custodialAccount(
        _ type: BlockchainAccount.Type,
        from event: Session.Event
    ) async throws -> CryptoTradingAccount {
        try await coincore.cryptoAccounts(
            for: event.context.decode(blockchain.ux.asset.id),
            filter: .custodial
        )
        .filter(CryptoTradingAccount.self)
        .first
        .or(
            throw: blockchain.ux.asset.error[]
                .error(message: "No Blockchain.com Account found for \(event.reference)")
        )
    }

    func targetWithdrawAccount(for source: CryptoAccount) async throws -> CryptoTradingAccount {
        guard let currency = source.currencyType.cryptoCurrency else {
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring from rewards requires a CryptoTradingAccount target")
        }
        let accounts = try await coincore.cryptoAccounts(for: currency, filter: .custodial)
        guard let target = accounts.compactMap({ $0 as? CryptoTradingAccount }).first else {
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring from rewards requires a CryptoTradingAccount target")
        }
        return target
    }

    func cryptoAccount(
        for action: AssetAction? = nil,
        from event: Session.Event
    ) async throws -> CryptoAccount {
        let accounts = try await coincore.cryptoAccounts(
            for: (event.context + event.reference.context).decode(blockchain.ux.asset.id),
            supporting: action
        )
        if let id = try? event.reference.context.decode(blockchain.ux.asset.account.id, as: String.self) {
            return try accounts.first(where: { account in account.identifier == id })
                .or(
                    throw: blockchain.ux.asset.error[]
                        .error(message: "No account found with id \(id)")
                )
        } else {
            let appMode = app.currentMode
            switch appMode {
            case .trading:
                return try(
                    accounts.first(where: { account in account is TradingAccount })
                        ?? accounts.first(where: { account in account is InterestAccount })
                        ?? accounts.first(where: { account in account is StakingAccount })
                )
                .or(
                    throw: blockchain.ux.asset.error[]
                        .error(message: "\(event) has no valid accounts for \(String(describing: action))")
                )

            case .pkw:
                return try(accounts.first(where: { account in account is NonCustodialAccount }))
                    .or(
                        throw: blockchain.ux.asset.error[]
                            .error(message: "\(event) has no valid accounts for \(String(describing: action))")
                    )
            }
        }
    }
}

extension FeatureCoinDomain.RecurringBuy {
    init(_ recurringBuy: FeatureTransactionDomain.RecurringBuy) {
        self.init(
            id: recurringBuy.id,
            recurringBuyFrequency: recurringBuy.recurringBuyFrequency.description,
            // Should never be nil as nil is only for one time payments and unknown
            nextPaymentDate: recurringBuy.nextPaymentDate,
            paymentMethodType: recurringBuy.paymentMethodTypeDescription,
            amount: recurringBuy.amount.displayString,
            asset: recurringBuy.asset.displayCode
        )
    }
}

extension FeatureTransactionDomain.RecurringBuy {
    private typealias L01n = LocalizationConstants.Transaction.Buy.Recurring.PaymentMethod
    fileprivate var paymentMethodTypeDescription: String {
        switch paymentMethodType {
        case .bankTransfer,
                .bankAccount:
            return L01n.bankTransfer
        case .card:
            return L01n.creditOrDebitCard
        case .applePay:
            return L01n.applePay
        case .funds:
            return amount.currency.name + " \(L01n.account)"
        }
    }
}

extension FeatureCoinDomain.Account {
    init(_ account: CryptoAccount, _ fiatCurrency: FiatCurrency) {
        self.init(
            id: account.identifier,
            name: account.label,
            assetName: account.assetName,
            accountType: .init(account),
            cryptoCurrency: account.currencyType.cryptoCurrency!,
            fiatCurrency: fiatCurrency,
            actionsPublisher: {
                account.actions
                    .map { actions in OrderedSet(actions.compactMap(Account.Action.init)) }
                    .eraseToAnyPublisher()
            },
            cryptoBalancePublisher: account.balance.ignoreFailure(),
            fiatBalancePublisher: account.fiatBalance(fiatCurrency: fiatCurrency).ignoreFailure(),
            receiveAddressPublisher: account.receiveAddress.ignoreFailure()
        )
    }
}

extension FeatureCoinDomain.Account.Action {

    // swiftlint:disable cyclomatic_complexity
    init?(_ action: AssetAction) {
        switch action {
        case .buy:
            self = .buy
        case .deposit:
            self = .exchange.deposit
        case .interestTransfer:
            self = .rewards.deposit
        case .interestWithdraw:
            self = .rewards.withdraw
        case .stakingDeposit:
            self = .staking.deposit
        case .stakingWithdraw:
            self = .staking.withdraw
        case .activeRewardsDeposit:
            self = .active.deposit
        case .activeRewardsWithdraw:
            self = .active.withdraw
        case .receive:
            self = .receive
        case .sell:
            self = .sell
        case .send:
            self = .send
        case .sign:
            return nil
        case .swap:
            self = .swap
        case .viewActivity:
            self = .activity
        case .withdraw:
            self = .exchange.withdraw
        }
    }
}

extension FeatureCoinDomain.Account.AccountType {

    init(_ account: CryptoAccount) {
        if account is TradingAccount {
            self = .trading
        } else if account is ExchangeAccount {
            self = .exchange
        } else if account is InterestAccount {
            self = .interest
        } else if account is StakingAccount {
            self = .staking
        } else if account is ActiveRewardsAccount {
            self = .activeRewards
        } else {
            self = .privateKey
        }
    }
}

extension FeatureCoinDomain.KYCStatus {

    init(_ kycStatus: UserState.KYCStatus) {
        switch kycStatus {
        case .unverified:
            self = .unverified
        case .inReview:
            self = .inReview
        case .gold:
            self = .gold
        }
    }
}

extension TransactionsRouterAPI {

    @discardableResult
    @MainActor func presentTransactionFlow(to action: TransactionFlowAction) async -> TransactionFlowResult? {
        try? await presentTransactionFlow(to: action).stream().next()
    }
}

extension CoincoreAPI {
    func cryptoAccounts(
        for cryptoCurrency: CryptoCurrency,
        supporting action: AssetAction? = nil,
        filter: AssetFilter = .allExcludingExchange
    ) async throws -> [CryptoAccount] {
        try await cryptoAccounts(for: cryptoCurrency, supporting: action, filter: filter).stream().next()
    }
}
