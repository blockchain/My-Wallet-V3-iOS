// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import DIKit
import ErrorsUI
import FeatureFormDomain
import FeatureKYCUI
import FeatureProductsDomain
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import ToolKit
import UIComponentsKit

/// A protocol defining the API for the app's entry point to any `Transaction Flow`.
/// NOTE: Presenting a Transaction Flow can never fail because it's expected for any error to be handled within the flow.
/// Non-recoverable errors should force the user to abandon the flow.
public protocol TransactionsRouterAPI {

    /// Some APIs may not have UIKit available. In this instance we use
    /// `TopMostViewControllerProviding`.
    func presentTransactionFlow(
        to action: TransactionFlowAction
    ) -> AnyPublisher<TransactionFlowResult, Never>

    func presentTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never>
}

public enum UserActionServiceResult: Equatable {
    case canPerform
    case cannotPerform(upgradeTier: KYC.Tier?)
    case questions
}

public protocol UserActionServiceAPI {

    func canPresentTransactionFlow(
        toPerform action: TransactionFlowAction
    ) -> AnyPublisher<UserActionServiceResult, Never>
}

final class TransactionsRouter: TransactionsRouterAPI {

    private let app: AppProtocol
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let pendingOrdersService: PendingOrderDetailsServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let userActionService: UserActionServiceAPI
    private let coincore: CoincoreAPI
    private let kycRouter: PlatformUIKit.KYCRouting
    private let kyc: FeatureKYCUI.Routing
    private let alertViewPresenter: AlertViewPresenterAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private var transactionFlowBuilder: TransactionFlowBuildable
    private let buyFlowBuilder: BuyFlowBuildable
    private let sellFlowBuilder: SellFlowBuildable
    private let signFlowBuilder: SignFlowBuildable
    private let sendFlowBuilder: SendRootBuildable
    private let interestFlowBuilder: InterestTransactionBuilder
    private let withdrawFlowBuilder: WithdrawRootBuildable
    private let depositFlowBuilder: DepositRootBuildable
    private let receiveCoordinator: ReceiveCoordinator
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let productsService: FeatureProductsDomain.ProductsServiceAPI
    @LazyInject var tabSwapping: TabSwapping

    /// Currently retained RIBs router in use.
    private var currentRIBRouter: RIBs.Routing?
    private var cancellables: Set<AnyCancellable> = []

    init(
        app: AppProtocol = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        pendingOrdersService: PendingOrderDetailsServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        userActionService: UserActionServiceAPI = resolve(),
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        transactionFlowBuilder: TransactionFlowBuildable = TransactionFlowBuilder(),
        buyFlowBuilder: BuyFlowBuildable = BuyFlowBuilder(analyticsRecorder: resolve()),
        sellFlowBuilder: SellFlowBuildable = SellFlowBuilder(),
        signFlowBuilder: SignFlowBuildable = SignFlowBuilder(),
        sendFlowBuilder: SendRootBuildable = SendRootBuilder(),
        interestFlowBuilder: InterestTransactionBuilder = InterestTransactionBuilder(),
        withdrawFlowBuilder: WithdrawRootBuildable = WithdrawRootBuilder(),
        depositFlowBuilder: DepositRootBuildable = DepositRootBuilder(),
        receiveCoordinator: ReceiveCoordinator = ReceiveCoordinator(),
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
        kyc: FeatureKYCUI.Routing = resolve(),
        productsService: FeatureProductsDomain.ProductsServiceAPI = resolve()
    ) {
        self.app = app
        self.analyticsRecorder = analyticsRecorder
        self.featureFlagsService = featureFlagsService
        self.eligibilityService = eligibilityService
        self.userActionService = userActionService
        self.kycRouter = kycRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.alertViewPresenter = alertViewPresenter
        self.coincore = coincore
        self.pendingOrdersService = pendingOrdersService
        self.transactionFlowBuilder = transactionFlowBuilder
        self.buyFlowBuilder = buyFlowBuilder
        self.sellFlowBuilder = sellFlowBuilder
        self.signFlowBuilder = signFlowBuilder
        self.sendFlowBuilder = sendFlowBuilder
        self.interestFlowBuilder = interestFlowBuilder
        self.withdrawFlowBuilder = withdrawFlowBuilder
        self.depositFlowBuilder = depositFlowBuilder
        self.receiveCoordinator = receiveCoordinator
        self.fiatCurrencyService = fiatCurrencyService
        self.kyc = kyc
        self.productsService = productsService
    }

