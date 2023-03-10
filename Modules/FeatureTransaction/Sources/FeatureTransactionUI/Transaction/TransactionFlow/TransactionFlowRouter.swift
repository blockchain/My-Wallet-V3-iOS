// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BINDWithdrawUI
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import DIKit
import Errors
import ErrorsUI
import FeatureCardPaymentDomain
import FeatureOpenBankingUI
import FeaturePlaidUI
import FeatureStakingUI
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import ToolKit
import UIComponentsKit

typealias CountryCode = String

protocol TransactionFlowInteractable: Interactable,
    EnterAmountPageListener,
    ConfirmationPageListener,
    AccountPickerListener,
    PendingTransactionPageListener,
    TargetSelectionPageListener
{

    var router: TransactionFlowRouting? { get set }
    var listener: TransactionFlowListener? { get set }

    func didSelectSourceAccount(account: BlockchainAccount)
    func didSelectDestinationAccount(target: TransactionTarget)
}

public protocol TransactionFlowViewControllable: ViewControllable {

    var viewControllers: [UIViewController] { get }

    func present(viewController: ViewControllable?, animated: Bool, completion: (() -> Void)?)
    func replaceRoot(viewController: ViewControllable?, animated: Bool)
    func push(viewController: ViewControllable?)
    func dismiss()
    func pop()
    func popToRoot()
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
}

extension TransactionFlowViewControllable {
    func present(viewController: ViewControllable?, animated: Bool) {
        present(viewController: viewController, animated: animated, completion: nil)
    }
}

typealias TransactionViewableRouter = ViewableRouter<TransactionFlowInteractable, TransactionFlowViewControllable>
typealias TransactionFlowAnalyticsEvent = AnalyticsEvents.New.TransactionFlow

final class TransactionFlowRouter: TransactionViewableRouter, TransactionFlowRouting {

    private var app: AppProtocol
    private var paymentMethodLinker: PaymentMethodLinkingSelectorAPI
    private var bankWireLinker: BankWireLinkerAPI
    private var cardLinker: CardLinkerAPI
    private let alertViewPresenter: AlertViewPresenterAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding

    private var linkBankFlowRouter: LinkBankFlowStarter?
    private var securityRouter: PaymentSecurityRouter?
    private let kycRouter: PlatformUIKit.KYCRouting
    private let transactionsRouter: TransactionsRouterAPI
    private let cacheSuite: CacheSuite
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let bindRepository: BINDWithdrawRepositoryProtocol
    private let stakingAccountService: EarnAccountService

    private let bottomSheetPresenter = BottomSheetPresenting(ignoresBackgroundTouches: true)

    private var cancellables = Set<AnyCancellable>()
    private var cardLinkingCancellables = Set<AnyCancellable>()

    var isDisplayingRootViewController: Bool {
        viewController.uiviewController.presentedViewController == nil
    }

