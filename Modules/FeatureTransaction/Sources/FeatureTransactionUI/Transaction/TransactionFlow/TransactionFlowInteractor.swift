// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureStakingDomain
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxRelay
import RxSwift
import ToolKit

enum TransitionType: Equatable {
    case push
    case modal
    case replaceRoot
}

enum OpenBankingAction {
    case buy(OrderDetails)
    case deposit(PendingTransaction)
}

protocol TransactionFlowRouting: Routing {

    var isDisplayingRootViewController: Bool { get }

    /// Pop the current screen off the stack.
    func pop()

    /// Dismiss the top most screen. Currently not called but should be used when
    /// a picker is presented over the `Enter Amount` screen. This is different from
    /// going back.
    func dismiss()

    /// Exit the flow. This occurs usually when the user taps the close button
    /// on the top right of the screen.
    func closeFlow()

    /// The back button was tapped.
    func didTapBack()

    /// Presents a modal with information  about the transaction error state and, if needed, a call to action for the user to resolve that error state.
    func showErrorRecoverySuggestion(
        action: AssetAction,
        errorState: TransactionErrorState,
        transactionModel: TransactionModel,
        handleCalloutTapped: @escaping (ErrorRecoveryState.Callout) -> Void
    )

    /// Show the `source` selection screen. This replaces the root.
    func routeToSourceAccountPicker(
        transitionType: TransitionType,
        transactionModel: TransactionModel,
        action: AssetAction,
        canAddMoreSources: Bool
    )

    /// Show the target selection screen (currently only used in `Send`).
    /// This pushes onto the prior screen.
    func routeToTargetSelectionPicker(transactionModel: TransactionModel, action: AssetAction)

    /// Route to the destination account picker from the target selection screen
    func routeToDestinationAccountPicker(
        transitionType: TransitionType,
        transactionModel: TransactionModel,
        action: AssetAction
    )

    /// Present the payment method linking flow modally over the current screen
    func presentLinkPaymentMethod(transactionModel: TransactionModel)

    /// Present the card linking flow modally over the current screen
    func presentLinkACard(transactionModel: TransactionModel)

    /// Present the bank linking flow modally over the current screen
    func presentLinkABank(transactionModel: TransactionModel)

    /// Present wiring instructions so users can deposit funds into their wallet
    func presentBankWiringInstructions(transactionModel: TransactionModel)

    /// Present open banking authorisation so users can deposit funds into their wallet
    func presentOpenBanking(
        action: OpenBankingAction,
        transactionModel: TransactionModel,
        account: LinkedBankData
    )

    /// Present an `ErrorView`. This `ErrorView` is initialized with the `UX.Dialog`
    /// on the `TransactionState`. This property is set *not* as a result of an error but
    /// rather from user interaction (e.g. the user tapping a `BadgeView` on
    /// the payment selection screen to learn more about why a card has a high failure rate)
    func presentUXDialogFromUserInteraction(
        state: TransactionState,
        transactionModel: TransactionModel
    )

    /// Present an `ErrorView`. This `ErrorView` is initialized with the `UX.Dialog`
    /// on the `TransactionErrorState`. This occurs when the user selects a source account
    /// that is blocked (e.g. a high failure rate payment account in buy).
    func presentUXDialogFromErrorState(
        _ errorState: TransactionErrorState,
        transactionModel: TransactionModel
    )

    /// Present the `RecurringBuy` frequency selector over the enter amount screen as a bottom sheet.
    func presentRecurringBuyFrequencySelectorWithTransactionModel(_ transactionModel: TransactionModel)

    /// Route to the in progress screen. This pushes onto the navigation stack.
    func routeToInProgress(transactionModel: TransactionModel, action: AssetAction)

    /// Route to the in error screen. This pushes onto the navigation stack.
    func routeToError(state: TransactionState, model: TransactionModel)

    /// Route to the transaction security checks screen (e.g. 3DS checks for card payments)
    func routeToSecurityChecks(transactionModel: TransactionModel)

    /// Show the `EnterAmount` screen. This pushes onto the prior screen.
    /// For `Buy` we should set this as the root.
    func routeToPriceInput(
        source: BlockchainAccount,
        destination: TransactionTarget,
        transactionModel: TransactionModel,
        action: AssetAction
    )

    /// Show the confirmation screen. This pushes onto the prior screen.
    func routeToConfirmation(transactionModel: TransactionModel, action: AssetAction)

    /// Presents the KYC Flow if needed or progresses the transactionModel to the next step otherwise
    func presentKYCFlowIfNeeded(completion: @escaping (Bool) -> Void)

    /// Presents the KYC Upgrade Flow.
    /// - Parameters:
    ///  - completion: A closure that is called with `true` if the user completed the KYC flow to move to the next tier.
    func presentKYCUpgradeFlow(completion: @escaping (Bool) -> Void)

    /// Shows a bottom sheet to ask the user to upgrade to a higher KYC tier
    func showVerifyToUnlockMoreTransactionsPrompt(action: AssetAction)