    func presentTransactionFlow(
        to action: TransactionFlowAction
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        guard let viewController = topMostViewControllerProvider.topMostViewController else {
            fatalError("Expected a UIViewController")
        }
        return presentTransactionFlow(to: action, from: viewController)
    }

    func presentTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        isUserEligible(for: action)
            .handleEvents(
                receiveSubscription: { [app] _ in
                    app.state.transaction { state in
                        state.set(blockchain.ux.transaction.id, to: action.asset.rawValue)
                    }
                    app.post(event: blockchain.ux.transaction.event.will.start)
                }
            )
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] ineligibility -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self else {
                    return .empty()
                }
                guard let ineligibility else {
                    // There is no 'ineligibility' reason, continue.
                    return self.continuePresentingTransactionFlow(
                        to: action,
                        from: presenter,
                        showKycQuestions: action.isCustodial
                    )
                }

                // There is a 'ineligibility' reason.
                // Show KYC flow or 'blocked' flow.
                switch (ineligibility.type, action) {
                case (.insufficientTier, _):
                    let tier: KYC.Tier = ineligibility.reason == .tier2Required ? .tier2 : .tier1
                    return self.presentKYCUpgradeFlow(from: presenter, requiredTier: tier)
                case (.other, .deposit):
                    self.app.post(event: blockchain.ux.frequent.action.deposit.cash.identity.verification)
                    return .just(.abandoned)
                default:
                    guard let presenter = self.topMostViewControllerProvider.topMostViewController else {
                        return .just(.abandoned)
                    }
                    let viewController = self.buildIneligibilityErrorView(ineligibility, for: action, from: presenter)
                    presenter.present(viewController, animated: true, completion: nil)
                    return .just(.abandoned)
                }
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.currentRIBRouter = nil
            })
            .eraseToAnyPublisher()
    }

    private func isUserEligible(
        for action: TransactionFlowAction
    ) -> AnyPublisher<ProductIneligibility?, Never> {
        guard action.isCustodial, let productId = action.toProductIdentifier else {
            return .just(nil)
        }
        return productsService
            .fetchProducts()
            .replaceError(with: [])
            .flatMap { products -> AnyPublisher<ProductIneligibility?, Never> in
                let product: ProductValue? = products.first { $0.id == productId }
                return .just(product?.reasonNotEligible)
            }
            .eraseToAnyPublisher()
    }

    private func presentKYCUpgradeFlow(
        from presenter: UIViewController,
        requiredTier: KYC.Tier?
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        kycRouter.presentKYCUpgradeFlow(from: presenter)
            .map { result in
                switch result {
                case .abandoned:
                    return .abandoned
                case .completed, .skipped:
                    return .completed
                }
            }
            .eraseToAnyPublisher()
    }

    /// Call this only after having checked that users can perform the requested action
    private func continuePresentingTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController,
        showKycQuestions: Bool
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        do {
            let isKycQuestionsEmpty: Bool = try app.state.get(blockchain.ux.kyc.extra.questions.form.is.empty)
            if showKycQuestions, !isKycQuestionsEmpty {
                return presentKycQuestionsIfNeeded(
                    to: action,
                    from: presenter
                )
            }
        } catch { /* ignore */ }

        switch action {
        case .buy:
            return presentTradingCurrencySelectorIfNeeded(from: presenter)
                .flatMap { result -> AnyPublisher<TransactionFlowResult, Never> in
                    guard result == .completed else {
                        return .just(result)
                    }
                    return self.presentBuyTransactionFlow(to: action, from: presenter)
                }
                .eraseToAnyPublisher()

        case .sell,
             .order,
             .swap,
             .interestTransfer,
             .interestWithdraw,
             .stakingDeposit,
             .activeRewardsDeposit,
             .activeRewardsWithdraw,
             .sign,
             .send,
             .receive,
             .withdraw,
             .deposit:
            return presentNewTransactionFlow(action, from: presenter)
        }
    }

    private func presentKycQuestionsIfNeeded(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        let subject = PassthroughSubject<TransactionFlowResult, Never>()
        kyc.routeToKYC(
            from: presenter,
            requiredTier: .tier1,
            flowCompletion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .abandoned:
                    subject.send(.abandoned)
                case .completed, .skipped:
                    self.continuePresentingTransactionFlow(
                        to: action,
                        from: presenter,
                        showKycQuestions: false // if questions were skipped
                    )
                    .sink(receiveValue: subject.send)
                    .store(in: &self.cancellables)
                }
            }
        )
        return subject.eraseToAnyPublisher()
    }

    private func presentBuyTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        eligibilityService.eligibility()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] eligibility -> AnyPublisher<TransactionFlowResult, Error> in
                guard let self else { return .empty() }
                if eligibility.simpleBuyPendingTradesEligible {
                    return self.pendingOrdersService.pendingOrderDetails
                        .receive(on: DispatchQueue.main)
                        .flatMap { [weak self] orders -> AnyPublisher<TransactionFlowResult, Never> in
                            guard let self else { return .empty() }
                            let isAwaitingAction = orders.filter(\.isAwaitingAction)
                            if isAwaitingAction.isNotEmpty {
                                return isAwaitingAction.publisher
                                    .flatMap { order in
                                        self.pendingOrdersService.cancel(order).ignoreFailure()
                                    }
                                    .collect()
                                    .mapToVoid()
                                    .receive(on: DispatchQueue.main)
                                    .flatMap {
                                        self.presentNewTransactionFlow(action, from: presenter)
                                    }
                                    .eraseToAnyPublisher()
                            } else {
                                return self.presentNewTransactionFlow(action, from: presenter)
                            }
                        }
                        .eraseError()
                        .eraseToAnyPublisher()
                } else {
                    return self.presentTooManyPendingOrders(
                        count: eligibility.maxPendingDepositSimpleBuyTrades,
                        from: presenter
                    )
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                }
            }
            .catch { [weak self] error -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self else { return .empty() }
                return self.presentError(error: error, action: action, from: presenter)
            }
            .eraseToAnyPublisher()
    }
}