    init(
        app: AppProtocol = resolve(),
        interactor: TransactionFlowInteractable,
        viewController: TransactionFlowViewControllable,
        paymentMethodLinker: PaymentMethodLinkingSelectorAPI = resolve(),
        bankWireLinker: BankWireLinkerAPI = resolve(),
        cardLinker: CardLinkerAPI = resolve(),
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        transactionsRouter: TransactionsRouterAPI = resolve(),
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        cacheSuite: CacheSuite = resolve(),
        bindRepository: BINDWithdrawRepositoryProtocol = resolve(),
        stakingAccountService: EarnAccountService = resolve(tag: EarnProduct.staking)
    ) {
        self.app = app
        self.paymentMethodLinker = paymentMethodLinker
        self.bankWireLinker = bankWireLinker
        self.cardLinker = cardLinker
        self.kycRouter = kycRouter
        self.transactionsRouter = transactionsRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.alertViewPresenter = alertViewPresenter
        self.featureFlagsService = featureFlagsService
        self.analyticsRecorder = analyticsRecorder
        self.cacheSuite = cacheSuite
        self.bindRepository = bindRepository
        self.stakingAccountService = stakingAccountService
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToConfirmation(transactionModel: TransactionModel, action: AssetAction) {
        let builder = ConfirmationPageBuilder(transactionModel: transactionModel, action: action)
        let router = builder.build(listener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func routeToInProgress(transactionModel: TransactionModel, action: AssetAction) {
        let builder = PendingTransactionPageBuilder()
        let router = builder.build(
            withListener: interactor,
            transactionModel: transactionModel,
            action: action
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func presentRecurringBuyFrequencySelectorWithTransactionModel(_ transactionModel: TransactionModel) {
        let viewController = SelfSizingHostingController(
            rootView: RecurringBuyFrequencySelectorView(
                store: .init(
                    initialState: .init(),
                    reducer: recurringBuyFrequencySelectorReducer,
                    environment: .init(
                        app: app,
                        dismiss: {
                            transactionModel.process(action: .returnToPreviousStep)
                        }
                    )
                )
            )
        )

        attachChild(Router<Interactor>(interactor: Interactor()))

        viewController.transitioningDelegate = bottomSheetPresenter
        viewController.modalPresentationStyle = .custom
        let presenter = topMostViewControllerProvider.topMostViewController
        presenter?.present(viewController, animated: true, completion: nil)
    }

    func presentUXDialogFromErrorState(
        _ errorState: TransactionErrorState,
        transactionModel: TransactionModel
    ) {
        guard case .ux(let ux) = errorState else {
            impossible("state.errorState is not ux")
        }
        presentErrorViewForDialog(ux, transactionModel: transactionModel)
    }

    func presentUXDialogFromUserInteraction(
        state: TransactionState,
        transactionModel: TransactionModel
    ) {
        guard let ux = state.dialog else {
            impossible("state.dialog is nil")
        }
        presentErrorViewForDialog(ux, transactionModel: transactionModel)
    }

    func routeToError(state: TransactionState, model: TransactionModel) {
        let error = state.errorState.ux(action: state.action)

        Task(priority: .userInitiated) { @MainActor in
            let errorViewController = UIHostingController(
                rootView: ErrorView(
                    ux: error,
                    fallback: {
                        if let destination = state.destination {
                            destination.currencyType.logoResource.view
                        } else if let source = state.source {
                            source.currencyType.logoResource.view
                        } else {
                            Icon.error.foregroundColor(.semantic.warning)
                        }
                    },
                    dismiss: { [weak self] in
                        guard let self else { return }
                        self.closeFlow()
                    }
                )
                .app(app)
            )

            attachChild(Router<Interactor>(interactor: Interactor()))

            if state.stepsBackStack.isNotEmpty {
                viewController.push(viewController: errorViewController)
            } else {
                viewController.replaceRoot(
                    viewController: errorViewController,
                    animated: false
                )
            }
        }
    }

    func closeFlow() {
        viewController.dismiss()
        interactor.listener?.dismissTransactionFlow()
    }

    func showErrorRecoverySuggestion(
        action: AssetAction,
        errorState: TransactionErrorState,
        transactionModel: TransactionModel,
        handleCalloutTapped: @escaping (ErrorRecoveryState.Callout) -> Void
    ) {
        guard errorState != .none else {
            // The transaction is valid, there's no error to show.
            if BuildFlag.isInternal {
                fatalError("Developer error: calling `showErrorRecoverySuggestion` with an `errorState` of `none`.")
            }
            return
        }

        presentErrorRecoveryCallout(
            title: errorState.recoveryWarningTitle(for: action).or(Localization.Error.unknownError),
            message: errorState.recoveryWarningMessage(for: action),
            callouts: errorState.recoveryWarningCallouts(for: action),
            onClose: { [transactionModel] in
                transactionModel.process(action: .returnToPreviousStep)
            },
            onCalloutTapped: handleCalloutTapped
        )
    }

    func showVerifyToUnlockMoreTransactionsPrompt(action: AssetAction) {
        presentErrorRecoveryCallout(
            title: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeTitle,
            message: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeMessage,
            callouts: [
                .init(
                    image: Image("icon-verified", bundle: .main),
                    title: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeCalloutTitle,
                    message: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeCalloutMessage,
                    callToAction: LocalizationConstants.Transaction.Notices.verifyToUnlockMoreTradingNoticeCalloutCTA
                )
            ],
            onClose: { [analyticsRecorder, presenter = topMostViewControllerProvider.topMostViewController] in
                if let flowStep = TransactionFlowAnalyticsEvent.FlowStep(action) {
                    analyticsRecorder.record(
                        event: TransactionFlowAnalyticsEvent.getMoreAccessWhenYouVerifyDismissed(flowStep: flowStep)
                    )
                }
                presenter?.dismiss(animated: true)
            },
            onCalloutTapped: { [analyticsRecorder, presentKYCUpgradeFlow] _ in
                if let flowStep = TransactionFlowAnalyticsEvent.FlowStep(action) {
                    analyticsRecorder.record(
                        event: TransactionFlowAnalyticsEvent.getMoreAccessWhenYouVerifyClicked(flowStep: flowStep)
                    )
                }
                presentKYCUpgradeFlow { _ in }
            }
        )
    }

    private func presentErrorRecoveryCallout(
        title: String,
        message: String,
        callouts: [ErrorRecoveryState.Callout],
        onClose: @escaping () -> Void,
        onCalloutTapped: @escaping (ErrorRecoveryState.Callout) -> Void
    ) {
        let view = ErrorRecoveryView(
            store: .init(
                initialState: ErrorRecoveryState(title: title, message: message, callouts: callouts),
                reducer: errorRecoveryReducer,
                environment: ErrorRecoveryEnvironment(close: onClose, calloutTapped: onCalloutTapped)
            )
        )
        let viewController = UIHostingController(rootView: view)
        viewController.transitioningDelegate = bottomSheetPresenter
        viewController.modalPresentationStyle = .custom
        let presenter = topMostViewControllerProvider.topMostViewController
        presenter?.present(viewController, animated: true, completion: nil)
    }

    func pop() {
        viewController.pop()
    }

    func dismiss() {
        guard let topVC = topMostViewControllerProvider.topMostViewController else {
            return
        }
        let topRouter = children.last
        topVC.presentingViewController?.dismiss(animated: true) { [weak self] in
            // Detatch child in completion block to avoid false-positive leak checks
            guard let child = topRouter as? ViewableRouting, child.viewControllable.uiviewController === topVC else {
                return
            }
            self?.detachChild(child)
        }
    }

    func didTapBack() {
        guard let child = children.last else { return }
        pop()
        detachChild(child)
    }

    func pop<T: UIViewController>(to type: T.Type) {
        var viewable = children
        for child in Array(viewable.reversed()) {
            guard let child = child as? ViewableRouting else {
                viewable = viewable.dropLast(); continue
            }
            if child.viewControllable.uiviewController is T { break }
            viewable = viewable.dropLast()
            detachChild(child as Routing)
        }
        children = viewable as [Routing]
        let viewControllers = viewable.filter(ViewableRouting.self).map(\.viewControllable.uiviewController)
        viewController.setViewControllers(viewControllers, animated: true)
    }

    func routeToSourceAccountPicker(
        transitionType: TransitionType,
        transactionModel: TransactionModel,
        action: AssetAction,
        canAddMoreSources: Bool
    ) {
        let router = sourceAccountPickerRouter(
            with: transactionModel,
            action: action,
            canAddMoreSources: canAddMoreSources
        )
        attachAndPresent(router, transitionType: transitionType, completion: { [app, stakingAccountService] in
            Task {
                let state = try await transactionModel.state.await()
                guard let crypto = state.destination?.currencyType.code else { return }
                switch state.action {
                case .stakingDeposit:
                    guard try await stakingAccountService.limits().await()[crypto]?.disabledWithdrawals == true else { return }
                    app.post(
                        event: blockchain.ux.transaction.event.should.show.disclaimer,
                        context: [blockchain.user.earn.product.asset.id: crypto]
                    )
                case .activeRewardsDeposit:
                    app.post(
                        event: blockchain.ux.transaction.event.should.show.disclaimer,
                        context: [blockchain.user.earn.product.asset.id: crypto]
                    )
                case _:
                    break
                }
            }
        })
    }

    func routeToDestinationAccountPicker(
        transitionType: TransitionType,
        transactionModel: TransactionModel,
        action: AssetAction,
        state: TransactionState
    ) {
        let navigationModel: ScreenNavigationModel
        switch transitionType {
        case .push:
            navigationModel = ScreenNavigationModel.AccountPicker.navigationClose(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            )
        case .modal, .replaceRoot:
            navigationModel = ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            )
        }
        let router = destinationAccountPicker(
            with: transactionModel,
            navigationModel: navigationModel,
            action: action,
            state: state
        )
        attachAndPresent(router, transitionType: transitionType)
    }

    func routeToTargetSelectionPicker(transactionModel: TransactionModel, action: AssetAction) {
        let builder = TargetSelectionPageBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: { $0.availableTargets as? [BlockchainAccount] ?? [] }
            ),
            action: action,
            cacheSuite: cacheSuite,
            featureFlagsService: featureFlagsService
        )
        let router = builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.TargetSelection.navigation(
                title: TransactionFlowDescriptor.TargetSelection.navigationTitle(action: action)
            ),
            backButtonInterceptor: {
                transactionModel.state.map {
                    ($0.step, $0.stepsBackStack, $0.isGoingBack)
                }
            }
        )
        attachAndPresent(router, transitionType: .replaceRoot)
    }

    func presentLinkPaymentMethod(transactionModel: TransactionModel) {
        let viewController = viewController.uiviewController
        paymentMethodLinker.presentAccountLinkingFlow(
            from: viewController.uiviewController
        ) { [weak self] result in
            guard let self else { return }
            viewController.dismiss(animated: true) {
                switch result {
                case .abandoned:
                    transactionModel.process(action: .returnToPreviousStep)
                case .completed(let paymentMethod):
                    switch paymentMethod.type {
                    case .applePay:
                        transactionModel.process(
                            action: .sourceAccountSelected(PaymentMethodAccount.applePay(from: paymentMethod))
                        )
                    case .bankAccount:
                        transactionModel.process(action: .showBankWiringInstructions)
                    case .bankTransfer:
                        switch paymentMethod.fiatCurrency {
                        case .USD:
                            transactionModel.process(action: .showBankLinkingFlow)
                        case .GBP, .EUR:
                            self.featureFlagsService
                                .isEnabled(.openBanking)
                                .if(
                                    then: {
                                        transactionModel.process(action: .showBankLinkingFlow)
                                    },
                                    else: {
                                        transactionModel.process(action: .showBankWiringInstructions)
                                    }
                                )
                                .store(in: &self.cancellables)
                        default:
                            transactionModel.process(action: .showBankWiringInstructions)
                        }
                    case .card:
                        transactionModel.process(action: .showCardLinkingFlow)
                    case .funds:
                        transactionModel.process(action: .showBankWiringInstructions)
                    }
                }
            }
        }
    }

    func presentLinkACard(transactionModel: TransactionModel) {
        app.post(event: blockchain.ux.transaction.payment.method.link.a.card)
        if isVGSEnabledOrUserHasCassyTagOnAlpha(app) {
            // clear previous observations
            cardLinkingCancellables = []
            app.on(blockchain.ux.payment.method.vgs.add.card.abandoned)
                .receive(on: DispatchQueue.main)
                .sink { [transactionModel] _ in
                    transactionModel.process(action: .returnToPreviousStep)
                }
                .store(in: &cardLinkingCancellables)
            app.on(blockchain.ux.payment.method.vgs.add.card.completed)
                .receive(on: DispatchQueue.main)
                .sink { [transactionModel] event in
                    do {
                        let data = try event.context[
                            blockchain.ux.payment.method.vgs.add.card.completed.card.data
                        ].decode(CardPayload.self)
                        if let cardData = CardData(response: data) {
                            transactionModel.process(action: .cardLinkingFlowCompleted(cardData))
                        }
                    } catch {
                        transactionModel.process(
                            action: .showUxDialogSuggestion(
                                UX.Dialog(title: "Error", message: error.localizedDescription)
                            )
                        )
                    }
                }
                .store(in: &cardLinkingCancellables)
            Task(priority: .userInitiated) { [app] in
                try await app.set(
                    blockchain.ux.payment.method.vgs.add.card.abandoned.then.close,
                    to: true
                )
                try await app.set(
                    blockchain.ux.payment.method.vgs.add.card.completed.then.close,
                    to: true
                )
                app.post(event: blockchain.ux.payment.method.vgs.add.card)
            }
        } else {
            let presenter = viewController.uiviewController.topMostViewController ?? viewController.uiviewController
            cardLinker.presentCardLinkingFlow(from: presenter) { [transactionModel] result in
                presenter.dismiss(animated: true) {
                    switch result {
                    case .abandoned:
                        transactionModel.process(action: .returnToPreviousStep)
                    case .completed(let data):
                        transactionModel.process(action: .cardLinkingFlowCompleted(data))
                    }
                }
            }
        }
    }

    func presentLinkABank(transactionModel: TransactionModel) {
        analyticsRecorder.record(event: AnalyticsEvents.New.SimpleBuy.linkBankClicked(origin: .buy))
        Task {
            let isPlaidAvailable = app.state.yes(if: blockchain.ux.payment.method.plaid.is.available)
            let isArgentinaEnabled = (try? await app.get(blockchain.app.configuration.argentinalinkbank.is.enabled)) ?? false

            let country: String = try app.state.get(blockchain.user.address.country.code)
            if isPlaidAvailable {
                try await presentPlaidLinkABank(transactionModel: transactionModel)
            } else if country.isArgentina, isArgentinaEnabled {
                try await presentBINDLinkABank(transactionModel: transactionModel)
            } else {
                presentDefaultLinkABank(transactionModel: transactionModel)
            }
        }
    }

    @MainActor
    private func presentPlaidLinkABank(
        transactionModel: TransactionModel
    ) async throws {
        let state = try await transactionModel.state.await()
        let presentingViewController = viewController.uiviewController

        let router = Router<Interactor>(interactor: Interactor())
        attachChild(router)

        let app: AppProtocol = DIKit.resolve()
        let view = PlaidView(
            store: .init(
                initialState: PlaidState(),
                reducer: PlaidModule.reducer,
                environment: .init(
                    app: app,
                    mainQueue: .main,
                    plaidRepository: DIKit.resolve(),
                    dismissFlow: { [weak self] success in
                        presentingViewController.dismiss(animated: true) {
                            self?.detachChild(router)
                            if success {
                                transactionModel.process(action: .bankAccountLinked(state.action))
                            } else {
                                transactionModel.process(action: .bankLinkingFlowDismissed(state.action))
                            }
                        }
                    }
                )
            )
        )
        .app(app)
        .onAppear {
            app.post(event: blockchain.ux.transaction.payment.method.link.a.bank.via.ACH)
        }

        let viewController = UIHostingController(rootView: view)

        viewController.isModalInPresentation = true
        presentingViewController.present(viewController, animated: true)
    }

    private func presentDefaultLinkABank(transactionModel: TransactionModel) {
        let builder = LinkBankFlowRootBuilder()
        let router = builder.build()
        linkBankFlowRouter = router
        router.startFlow()
            .withLatestFrom(transactionModel.state) { ($0, $1) }
            .asPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [topMostViewControllerProvider] effect, state in
                topMostViewControllerProvider
                    .topMostViewController?
                    .dismiss(animated: true, completion: nil)
                switch effect {
                case .closeFlow:
                    transactionModel.process(action: .bankLinkingFlowDismissed(state.action))
                case .bankLinked:
                    transactionModel.process(action: .bankAccountLinked(state.action))
                }
            })
            .store(in: &cancellables)
    }

    @MainActor
    private func presentBINDLinkABank(
        transactionModel: TransactionModel
    ) async throws {
        let state = try await transactionModel.state.await()
        guard let fiat = (state.source?.currencyType ?? state.destination?.currencyType)?.fiatCurrency else {
            return assertionFailure("Expected one fiat currency to create a BIND beneficiary")
        }
        let presentingViewController = viewController.uiviewController
        let hostedViewController = UIHostingController(
            rootView: PrimaryNavigationView {
                BINDWithdrawView { _ in
                    transactionModel.process(action: .bankAccountLinked(state.action))
                }
                .primaryNavigation(
                    title: Localization.withdraw,
                    trailing: {
                        IconButton(
                            icon: .closeCirclev2,
                            action: {
                                presentingViewController.presentedViewController?.dismiss(
                                    animated: true,
                                    completion: {
                                        transactionModel.process(action: .bankLinkingFlowDismissed(state.action))
                                    }
                                )
                            }
                        )
                    }
                )
            }
            .environmentObject(BINDWithdrawService(repository: bindRepository.currency(fiat.code)))
        )
        hostedViewController.isModalInPresentation = true
        presentingViewController.present(hostedViewController, animated: true, completion: nil)
    }

    private func presentErrorViewForDialog(
        _ ux: UX.Dialog,
        transactionModel: TransactionModel
    ) {
        let viewController = UIHostingController(
            rootView: ErrorView(
                ux: .init(nabu: ux),
                dismiss: {
                    transactionModel.process(action: .returnToPreviousStep)
                }
            )
            .app(app)
        )

        attachChild(Router<Interactor>(interactor: Interactor()))

        viewController.transitioningDelegate = bottomSheetPresenter
        viewController.modalPresentationStyle = .custom
        let presenter = topMostViewControllerProvider.topMostViewController
        presenter?.present(viewController, animated: true, completion: nil)
    }

    func presentBankWiringInstructions(transactionModel: TransactionModel) {
        let presenter = viewController.uiviewController.topMostViewController ?? viewController.uiviewController
        // NOTE: using [weak presenter] to avoid a memory leak
        bankWireLinker.presentBankWireInstructions(from: presenter) { [weak presenter] in
            presenter?.dismiss(animated: true) {
                transactionModel.process(action: .returnToPreviousStep)
            }
        }
    }

    func presentOpenBanking(
        action: OpenBankingAction,
        transactionModel: TransactionModel,
        account: LinkedBankData
    ) {

        let presenter = viewController

        let environment = OpenBankingEnvironment(
            app: resolve(),
            dismiss: { [weak presenter] in
                presenter?.dismiss()
            },
            cancel: { [weak presenter] in
                presenter?.popToRoot()
            },
            currency: action.currency
        )

        let viewController: OpenBankingViewController
        switch action {
        case .buy(let order):
            viewController = OpenBankingViewController(
                order: .init(order),
                from: .init(account),
                environment: environment
            )
        case .deposit(let transaction):
            viewController = OpenBankingViewController(
                deposit: transaction.amount.minorString,
                product: "SIMPLEBUY",
                from: .init(account),
                environment: environment
            )
        }

        viewController.eventPublisher.sink { [weak presenter] result in
            switch result {
            case .success:
                transactionModel.process(action: .updateTransactionComplete)
                presenter?.dismiss()
            case .failure:
                break
            }
        }
        .store(withLifetimeOf: viewController)

        presenter.push(viewController: viewController)
    }

    func routeToPriceInput(
        source: BlockchainAccount,
        destination: TransactionTarget,
        transactionModel: TransactionModel,
        action: AssetAction
    ) {

        if viewController.viewControllers.contains(EnterAmountViewController.self) {
            return pop(to: EnterAmountViewController.self)
        }

        guard let source = source as? SingleAccount else { return }
        let builder = EnterAmountPageBuilder(transactionModel: transactionModel)
        let router = builder.build(
            listener: interactor,
            sourceAccount: source,
            destinationAccount: destination,
            action: action,
            navigationModel: ScreenNavigationModel.EnterAmount.navigation(
                allowsBackButton: action.allowsBackButton
            )
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        if let childVC = viewController.uiviewController.children.first,
           childVC is TransactionFlowInitialViewController
        {
            viewController.replaceRoot(viewController: viewControllable, animated: false)
        } else {
            viewController.push(viewController: viewControllable)
        }
    }

    func presentKYCFlowIfNeeded(completion: @escaping (Bool) -> Void) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        interactor.listener?.presentKYCFlowIfNeeded(from: presenter, completion: completion)
    }

    func presentKYCUpgradeFlow(completion: @escaping (Bool) -> Void) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        kycRouter
            .presentKYCUpgradeFlow(from: presenter)
            .map { result -> Bool in result == .completed || result == .skipped }
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }

    func routeToSecurityChecks(transactionModel: TransactionModel) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        securityRouter = PaymentSecurityRouter { result in
            Logger.shared.debug(String(describing: result))
            switch result {
            case .abandoned, .failed:
                transactionModel.process(action: .returnToPreviousStep)
            case .pending, .completed:
                transactionModel.process(action: .securityChecksCompleted)
            }
        }
        transactionModel
            .state
            .asPublisher()
            .first()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        transactionModel.process(action: .fatalTransactionError(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] transactionState in
                    guard let self else { return }
                    guard
                        let order = transactionState.order as? OrderDetails,
                        let authorizationData = order.authorizationData
                    else {
                        let error = FatalTransactionError.message("Order should contain authorization data.")
                        return transactionModel.process(action: .fatalTransactionError(error))
                    }
                    self.securityRouter?.presentPaymentSecurity(
                        from: presenter,
                        authorizationData: authorizationData
                    )
                }
            )
            .store(in: &cancellables)
    }

    func presentNewTransactionFlow(
        to action: TransactionFlowAction,
        completion: @escaping (Bool) -> Void
    ) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        transactionsRouter
            .presentTransactionFlow(to: action, from: presenter)
            .map { $0 == .completed }
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }
}