    /// Presentes a new transaction flow on top of the current one
    func presentNewTransactionFlow(
        to action: TransactionFlowAction,
        completion: @escaping (Bool) -> Void
    )
}

public protocol TransactionFlowListener: AnyObject {
    func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void)
    func dismissTransactionFlow()
}

final class TransactionFlowInteractor: PresentableInteractor<TransactionFlowPresentable>,
    TransactionFlowInteractable,
    AccountPickerListener,
    TransactionFlowPresentableListener,
    TargetSelectionPageListener
{

    weak var router: TransactionFlowRouting?
    weak var listener: TransactionFlowListener?

    private var initialStep: Bool = true
    private let transactionModel: TransactionModel
    private let action: AssetAction // TODO: this should be removed and taken from TransactionModel
    private let sourceAccount: BlockchainAccount? // TODO: this should be removed and taken from TransactionModel
    private let target: TransactionTarget? // TODO: this should be removed and taken from TransactionModel
    private let restrictionsProvider: TransactionRestrictionsProviderAPI
    private let analyticsHook: TransactionAnalyticsHook
    private let messageRecorder: MessageRecording
    private let linkedBankFactory: LinkedBanksFactoryAPI
    private let app: AppProtocol

    private var bag = Set<AnyCancellable>()
    private var tasks = Set<Task<Void, Never>>()

    init(
        transactionModel: TransactionModel,
        action: AssetAction,
        sourceAccount: BlockchainAccount?,
        target: TransactionTarget?,
        presenter: TransactionFlowPresentable,
        restrictionsProvider: TransactionRestrictionsProviderAPI = resolve(),
        analyticsHook: TransactionAnalyticsHook = resolve(),
        messageRecorder: MessageRecording = resolve(),
        linkedBankFactory: LinkedBanksFactoryAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.transactionModel = transactionModel
        self.action = action
        self.sourceAccount = sourceAccount
        self.target = target
        self.restrictionsProvider = restrictionsProvider
        self.analyticsHook = analyticsHook
        self.messageRecorder = messageRecorder
        self.linkedBankFactory = linkedBankFactory
        self.app = app
        super.init(presenter: presenter)
        presenter.listener = self
        onInit()
    }

    deinit {
        transactionModel.destroy()
        bag.removeAll()
        for task in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        transactionModel
            .state
            .distinctUntilChanged(\.step)
            .withPrevious()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] previousState, newState in
                self?.handleStateChange(previousState: previousState, newState: newState)
            }
            .disposeOnDeactivate(interactor: self)

        Single<Void>
            .just(())
            .observe(on: MainScheduler.asyncInstance)
            .map { [sourceAccount, target, action] _ -> TransactionAction in
                switch action {
                case .deposit:
                    return self.handleFiatDeposit(
                        sourceAccount: sourceAccount,
                        target: target
                    )

                case .swap where sourceAccount != nil && target != nil:
                    return .initialiseWithSourceAndPreferredTarget(
                        action: action,
                        sourceAccount: sourceAccount!,
                        target: target!
                    )

                case _ where sourceAccount != nil && target != nil:
                    return .initialiseWithSourceAndTargetAccount(
                        action: action,
                        sourceAccount: sourceAccount!,
                        target: target!
                    )

                case _ where sourceAccount != nil:
                    return .initialiseWithSourceAccount(
                        action: action,
                        sourceAccount: sourceAccount!
                    )

                case _ where target != nil:
                    return .initialiseWithTargetAndNoSource(
                        action: action,
                        target: target!
                    )

                default:
                    return .initialiseWithNoSourceOrTargetAccount(
                        action: action
                    )
                }
            }
            .subscribe(
                onSuccess: { [weak self] action in
                    self?.transactionModel.process(action: action)
                },
                onFailure: { [weak self] error in
                    Logger.shared.debug("Unable to configure transaction flow, aborting. \(String(describing: error))")
                    self?.finishFlow()
                }
            )
            .disposeOnDeactivate(interactor: self)

        transactionModel.state
            .filter { $0.executionStatus == .error }
            .subscribe(onNext: { [analyticsHook] transactionState in
                analyticsHook.onTransactionFailure(with: transactionState)
            })
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func didSelect(ux: UX.Dialog) {
        transactionModel.process(action: .showUxDialogSuggestion(ux))
    }

    func didSelectActionButton() {
        transactionModel.process(action: .returnToPreviousStep)
        transactionModel.process(action: .showAddAccountFlow)
    }

    func didSelect(blockchainAccount: BlockchainAccount) {
        guard let target = blockchainAccount as? TransactionTarget else {
            fatalError("Account \(blockchainAccount.self) is not currently supported.")
        }
        didSelect(target: target)
    }

    func didSelect(target: TransactionTarget) {
        transactionModel.state
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { [weak self] state in
                switch state.step {
                case .selectSource:
                    /// Apply the source account
                    self?.didSelectSourceAccount(account: target as! BlockchainAccount)
                    /// If the flow was started with a destination already, like if they
                    /// are depositing into a `FiatAccount`, we apply the destination.
                    /// This will route the user to the `Enter Amount` screen.
                    if let destination = state.destination, !state.stepsBackStack.contains(.enterAmount) {
                        self?.didSelectDestinationAccount(target: destination)
                    }
                case .selectTarget:
                    self?.didSelectDestinationAccount(target: target)
                default:
                    break
                }
            })
            .disposeOnDeactivate(interactor: self)
    }

    func didTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func didTapClose() {
        guard router?.isDisplayingRootViewController == true else {
            // there's a modal to dismiss
            transactionModel.process(action: .returnToPreviousStep)
            return
        }
        // the top most view controller is at the root of the flow, so dismissing it means closing the flow itself.
        router?.closeFlow()
    }

    func enterAmountDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func closeFlow() {
        transactionModel.process(action: .resetFlow)
        router?.closeFlow()
    }

    func checkoutDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func didSelectSourceAccount(account: BlockchainAccount) {
        transactionModel.process(action: .sourceAccountSelected(account))
    }

    func didSelectDestinationAccount(target: TransactionTarget) {
        transactionModel.process(action: .targetAccountSelected(target))
    }

    func enterAmountDidTapAuxiliaryButton() {
        router?.showVerifyToUnlockMoreTransactionsPrompt(action: action)
    }

    func showGenericFailure(error: Error) {
        transactionModel.process(action: .fatalTransactionError(error))
    }

    // MARK: - Private Functions

    private func doCloseFlow() {
        router?.closeFlow()
    }

    private func handleStateChange(previousState: TransactionState?, newState: TransactionState) {
        if !initialStep, newState.step == .initial {
            finishFlow()
        } else {
            initialStep = newState.step == .initial
            showFlowStep(previousState: previousState, newState: newState)
        }
    }

    private func finishFlow() {
        transactionModel.process(action: .resetFlow)
    }

    // swiftlint:disable cyclomatic_complexity
    private func showFlowStep(previousState: TransactionState?, newState: TransactionState) {
        messageRecorder.record("Transaction Step: \(String(describing: previousState?.step)) -> \(newState.step)")
        guard previousState?.step != newState.step else {
            // if the step hasn't changed we have nothing to do
            return
        }
        guard !newState.isGoingBack else {
            guard !goingBackSkipsNavigation(previousState: previousState, newState: newState) else {
                return
            }

            if router?.isDisplayingRootViewController == false {
                router?.dismiss()
            } else {
                router?.didTapBack()
            }
            return
        }

        switch newState.step {
        case .initial:
            break

        case .authorizeOpenBanking:
            let linkedBankData: LinkedBankData
            switch newState.source {
            case let account as PaymentMethodAccount:
                switch account.paymentMethodType {
                case .linkedBank(let data):
                    linkedBankData = data
                default:
                    return assertionFailure("Authorising open banking without a valid payment method")
                }
            case let account as LinkedBankAccount:
                linkedBankData = account.data
            default:
                return assertionFailure("Authorising open banking without a valid account type")
            }

            switch newState.action {
            case .buy:
                guard let order = newState.order as? OrderDetails else {
                    return assertionFailure("OpenBanking for buy requires OrderDetails")
                }
                router?.presentOpenBanking(
                    action: .buy(order),
                    transactionModel: transactionModel,
                    account: linkedBankData
                )
            case .deposit:
                guard let order = newState.pendingTransaction else {
                    return assertionFailure("OpenBanking for deposit requires a PendingTransaction")
                }
                router?.presentOpenBanking(
                    action: .deposit(order),
                    transactionModel: transactionModel,
                    account: linkedBankData
                )
            default:
                return assertionFailure("OpenBanking authorisation is only required for buy and deposit")
            }

        case .enterAmount:
            router?.routeToPriceInput(
                source: newState.source!,
                destination: newState.destination!,
                transactionModel: transactionModel,
                action: action
            )

        case .recurringBuyFrequencySelector:
            router?.presentRecurringBuyFrequencySelectorWithTransactionModel(transactionModel)

        case .linkPaymentMethod:
            router?.presentLinkPaymentMethod(transactionModel: transactionModel)

        case .linkACard:
            router?.presentLinkACard(transactionModel: transactionModel)

        case .linkABank:
            router?.presentLinkABank(transactionModel: transactionModel)

        case .linkBankViaWire:
            router?.presentBankWiringInstructions(transactionModel: transactionModel)

        case .selectTarget:
            /// `TargetSelectionViewController` should only be shown for `SendP2`
            /// and `.send`. Otherwise we should show the account picker to select
            /// the destination/target.
            switch action {
            case .send:
                // `Send` supports the target selection screen rather than a
                // destination selection screen.
                router?.routeToTargetSelectionPicker(
                    transactionModel: transactionModel,
                    action: action
                )
            case .buy:
                router?.routeToDestinationAccountPicker(
                    transitionType: newState.stepsBackStack.contains(.enterAmount) ? .modal : .replaceRoot,
                    transactionModel: transactionModel,
                    action: action
                )
            case .withdraw,
                 .interestWithdraw,
                 .activeRewardsWithdraw:
                // `Withdraw` shows the destination screen modally. It does not
                // present over another screen (and thus replaces the root).
                router?.routeToDestinationAccountPicker(
                    transitionType: .replaceRoot,
                    transactionModel: transactionModel,
                    action: action
                )
            case .deposit,
                 .interestTransfer,
                 .stakingDeposit,
                 .activeRewardsDeposit,
                 .sell,
                 .swap:
                router?.routeToDestinationAccountPicker(
                    transitionType: newState.stepsBackStack.contains(.selectSource) ? .push : .replaceRoot,
                    transactionModel: transactionModel,
                    action: action
                )
            case .receive,
                 .sign,
                 .viewActivity:
                unimplemented("Action \(action) does not support 'selectTarget'")
            }

        case .kycChecks:
            router?.presentKYCFlowIfNeeded { [transactionModel] didCompleteKYC in
                if didCompleteKYC {
                    transactionModel.process(action: .validateTransactionAfterKYC)
                } else {
                    transactionModel.process(action: .returnToPreviousStep)
                }
            }

        case .validateSource:
            switch action {
            case .buy:
                router?.presentKYCFlowIfNeeded { [weak self, newState] isComplete in
                    guard let self else { return }
                    if isComplete {
                        self.linkPaymentMethodOrMoveToNextStep(for: newState)
                    } else {
                        self.transactionModel.process(action: .returnToPreviousStep)
                    }
                }
            default:
                // there's no need to validate the source account for these kinds of transactions
                transactionModel.process(action: .prepareTransaction)
            }

        case .confirmDetail:
            router?.routeToConfirmation(transactionModel: transactionModel, action: action)

        case .inProgress:
            router?.routeToInProgress(
                transactionModel: transactionModel,
                action: action
            )

        case .uxFromErrorState:
            router?.presentUXDialogFromErrorState(
                newState.errorState,
                transactionModel: transactionModel
            )

        case .uxFromUserInteraction:
            router?.presentUXDialogFromUserInteraction(
                state: newState,
                transactionModel: transactionModel
            )

        case .error:
            router?.routeToError(state: newState, model: transactionModel)

        case .selectSource:
            let canAddMoreSources = newState.userKYCStatus?.tiers.isTier2Approved ?? false
            switch action {
            case .buy where newState.stepsBackStack.contains(.enterAmount):
                router?.routeToSourceAccountPicker(
                    transitionType: .modal,
                    transactionModel: transactionModel,
                    action: action,
                    canAddMoreSources: canAddMoreSources
                )

            case .deposit:
                // `Deposit` can only be reached if the user has been
                // tier two approved. If the user has been tier two approved
                // then they can add more sources.
                router?.routeToSourceAccountPicker(
                    transitionType: .replaceRoot,
                    transactionModel: transactionModel,
                    action: action,
                    canAddMoreSources: true
                )

            case .interestTransfer,
                 .stakingDeposit,
                 .withdraw,
                 .buy,
                 .interestWithdraw,
                 .sell,
                 .swap,
                 .send,
                 .receive,
                 .viewActivity,
                 .activeRewardsDeposit,
                 .activeRewardsWithdraw:
                router?.routeToSourceAccountPicker(
                    transitionType: .replaceRoot,
                    transactionModel: transactionModel,
                    action: action,
                    canAddMoreSources: canAddMoreSources
                )

            case .sign:
                unimplemented("Sign action does not support selectSource.")
            }

        case .enterAddress:
            router?.routeToDestinationAccountPicker(
                transitionType: action == .buy ? .replaceRoot : .push,
                transactionModel: transactionModel,
                action: action
            )

        case .securityConfirmation:
            router?.routeToSecurityChecks(
                transactionModel: transactionModel
            )

        case .errorRecoveryInfo:
            router?.showErrorRecoverySuggestion(
                action: newState.action,
                errorState: newState.errorState,
                transactionModel: transactionModel,
                handleCalloutTapped: { [weak self] callout in
                    self?.handleCalloutTapped(callout: callout, state: newState)
                }
            )

        case .closed:
            transactionModel.destroy()
        }
    }

    private func handleFiatDeposit(
        sourceAccount: BlockchainAccount?,
        target: TransactionTarget?
    ) -> TransactionAction {
        if let source = sourceAccount, let target {
            return .initialiseWithSourceAndTargetAccount(
                action: .deposit,
                sourceAccount: source,
                target: target
            )
        }
        if let source = sourceAccount {
            return .initialiseWithSourceAccount(
                action: .deposit,
                sourceAccount: source
            )
        }
        if let target {
            return .initialiseWithTargetAndNoSource(
                action: .deposit,
                target: target
            )
        }
        return .initialiseWithNoSourceOrTargetAccount(
            action: .deposit
        )
    }

    private func handleCalloutTapped(callout: ErrorRecoveryState.Callout, state: TransactionState) {
        switch callout.id {
        case AnyHashable(ErrorRecoveryCalloutIdentifier.upgradeKYCTier.rawValue):
            presentKYCUpgradePrompt()
        case AnyHashable(ErrorRecoveryCalloutIdentifier.buy.rawValue):
            guard let account = state.source as? CryptoAccount else {
                return
            }
            router?.presentNewTransactionFlow(to: .buy(account)) { _ in }
        default:
            unimplemented()
        }
    }

    private func linkPaymentMethodOrMoveToNextStep(for transactionState: TransactionState) {
        guard let paymentAccount = transactionState.source as? PaymentMethodAccount else {
            impossible("The source account for Buy should be a valid payment method")
        }
        // If the select payment account's method is a suggested payment method, it means we need to link a bank or card to the user's account.
        // Otherwise, we can move on to the order details confirmation screen as we're able to process the transaction.
        guard case .suggested = paymentAccount.paymentMethodType else {
            transactionModel.process(action: .prepareTransaction)
            return
        }
        // Otherwise, make the user link a relevant payment account.
        switch paymentAccount.paymentMethod.type {
        case .bankAccount:
            transactionModel.process(action: .showBankWiringInstructions)
        case .bankTransfer:
            // Check the currency to ensure the user can link a bank via ACH until Open Banking is complete.
            if paymentAccount.paymentMethod.fiatCurrency == .USD {
                transactionModel.process(action: .showBankLinkingFlow)
            } else {
                transactionModel.process(action: .showBankWiringInstructions)
            }
        case .card:
            transactionModel.process(action: .showCardLinkingFlow)
        case .funds:
            transactionModel.process(action: .showBankWiringInstructions)
        case .applePay:
            // Nothing to link, move on to the next step
            transactionModel.process(action: .prepareTransaction)
        }
    }
}