extension TransactionsRouter {

    // since we're not attaching a RIB to a RootRouter we have to retain the router and manually activate it
    private func mimicRIBAttachment(router: RIBs.Routing) {
        currentRIBRouter?.interactable.deactivate()
        currentRIBRouter = router
        router.load()
        router.interactable.activate()
    }
}

extension TransactionsRouter {

    // swiftlint:disable:next cyclomatic_complexity
    private func presentNewTransactionFlow(
        _ action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        switch action {
        case .interestWithdraw(let source, let target):
            let listener = InterestTransactionInteractor(transactionType: .withdraw(source, target))
            let router = interestFlowBuilder.buildWithInteractor(listener)
            router.start()
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .interestTransfer(let cryptoAccount):
            let listener = InterestTransactionInteractor(transactionType: .transfer(cryptoAccount))
            let router = interestFlowBuilder.buildWithInteractor(listener)
            router.start()
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .stakingDeposit(let cryptoAccount):
            let listener = InterestTransactionInteractor(transactionType: .stake(cryptoAccount))
            let router = interestFlowBuilder.buildWithInteractor(listener)
            router.start()
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .activeRewardsDeposit(let cryptoAccount):
            let listener = InterestTransactionInteractor(transactionType: .activeRewardsDeposit(cryptoAccount))
            let router = interestFlowBuilder.buildWithInteractor(listener)
            router.start()
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .activeRewardsWithdraw(let cryptoAccount):
            let listener = InterestTransactionInteractor(transactionType: .activeRewardsWithdraw(cryptoAccount))
            let router = interestFlowBuilder.buildWithInteractor(listener)
            router.start()
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .buy(let cryptoAccount):
            let listener = BuyFlowListener(
                kycRouter: kycRouter,
                alertViewPresenter: alertViewPresenter
            )
            let interactor = BuyFlowInteractor()
            let router = buyFlowBuilder.build(with: listener, interactor: interactor)
            router.start(with: cryptoAccount, order: nil, from: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .order(let order):
            let listener = BuyFlowListener(
                kycRouter: kycRouter,
                alertViewPresenter: alertViewPresenter
            )
            let interactor = BuyFlowInteractor()
            let router = buyFlowBuilder.build(with: listener, interactor: interactor)
            router.start(with: nil, order: order, from: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .sell(let cryptoAccount):
            let listener = SellFlowListener()
            let interactor = SellFlowInteractor()
            let router = SellFlowBuilder().build(with: listener, interactor: interactor)
            startSellRouter(router, cryptoAccount: cryptoAccount, from: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .swap(let cryptoAccount):
            let listener = SwapRootInteractor()
            let router = transactionFlowBuilder.build(
                withListener: listener,
                action: .swap,
                sourceAccount: cryptoAccount,
                target: nil
            )
            presenter.present(router.viewControllable.uiviewController, animated: true)
            mimicRIBAttachment(router: router)
            return .empty()

        case .sign(let sourceAccount, let destination):
            let listener = SignFlowListener()
            let interactor = SignFlowInteractor()
            let router = signFlowBuilder.build(with: listener, interactor: interactor)
            router.start(sourceAccount: sourceAccount, destination: destination, presenter: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .send(let fromAccount, let target):
            let router = sendFlowBuilder.build()
            switch (fromAccount, target) {
            case (.some(let fromAccount), let target):
                router.routeToSend(sourceAccount: fromAccount, destination: target)
            case (nil, _):
                router.routeToSendLanding(navigationBarHidden: true)
            }
            presenter.present(router.viewControllable.uiviewController, animated: true)
            mimicRIBAttachment(router: router)
            return .empty()

        case .receive(let account):
            presenter.present(receiveCoordinator.builder.receive(), animated: true)
            if let account {
                receiveCoordinator.routeToReceive(sourceAccount: account)
            }
            return .empty()

        case .withdraw(let fiatAccount):
            let router = withdrawFlowBuilder.build(sourceAccount: fiatAccount)
            router.start()
            mimicRIBAttachment(router: router)
            return .empty()

        case .deposit(let fiatAccount):
            let router = depositFlowBuilder.build(with: fiatAccount)
            router.start()
            mimicRIBAttachment(router: router)
            return .empty()
        }
    }

    private func startSellRouter(
        _ router: SellFlowRouting,
        cryptoAccount: CryptoAccount?,
        from presenter: UIViewController
    ) {
        @Sendable func startRouterOnMainThread(target: TransactionTarget?) async {
            await MainActor.run {
                router.start(with: cryptoAccount, target: target, from: presenter)
            }
        }
        Task(priority: .userInitiated) {
            do {
                let currency: FiatCurrency = try await app.get(blockchain.user.currency.preferred.fiat.trading.currency)
                let account = try await coincore
                    .account(where: { $0.currencyType == currency })
                    .values
                    .next()
                    .first as? TransactionTarget
                await startRouterOnMainThread(target: account)
            } catch {
                await startRouterOnMainThread(target: nil)
            }
        }
    }

    private func presentTooManyPendingOrders(
        count: Int,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        let subject = PassthroughSubject<TransactionFlowResult, Never>()

        func dismiss() {
            presenter.dismiss(animated: true) {
                subject.send(.abandoned)
            }
        }

        presenter.present(
            PrimaryNavigationView {
                TooManyPendingOrdersView(
                    count: count,
                    viewActivityAction: { [tabSwapping] in
                        tabSwapping.switchToActivity()
                        dismiss()
                    },
                    okAction: dismiss
                )
                .whiteNavigationBarStyle()
                .trailingNavigationButton(.close, action: dismiss)
            }
        )
        return subject.eraseToAnyPublisher()
    }

    /// Checks if the user has a valid trading currency set. If not, it presents a modal asking the user to select one.
    ///
    /// If presented, the modal allows the user to select a trading fiat currency to be the base of transactions. This currency can only be one of the currencies supported for any of our official trading pairs.
    /// At the time of this writing, the supported trading currencies are USD, EUR, and GBP.
    ///
    /// The trading currency should be used to define the fiat inputs in the Enter Amount Screen and to show fiat values in the transaction flow.
    ///
    /// - Note: Checking for a trading currency is only required for the Buy flow at this time. However, it may be required for other flows as well in the future.
    ///
    /// - Returns: A `Publisher` whose result is `TransactionFlowResult.completed` if the user had or has successfully selected a trading currency.
    /// Otherwise, it returns `TransactionFlowResult.abandoned`. In this case, the user should be prevented from entering the desired transaction flow.
    private func presentTradingCurrencySelectorIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        let viewControllerGenerator = viewControllerForSelectingTradingCurrency
        // 1. Fetch Trading Currency and supported trading currencies
        return fiatCurrencyService.tradingCurrency
            .zip(fiatCurrencyService.supportedFiatCurrencies)
            .receive(on: DispatchQueue.main)
            .flatMap { tradingCurrency, supportedTradingCurrencies -> AnyPublisher<TransactionFlowResult, Never> in
                // 2a. If trading currency matches one of supported currencies, return .completed
                guard !supportedTradingCurrencies.contains(tradingCurrency) else {
                    return .just(.completed)
                }
                // 2b. Otherwise, present new screen, with close => .abandoned, selectCurrency => settingsService.setTradingCurrency
                let subject = PassthroughSubject<TransactionFlowResult, Never>()
                let sortedCurrencies = Array(supportedTradingCurrencies)
                    .sorted(by: { $0.displayCode < $1.displayCode })
                let viewController = viewControllerGenerator(tradingCurrency, sortedCurrencies) { result in
                    presenter.dismiss(animated: true) {
                        subject.send(result)
                        subject.send(completion: .finished)
                    }
                }
                presenter.present(viewController, animated: true, completion: nil)
                return subject.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func viewControllerForSelectingTradingCurrency(
        displayCurrency: FiatCurrency,
        currencies: [FiatCurrency],
        handler: @escaping (TransactionFlowResult) -> Void
    ) -> UIViewController {
        UIHostingController(
            rootView: TradingCurrencySelector(
                store: .init(
                    initialState: .init(
                        displayCurrency: displayCurrency,
                        currencies: currencies
                    ),
                    reducer: TradingCurrency.reducer,
                    environment: .init(
                        closeHandler: {
                            handler(.abandoned)
                        },
                        selectionHandler: { [weak self] selectedCurrency in
                            guard let self else {
                                return
                            }
                            self.fiatCurrencyService
                                .update(tradingCurrency: selectedCurrency, context: .simpleBuy)
                                .map(TransactionFlowResult.completed)
                                .receive(on: DispatchQueue.main)
                                .sink(receiveValue: handler)
                                .store(in: &self.cancellables)
                        },
                        analyticsRecorder: analyticsRecorder
                    )
                )
            )
        )
    }

    private func presentError(
        error: Error,
        action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        let subject = PassthroughSubject<TransactionFlowResult, Never>()

        func dismiss() {
            presenter.dismiss(animated: true) {
                subject.send(.abandoned)
            }
        }

        let state = TransactionErrorState.fatalError(.generic(error))

        presenter.present(
            NavigationView {
                ErrorView(
                    ux: state.ux(action: action.asset),
                    fallback: {
                        Icon.globe.color(.semantic.primary)
                    },
                    dismiss: dismiss
                )
            }
            .app(app)
        )

        return subject.eraseToAnyPublisher()
    }

    private func buildIneligibilityErrorView(
        _ reason: ProductIneligibility?,
        for action: TransactionFlowAction,
        from presenter: UIViewController
    )
        -> UIViewController
    {
        let title: String
        let message: String
        
        if let productTitle = action.asset.earnProductTitle, let asset = action.currencyCode {
            title = LocalizationConstants.MajorProductBlocked.Earn.notEligibleTitle
            message = LocalizationConstants.MajorProductBlocked.Earn.notEligibleMessage.interpolating(productTitle, asset)
        } else {
            title = LocalizationConstants.MajorProductBlocked.title
            message = reason?.message ?? LocalizationConstants.MajorProductBlocked.defaultMessage
        }
        
        let error = UX.Error(
            source: nil,
            title: title,
            message: message,
            actions: {
                var actions: [UX.Action] = .default
                if let learnMoreUrl = reason?.learnMoreUrl {
                    let newAction = UX.Action(
                        title: LocalizationConstants.MajorProductBlocked.ctaButtonLearnMore,
                        url: learnMoreUrl
                    )
                    actions.append(newAction)
                }
                return actions
            }()
        )

        return UIHostingController(
            rootView: ErrorView(
                ux: error,
                dismiss: { presenter.dismiss(animated: true) }
            ).app(app)
        )
    }
}

extension TransactionFlowAction {
    /// https://www.notion.so/blockchaincom/Russia-Sanctions-10k-euro-limit-5th-EC-Sanctions-d07a493c9b014a25a83986f390e0ac35
    fileprivate var toProductIdentifier: ProductIdentifier? {
        switch self {
        case .buy:
            return .buy
        case .sell:
            return .sell
        case .swap:
            return .swap
        case .deposit:
            return .depositFiat
        case .withdraw:
            return .withdrawFiat
        case .receive:
            return .depositCrypto
        case .send:
            return .withdrawCrypto
        case .interestTransfer:
            return .depositInterest
        case .interestWithdraw:
            return .withdrawCrypto
        default:
            return nil
        }
    }
}