extension TransactionFlowRouter {

    private func present(_ viewControllerToPresent: UIViewController, transitionType: TransitionType, completion: (() -> Void)? = nil) {
        switch transitionType {
        case .modal:
            viewControllerToPresent.isModalInPresentation = true
            viewController.present(viewController: viewControllerToPresent, animated: true, completion: completion)
        case .push:
            viewController.push(viewController: viewControllerToPresent)
            completion?()
        case .replaceRoot:
            viewController.replaceRoot(viewController: viewControllerToPresent, animated: false)
            completion?()
        }
    }

    private func attachAndPresent(_ router: ViewableRouting, transitionType: TransitionType, completion: (() -> Void)? = nil) {
        attachChild(router)
        present(router.viewControllable.uiviewController, transitionType: transitionType, completion: completion)
    }
}

extension TransactionFlowRouter {

    private func sourceAccountPickerRouter(
        with transactionModel: TransactionModel,
        action: AssetAction,
        canAddMoreSources: Bool
    ) -> AccountPickerRouting {
        let builder = AccountPickerBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: { model in
                    model.availableSources
                },
                flatMap: { accounts in
                    Task<[BlockchainAccount], Error>.Publisher {
                        try await accounts.async.reduce(into: []) { accounts, account in
                            guard try await !account.hasSmallBalance().await() else { return }
                            accounts.append(account)
                        }
                    }
                    .asObservable()
                }
            ),
            action: action
        )
        let shouldAddMoreButton = canAddMoreSources && action.supportsAddingSourceAccounts
        let button: ButtonViewModel? = shouldAddMoreButton ? .secondary(with: LocalizationConstants.addNew) : nil
        let searchable: Bool = app.remoteConfiguration.yes(if: blockchain.app.configuration.swap.search.is.enabled)
        let isSearchEnabled = action == .swap && searchable
        return builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.sourceTitle(action: action)
            ),
            headerModel: .simple(
                AccountPickerSimpleHeaderModel(
                    searchable: isSearchEnabled
                )
            ),
            buttonViewModel: button
        )
    }

    private func destinationAccountPicker(
        with transactionModel: TransactionModel,
        navigationModel: ScreenNavigationModel,
        action: AssetAction,
        state: TransactionState
    ) -> AccountPickerRouting {
        let builder = AccountPickerBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: {
                    $0.availableTargets as? [BlockchainAccount] ?? []
                }
            ),
            action: action
        )

        let button: ButtonViewModel?
        if action == .withdraw, app.state.yes(if: blockchain.ux.payment.method.plaid.is.available) {
            let isDisabled = state.availableTargets.as([FiatAccount].self)?.contains(where: { $0.capabilities?.withdrawal?.enabled == false }) ?? false
            button = isDisabled ? nil : .secondary(with: LocalizationConstants.addNew)
        } else {
            button = action == .withdraw ? .secondary(with: LocalizationConstants.addNew) : nil
        }

        let searchable: Bool = app.remoteConfiguration.yes(if: blockchain.app.configuration.swap.search.is.enabled)
        let switchable: Bool = app.remoteConfiguration.yes(if: blockchain.app.configuration.swap.switch.pkw.is.enabled)

        let isSearchEnabled = action == .swap && searchable
        let isSwitchEnabled = action == .swap && app.currentMode == .pkw && switchable
        let switchTitle = isSwitchEnabled ? Localization.Swap.tradingAccountsSwitchTitle : nil
        let initialAccountTypeFilter: AccountType? = app.currentMode == .pkw ? .nonCustodial : nil
        return builder.build(
            listener: .listener(interactor),
            navigationModel: navigationModel,
            headerModel: .simple(AccountPickerSimpleHeaderModel(
                subtitle: nil,
                searchable: isSearchEnabled,
                switchable: isSwitchEnabled,
                switchTitle: switchTitle
            )
            ),
            buttonViewModel: button,
            initialAccountTypeFilter: initialAccountTypeFilter
        )
    }
}

extension AssetAction {

    var supportsAddingSourceAccounts: Bool {
        switch self {
        case .buy,
             .deposit:
            return true

        case .sell,
             .withdraw,
             .receive,
             .send,
             .sign,
             .swap,
             .viewActivity,
             .interestWithdraw,
             .interestTransfer,
             .stakingDeposit,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            return false
        }
    }
}

extension PaymentMethodAccount {
    fileprivate static func applePay(from method: PaymentMethod) -> PaymentMethodAccount {
        PaymentMethodAccount(
            paymentMethodType: PaymentMethodType.applePay(
                CardData(
                    identifier: "",
                    state: .active,
                    partner: .unknown,
                    type: .unknown,
                    currency: method.fiatCurrency,
                    label: LocalizationConstants.Transaction.Buy.applePay,
                    ownerName: "",
                    number: "",
                    month: "",
                    year: "",
                    cvv: "",
                    topLimit: method.max
                )),
            paymentMethod: method
        )
    }
}

extension CountryCode {
    var isArgentina: Bool { self == "AR" }
    var isAmerica: Bool { self == "US" }
}