extension OpenBankingAction {

    var currency: String {
        switch self {
        case .buy(let order):
            return order.inputValue.code
        case .deposit(let order):
            return order.amount.code
        }
    }
}

extension TransactionFlowInteractor {

    func goingBackSkipsNavigation(
        previousState: TransactionState?,
        newState: TransactionState
    ) -> Bool {
        guard let previousState,
              previousState.step.goingBackSkipsNavigation
        else {
            return false
        }

        let source = newState.source as? PaymentMethodAccount

        switch (previousState.step, newState.step) {
        /// Dismiss the select payment method screen when selecting Apple Pay in the linkPaymentMethod screen
        case (.linkPaymentMethod, .enterAmount) where source?.paymentMethod.type.isApplePay == true:
            return false
        /// Dismiss the selectSource screen after adding a new card
        case (.linkACard, .selectSource):
            return false
        default:
            return true
        }
    }
}

// MARK: - PendingTransactionPageListener

extension TransactionFlowInteractor {

    func pendingTransactionPageDidTapClose() {
        closeFlow()
    }

    func pendingTransactionPageDidTapComplete() {
        transactionModel.state
            .take(1)
            .asSingle()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [app, weak self] state in
                guard let self else { return }
                if
                    app.state.no(if: blockchain.user.is.cowboy.fan),
                    state.canPresentKYCUpgradeFlowAfterClosingTxFlow
                {
                    self.presentKYCUpgradePrompt(completion: self.closeFlow)
                } else {
                    self.closeFlow()
                }
            } onFailure: { [weak self] _ in
                self?.closeFlow()
            }
            .disposeOnDeactivate(interactor: self)
    }

    private func presentKYCUpgradePrompt(completion: (() -> Void)? = nil) {
        router?.presentKYCUpgradeFlow { _ in
            completion?()
        }
    }
}

extension TransactionState {

    var canPresentKYCUpgradeFlowAfterClosingTxFlow: Bool {
        guard let kycStatus = userKYCStatus, kycStatus.canUpgradeTier else {
            return false
        }
        return action.canPresentKYCUpgradeFlowAfterClosingTxFlow
    }
}

extension AssetAction {

    var canPresentKYCUpgradeFlowAfterClosingTxFlow: Bool {
        let canPresentKYCUpgradeFlow: Bool
        switch self {
        case .buy, .swap:
            canPresentKYCUpgradeFlow = true
        default:
            canPresentKYCUpgradeFlow = false
        }
        return canPresentKYCUpgradeFlow
    }
}

extension TransactionFlowInteractor {

    func onInit() {

        app.post(event: blockchain.ux.transaction.event.did.start)
        app.state.transaction { state in
            state.set(blockchain.app.configuration.transaction.id, to: action.rawValue)
            state.set(blockchain.ux.transaction.id, to: action.rawValue)
            state.set(blockchain.ux.transaction.source.id, to: sourceAccount?.currencyType.code)
            state.set(blockchain.ux.transaction.source.target.id, to: target?.currencyType.code)
        }

        let intent = action
        transactionModel.actions.publisher
            .withLatestFrom(transactionModel.state.publisher) { ($1, $0) }
            .sink { [app] state, action in
                let tx = state
                app.state.transaction { state in
                    switch tx.step {
                    case .initial:
                        state.set(blockchain.ux.transaction.source.id, to: tx.source?.currencyType.code)
                        state.set(blockchain.ux.transaction.source.target.id, to: tx.destination?.currencyType.code)
                    case .closed:
                        state.clear(blockchain.ux.transaction.id)
                    default:
                        break
                    }
                    if tx.pendingTransaction?.amount.isZero ?? true {
                        state.clear(blockchain.ux.transaction.source.target.quote.price)
                    }
                    switch action {
                    case .sourceAccountSelected(let source):
                        state.set(blockchain.ux.transaction.source.id, to: source.currencyType.code)
                    case .targetAccountSelected(let target):
                        state.set(blockchain.ux.transaction.source.target.id, to: target.currencyType.code)
                    default:
                        break
                    }
                }
                app.state.transaction { state in
                    switch tx.step {
                    case .initial:
                        state.set(blockchain.ux.transaction.source.label, to: tx.source?.label)
                        state.set(blockchain.ux.transaction.source.is.private.key, to: tx.source is NonCustodialAccount)
                        state.set(blockchain.ux.transaction.source.analytics.type, to: tx.source is NonCustodialAccount ? "USERKEY" : "TRADING")
                        state.set(blockchain.ux.transaction.source.target.label, to: tx.destination?.label)
                        state.set(blockchain.ux.transaction.source.target.is.private.key, to: tx.destination is NonCustodialAccount)
                        state.set(blockchain.ux.transaction.source.target.analytics.type, to: tx.destination is NonCustodialAccount ? "USERKEY" : "TRADING")
                    default:
                        break
                    }

                    switch action {
                    case .fatalTransactionError:
                        state.set(blockchain.ux.transaction.source.target.previous.did.error, to: true)
                    case .showCheckout:
                        guard let value = tx.pendingTransaction?.amount else { break }

                        let minorAmount = try value.minorAmount.json()
                        let previous = blockchain.ux.transaction.source.target.previous

                        state.clear(previous.did.error)
                        state.set(previous.input.amount, to: minorAmount)
                        state.set(previous.input.currency.code, to: value.currency.code)

                        if intent == .buy, let source = tx.source {
                            state.set(blockchain.ux.transaction.previous.payment.method.id, to: source.identifier)
                        }
                    case .sourceAccountSelected(let source):
                        state.set(blockchain.ux.transaction.source.label, to: source.label)
                        state.set(blockchain.ux.transaction.source.is.private.key, to: source is NonCustodialAccount)
                        state.set(blockchain.ux.transaction.source.analytics.type, to: tx.source is NonCustodialAccount ? "USERKEY" : "TRADING")
                    case .targetAccountSelected(let target):
                        state.set(blockchain.ux.transaction.source.target.label, to: target.label)
                        state.set(blockchain.ux.transaction.source.target.is.private.key, to: target is NonCustodialAccount)
                        state.set(blockchain.ux.transaction.source.target.analytics.type, to: tx.destination is NonCustodialAccount ? "USERKEY" : "TRADING")
                    case .executeTransaction:
                        state.set(
                            blockchain.ux.transaction.source.target.count.of.completed,
                            to: (try? state.get(blockchain.ux.transaction.source.target.count.of.completed)).or(0) + 1
                        )
                    case .updateAmount:
                        state.clear(blockchain.ux.transaction.source.target.quote.price)
                    case .updateQuote(let quote):
                        state.set(blockchain.ux.transaction.source.target.quote.value, to: quote)
                    case .updatePrice(let price):
                        if let target = tx.destination?.currencyType {
                            state.set(
                                blockchain.ux.transaction.source.target.quote.price,
                                to: price.flatMap { MoneyValue.create(minor: $0.result, currency: target) }
                            )
                        }
                    default:
                        break
                    }

                    state.clear(blockchain.ux.transaction.payment.method.is.card)
                    state.clear(blockchain.ux.transaction.payment.method.is.ApplePay)
                    state.clear(blockchain.ux.transaction.payment.method.is.funds)
                    state.clear(blockchain.ux.transaction.payment.method.is.bank.OpenBanking)
                    state.clear(blockchain.ux.transaction.payment.method.is.bank.ACH)

                    switch action {
                    case .sourceAccountSelected(let account as PaymentMethodAccount):
                        switch account.paymentMethodType {
                        case .card:
                            state.set(blockchain.ux.transaction.payment.method.is.card, to: true)
                        case .linkedBank(let bank):
                            state.set(blockchain.ux.transaction.payment.method.is.bank.OpenBanking, to: bank.partner == .yapily)
                            state.set(blockchain.ux.transaction.payment.method.is.bank.ACH, to: bank.partner == .yodlee || bank.partner == .plaid)
                        case .account:
                            state.set(blockchain.ux.transaction.payment.method.is.funds, to: true)
                        case .applePay:
                            state.set(blockchain.ux.transaction.payment.method.is.ApplePay, to: true)
                        case .suggested(let suggestion) where suggestion.type.isApplePay:
                            state.set(blockchain.ux.transaction.payment.method.is.ApplePay, to: true)
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
                switch action {
                case .validateSourceAccount:
                    app.post(value: tx.source?.identifier, of: blockchain.ux.transaction.event.validate.source)
                case .validateTransactionAfterKYC:
                    app.post(event: blockchain.ux.transaction.event.validate.transaction)
                case .sourceAccountSelected:
                    app.post(event: blockchain.ux.transaction.event.did.select.source)
                case .targetAccountSelected:
                    app.post(event: blockchain.ux.transaction.event.did.select.target)
                case .returnToPreviousStep:
                    app.post(event: blockchain.ux.transaction.event.did.go.back)
                case .cardLinkingFlowCompleted:
                    app.post(event: blockchain.ux.transaction.event.did.link.a.card)
                    app.post(event: blockchain.ux.transaction.event.did.link.payment.method)
                case .bankAccountLinked:
                    app.post(event: blockchain.ux.transaction.event.did.link.a.bank)
                    app.post(event: blockchain.ux.transaction.event.did.link.payment.method)
                default:
                    break
                }
            }
            .store(in: &bag)

        transactionModel.state.distinctUntilChanged(\.executionStatus).publisher
            .sink { [app] state in
                switch state.executionStatus {
                case .error:
                    app.post(event: blockchain.ux.transaction.event.execution.status.error)
                case .notStarted:
                    app.post(event: blockchain.ux.transaction.event.execution.status.starting)
                case .inProgress:
                    app.post(event: blockchain.ux.transaction.event.execution.status.in.progress)
                case .completed:
                    app.post(event: blockchain.ux.transaction.event.execution.status.completed)
                case .pending:
                    app.post(event: blockchain.ux.transaction.event.execution.status.pending)
                }
            }
            .store(in: &bag)

        transactionModel.state.distinctUntilChanged(\.step).publisher
            .sink { [app] state in
                let tx = state
                app.state.transaction { state in
                    state.set(blockchain.ux.error.context.action, to: tx.step.label)
                    state.set(blockchain.ux.error.context.type, to: tx.step.label)
                }

                switch tx.step {
                case .closed:
                    app.post(event: blockchain.ux.transaction.event.will.finish)
                    app.post(event: blockchain.ux.transaction.event.did.finish)
                    app.state.transaction { state in
                        state.clear(blockchain.ux.error.context.action)
                        state.clear(blockchain.ux.error.context.type)
                        // Clear the latest recurring buy frequency selected by the user
                        // Clear the eligible payment methods for recurring buy
                        // Clear the localized recurring buy frequency as well as the currently selected recurring buy frequency.
                        state.clear(blockchain.ux.transaction.action.select.recurring.buy.frequency)
                        state.clear(blockchain.ux.transaction.event.did.fetch.recurring.buy.frequencies)
                        state.clear(blockchain.ux.transaction.checkout.recurring.buy.frequency.localized)
                        state.clear(blockchain.ux.transaction.checkout.recurring.buy.frequency)
                    }
                case .inProgress:
                    app.post(event: blockchain.ux.transaction.event.in.progress)
                case .enterAddress:
                    app.post(event: blockchain.ux.transaction.event.enter.address)
                case .linkABank:
                    app.post(event: blockchain.ux.transaction.event.link.a.bank)
                case .linkACard:
                    app.post(event: blockchain.ux.transaction.event.link.a.card)
                case .linkPaymentMethod:
                    app.post(event: blockchain.ux.transaction.event.link.payment.method)
                case .selectSource:
                    app.post(event: blockchain.ux.transaction.event.select.source)
                case .selectTarget:
                    app.post(event: blockchain.ux.transaction.event.select.target)
                case .error:
                    app.post(
                        value: tx.errorState.ux(action: tx.action),
                        of: blockchain.ux.transaction.event.did.error
                    )
                default:
                    break
                }
            }
            .store(in: &bag)

        app.on(blockchain.ux.transaction.action.change.payment.method) { @MainActor [weak self] _ in
            guard let transactionModel = self?.transactionModel else { return }
            let state = try await transactionModel.state.await()
            guard state.step != .selectSource else { return }
            if state.step == .uxFromUserInteraction {
                transactionModel.process(action: .returnToPreviousStep)
            } else if state.step == .uxFromErrorState {
                // Dismisses the `UX.Dialog` and shows the source selection screen.
                transactionModel.process(action: .returnToPreviousStep)
                transactionModel.process(action: .showSourceSelection)
            } else {
                // Shows the enter amount screen and then presents the source selection screen.
                transactionModel.process(action: .showEnterAmount)
                transactionModel.process(action: .showSourceSelection)
            }
        }
        .subscribe()
        .store(in: &bag)

        app.on(blockchain.ux.transaction.action.add.card) { @MainActor [weak self] _ in
            guard let transactionModel = self?.transactionModel else { return }
            let state = try await transactionModel.state.await()
            guard state.step != .linkACard else { return }
            transactionModel.process(action: .showEnterAmount)
            transactionModel.process(action: .showCardLinkingFlow)
        }
        .subscribe()
        .store(in: &bag)

        app.on(blockchain.ux.transaction.action.add.bank) { @MainActor [weak self] _ in
            guard let transactionModel = self?.transactionModel else { return }
            let state = try await transactionModel.state.await()
            guard state.step != .linkABank else { return }
            transactionModel.process(action: .showEnterAmount)
            transactionModel.process(action: .showBankLinkingFlow)
        }
        .subscribe()
        .store(in: &bag)

        app.on(blockchain.ux.transaction.action.add.account) { @MainActor [weak self] _ in
            guard let transactionModel = self?.transactionModel else { return }
            let state = try await transactionModel.state.await()
            guard state.step != .linkPaymentMethod else { return }
            transactionModel.process(action: .showEnterAmount)
            transactionModel.process(action: .showAddAccountFlow)
        }
        .subscribe()
        .store(in: &bag)

        app.on(blockchain.ux.transaction.action.go.back.to.enter.amount) { @MainActor [weak self] _ async in
            guard let transactionModel = self?.transactionModel else { return }
            transactionModel.process(action: .showEnterAmount)
        }
        .subscribe()
        .store(in: &bag)

        app.on(blockchain.ux.transaction.action.go.back) { @MainActor [weak self] _ async in
            guard let transactionModel = self?.transactionModel else { return }
            transactionModel.process(action: .returnToPreviousStep)
        }
        .subscribe()
        .store(in: &bag)

        app.on(blockchain.ux.transaction.action.show.wire.transfer.instructions) { @MainActor [weak self] _ async throws in
            guard let transactionModel = self?.transactionModel else { return }
            let state = try await transactionModel.state.await()
            guard state.step != .linkBankViaWire else { return }
            transactionModel.process(action: .showEnterAmount)
            transactionModel.process(action: .showBankWiringInstructions)
        }
        .subscribe()
        .store(in: &bag)

        app.on(blockchain.ux.transaction.action.reset) { @MainActor [weak self] _ async in
            self?.closeFlow()
        }
        .subscribe()
        .store(in: &bag)

        app.on(
            blockchain.ux.transaction.action.select.payment.method
        ) { [weak self] event in
            guard let transactionModel = self?.transactionModel else { return }
            if let accountId = try? event.context.decode(
                blockchain.ux.transaction.action.select.payment.method.id,
                as: String.self
            ) {
                _ = self?
                    .linkedBankFactory
                    .linkedBanks
                    .asPublisher()
                    .map { accounts in
                        if let account = accounts.first(where: { account in
                            account.accountId == accountId
                        }) {
                            transactionModel.process(action: .sourceAccountSelected(account))
                        }
                    }
                    .sink(receiveValue: { _ in })
            }
        }
        .subscribe()
        .store(in: &bag)

        tasks.insert(
            Task {
                do {
                    try await actions()
                } catch {
                    app.post(error: error)
                }
            }
        )
    }

    func actions() async throws {

        try await app.transaction { app in
            try await app.set(blockchain.ux.transaction.event.should.show.disclaimer.then.enter.into, to: blockchain.ux.transaction.disclaimer[])
            try await app.set(blockchain.ux.transaction.disclaimer.finish.tap.then.close, to: true)
        }

        _ = await Task<Void, Never> {
            do {
                guard let product = try? action.earnProduct.decode(EarnProduct.self), let asset = target?.currencyType.cryptoCurrency else {
                    try await app.set(blockchain.ux.transaction.event.should.show.disclaimer.policy.discard.if, to: true)
                    return
                }

                try await app.set(blockchain.ux.transaction.event.should.show.disclaimer.policy.perform.when, to: false)

                let disabled: Bool = try await app.get(
                    blockchain.user.earn.product[product.value].asset[asset.code].limit.withdraw.is.disabled,
                    waitForValue: true
                )

                let balance = (try? await app.get(blockchain.user.earn.product[product.value].asset[asset.code].account.balance, as: MoneyValue.self))
                    ?? .zero(currency: asset)

                try await app.transaction { app in
                    try await app.set(blockchain.ux.transaction.event.should.show.disclaimer.policy.perform.when, to: disabled || product == .active)
                    try await app.set(
                        blockchain.ux.transaction.event.should.show.disclaimer.policy.discard.if,
                        to: balance > .zero(currency: balance.currency) || !disabled
                    )
                }
            } catch {
                app.post(error: error)
            }
        }.value
    }
}

extension AssetAction {
    public var earnProduct: String? {
        switch self {
        case .stakingDeposit:
            return "staking"
        case .interestTransfer, .interestWithdraw:
            return "savings"
        case .activeRewardsDeposit, .activeRewardsWithdraw:
            return "earn_cc1w"
        case _:
            return nil
        }
    }
}
