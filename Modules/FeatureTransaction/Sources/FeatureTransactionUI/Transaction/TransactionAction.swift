// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureCardPaymentDomain
import FeatureStakingDomain
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

enum TransactionAction: MviAction {

    case initialiseWithNoSourceOrTargetAccount(action: AssetAction)
    case initialiseWithSourceAccount(action: AssetAction, sourceAccount: BlockchainAccount)
    case initialiseWithSourceAndPreferredTarget(
        action: AssetAction,
        sourceAccount: BlockchainAccount,
        target: TransactionTarget
    )
    case initialiseWithSourceAndTargetAccount(
        action: AssetAction,
        sourceAccount: BlockchainAccount,
        target: TransactionTarget
    )
    case initialiseWithTargetAndNoSource(action: AssetAction, target: TransactionTarget)
    case showAddAccountFlow
    case showCardLinkingFlow
    case cardLinkingFlowCompleted(CardData)
    case bankLinkingFlowDismissed(AssetAction)
    case showBankLinkingFlow
    case bankAccountLinkedFromSource(BlockchainAccount, AssetAction)
    case bankAccountLinked(AssetAction)
    case showBankWiringInstructions
    case sourceAccountSelected(BlockchainAccount)
    case targetAccountSelected(TransactionTarget)
    case availableSourceAccountsListUpdated([BlockchainAccount])
    case availableDestinationAccountsListUpdated([BlockchainAccount])
    case fetchPrice(amount: MoneyValue?) // Anytime the amount changes
    case updateAmount(MoneyValue) // Anytime the amount changes
    case pendingTransactionUpdated(PendingTransaction)
    case performKYCChecks
    case validateSourceAccount // e.g. Give an opportunity to link a payment method
    case prepareTransaction // When continue button is tapped on enter amount screen
    case executeTransaction
    case authorizedOpenBanking
    case performSecurityChecksForTransaction(TransactionResult)
    case securityChecksCompleted
    case startPollingOrderStatus(orderId: String)
    case updateTransactionPending
    case updateTransactionComplete
    case fetchTransactionExchangeRates
    case transactionExchangeRatesFetched(TransactionExchangeRates)
    case fetchUserKYCInfo
    case userKYCInfoFetched(TransactionState.KYCStatus?)
    case updateFeeLevelAndAmount(FeeLevel, MoneyValue?)
    case validateTransaction
    case validateTransactionAfterKYC
    case createOrder
    case updatePrice(BrokerageQuote.Price)
    case updateQuote(BrokerageQuote)
    case orderCreated(TransactionOrder?)
    case orderCancelled
    case resetFlow
    case refreshPendingTransaction
    case showSourceSelection
    case showTargetSelection
    case showEnterAmount
    case showCheckout
    case returnToPreviousStep
    case pendingTransactionStarted(allowFiatInput: Bool)
    case modifyTransactionConfirmation(TransactionConfirmation)
    case fatalTransactionError(Error)
    case updateRecurringBuyFrequency(RecurringBuy.Frequency)
    case showRecurringBuyFrequencySelector
    /// Shows a `UX.Dialog` that is from user interaction and not
    /// from an `errorState`. This `UX.Dialog` is a property on `TransactionState`
    /// Both this event and `showErrorRecoverySuggestion`
    /// show an `ErrorView` but only `showErrorRecoverySuggestion` is from
    /// the transaction's `errorState`.
    case showUxDialogSuggestion(UX.Dialog)
    /// Presents either a bespoke error view *or* an ErrorView
    /// if the `TransactionState.errorState` returns a `UX.Dialog`.
    case showErrorRecoverySuggestion
    case invalidateTransaction
}

extension TransactionAction {

    // swiftlint:disable cyclomatic_complexity
    func reduce(oldState: TransactionState) -> TransactionState {
        switch self {
        case .pendingTransactionStarted(let allowFiatInput):
            var newState = oldState
            newState.errorState = .none
            newState.allowFiatInput = allowFiatInput
            newState.nextEnabled = false
            return newState.withUpdatedBackstack(oldState: oldState)

        case .updateFeeLevelAndAmount:
            return oldState

        case .updateQuote(let quote):
            var state = oldState
            state.quote = quote
            return state

        case .updatePrice(let price):
            var state = oldState
            state.price = price
            return state

        case .fetchPrice(let amount):
            return oldState.update(keyPath: \.priceInput, value: amount)

        case .showAddAccountFlow:
            switch oldState.action {
            case .buy:
                return oldState.stateForMovingForward(to: .linkPaymentMethod)
            case .withdraw, .deposit:
                return TransactionAction.showBankLinkingFlow.reduce(oldState: oldState)
            default:
                unimplemented()
            }

        case .showCardLinkingFlow:
            return oldState.stateForMovingForward(to: .linkACard)

        case .cardLinkingFlowCompleted:
            return oldState.stateForMovingOneStepBack()

        case .showBankLinkingFlow:
            return oldState.stateForMovingForward(to: .linkABank)

        case .refreshPendingTransaction:
            return oldState

        case .bankAccountLinkedFromSource,
             .bankAccountLinked:
            switch oldState.action {
            case .buy:
                return oldState.stateForMovingOneStepBack()

            case .deposit, .withdraw:
                var newState = oldState
                newState.step = .selectTarget
                return newState.withUpdatedBackstack(oldState: oldState)

            default:
                unimplemented()
            }

        case .bankLinkingFlowDismissed(let action):
            var newState = oldState
            switch action {
            case .withdraw:
                newState.step = .selectTarget
            case .deposit:
                newState.step = .selectSource
            case .buy:
                newState = oldState.stateForMovingOneStepBack()
            default:
                unimplemented()
            }
            return newState

        case .showBankWiringInstructions:
            return oldState.stateForMovingForward(to: .linkBankViaWire)

        case .initialiseWithSourceAndTargetAccount(let action, let sourceAccount, let target):
            // Some targets (eg a BitPay invoice, or a WalletConnect payload) do not allow the
            // amount to be modified, thus when the target is 'StaticTransactionTarget' we should
            // go directly to the confirmation detail screen.
            let next: TransactionFlowStep = target is StaticTransactionTarget ? .confirmDetail : .enterAmount
            return TransactionState(
                action: action,
                source: sourceAccount,
                destination: target,
                step: next
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithSourceAndPreferredTarget(let action, let sourceAccount, let target):
            return TransactionState(
                action: action,
                source: sourceAccount,
                destination: target,
                step: .enterAmount
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithTargetAndNoSource(let action, let target):
            // On buy the source is always the default payment method returned by the API
            // The source should be loaded based on this fact by the `TransactionModel` when processing the state change.
            return TransactionState(
                action: action,
                source: nil,
                destination: target,
                step: action == .buy ? .initial : .selectSource
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithNoSourceOrTargetAccount(let action):
            // On buy the source is always the default payment method returned by the API
            // The source should be loaded based on this fact by the `TransactionModel` when processing the state change.
            return TransactionState(
                action: action,
                step: action == .buy ? .initial : .selectSource
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithSourceAccount(let action, let sourceAccount):
            return TransactionState(
                action: action,
                source: sourceAccount
            )

        case .fetchTransactionExchangeRates:
            return oldState

        case .transactionExchangeRatesFetched(let exchangeRates):
            return oldState.update(keyPath: \.exchangeRates, value: exchangeRates)

        case .fetchUserKYCInfo:
            return oldState

        case .userKYCInfoFetched(let kycStatus):
            return oldState.update(keyPath: \.userKYCStatus, value: kycStatus)

        case .sourceAccountSelected(let sourceAccount):
            var newState = oldState
            newState.source = sourceAccount
            newState.exchangeRates = nil

            // The standard flow is [select source] -> [select target] -> [enter amount] -> ...
            // Therefore if we have ... -> [enter amount] -> [select source] -> ... we should go back to [enter amount]
            let isGoingBack = newState.stepsBackStack.contains { $0 == .enterAmount }
            newState.step = isGoingBack ? .enterAmount : newState.step
            return newState
                .update(keyPath: \.isGoingBack, value: isGoingBack)
                .withUpdatedBackstack(oldState: oldState)

        case .targetAccountSelected(let destinationAccount):
            // Some targets (eg a BitPay invoice, or a WalletConnect payload) do not allow the
            // amount to be modified, thus when the target is 'StaticTransactionTarget' we should
            // go directly to the confirmation detail screen.
            let destinationIsStaticTransactionTarget = destinationAccount is StaticTransactionTarget
            let step: TransactionFlowStep = destinationIsStaticTransactionTarget ? .confirmDetail : .enterAmount
            var newState = oldState
            newState.errorState = .none
            newState.destination = destinationAccount
            newState.nextEnabled = false
            newState.step = step
            newState.exchangeRates = nil

            // The standard flow is [select source] -> [select target] -> [enter amount] -> ...
            // Therefore if we have ... -> [enter amount] -> [select target] -> ... we should go back to [enter amount]
            let isGoingBack = newState.stepsBackStack.contains { $0 == .enterAmount }
            return newState
                .update(keyPath: \.isGoingBack, value: isGoingBack)
                .withUpdatedBackstack(oldState: oldState)

        case .updateAmount:
            // Amount is updated after validation.
            var newState = oldState
            newState.nextEnabled = false
            return newState

        case .availableSourceAccountsListUpdated(let sources):
            var newState = oldState
            newState.availableSources = sources
            return newState.withUpdatedBackstack(oldState: oldState)

        case .availableDestinationAccountsListUpdated(let targets):
            let newStep: TransactionFlowStep
            if oldState.source != nil, oldState.destination != nil {
                // This operation could be done just to refresh the list of possible targets. E.g. for buy.
                // If we have both source and destination, the next step should be to enter an amount.
                newStep = .enterAmount
            } else {
                // If there's not target account when this list is updated, we should have the user select one.
                newStep = .selectTarget
            }
            return oldState
                .update(keyPath: \.availableTargets, value: targets.filter(TransactionTarget.self))
                .update(keyPath: \.step, value: newStep)
                .update(keyPath: \.isGoingBack, value: false)
                .withUpdatedBackstack(oldState: oldState)

        case .pendingTransactionUpdated(let pendingTransaction):
            var newState = oldState
            newState.pendingTransaction = pendingTransaction
            newState.nextEnabled = pendingTransaction.validationState == .canExecute
            newState.errorState = pendingTransaction.validationState.mapToTransactionErrorState
            return newState.withUpdatedBackstack(oldState: oldState)

        case .showSourceSelection:
            return oldState
                .update(keyPath: \.step, value: .selectSource)
                .update(keyPath: \.isGoingBack, value: oldState.action != .buy)
                .withUpdatedBackstack(oldState: oldState)

        case .showTargetSelection:
            return oldState
                .update(keyPath: \.step, value: .selectTarget)
                .update(keyPath: \.isGoingBack, value: oldState.action != .buy)
                .withUpdatedBackstack(oldState: oldState)

        case .showEnterAmount:
            return oldState
                .update(keyPath: \.step, value: .enterAmount)
                .update(keyPath: \.isGoingBack, value: false)
                .update(keyPath: \.errorState, value: .none)
                .update(
                    keyPath: \.stepsBackStack,
                    value: oldState.stepsBackStack.split(separator: .enterAmount).first.map(Array.init).or([])
                )

        case .performKYCChecks:
            return oldState.stateForMovingForward(to: .kycChecks)
                // disable next until kyc checks are done
                .update(keyPath: \.nextEnabled, value: false)

        case .validateSourceAccount:
            return oldState.stateForMovingForward(to: .validateSource)

        case .prepareTransaction:
            var newState = oldState
            newState.nextEnabled = false // Don't enable until we get a validated pendingTx from the interactor
            return newState

        case .updateRecurringBuyFrequency:
            var newState = oldState
            newState.nextEnabled = false
            return newState

        case .showRecurringBuyFrequencySelector:
            return oldState.stateForMovingForward(to: .recurringBuyFrequencySelector)

        case .createOrder:
            return oldState

        case .orderCreated(let order):
            var newState = oldState
            if newState.executionStatus == .inProgress, newState.source?.isYapily == true {
                newState.step = .authorizeOpenBanking
            }
            return newState
                .update(keyPath: \.order, value: order)

        case .orderCancelled:
            return oldState
                .update(keyPath: \.order, value: nil)

        case .showCheckout:
            return oldState.stateForMovingForward(to: .confirmDetail)

        case .executeTransaction:
            var newState = oldState
            newState.nextEnabled = false
            if newState.order.isNotNil, newState.source?.isYapily == true {
                newState.step = .authorizeOpenBanking
            } else {
                newState.step = .inProgress
            }
            newState.executionStatus = .inProgress
            return newState.withUpdatedBackstack(oldState: oldState)

        case .authorizedOpenBanking:
            var newState = oldState
            newState.nextEnabled = false
            newState.executionStatus = .pending
            return newState.withUpdatedBackstack(oldState: oldState)

        case .performSecurityChecksForTransaction(let transactionResult):
            guard case .unHashed(_, _, let order) = transactionResult else {
                impossible("This should only ever happen for transactions requiring 3D Secure or similar checks")
            }
            return oldState
                .update(keyPath: \.order, value: order)
                .stateForMovingForward(to: .securityConfirmation)

        case .securityChecksCompleted:
            return oldState.stateForMovingOneStepBack()

        case .startPollingOrderStatus:
            return oldState

        case .updateTransactionPending:
            return oldState
                .update(keyPath: \.nextEnabled, value: true)
                .update(keyPath: \.executionStatus, value: .pending)
                .withUpdatedBackstack(oldState: oldState)

        case .updateTransactionComplete:
            var newState = oldState
            newState.nextEnabled = true
            newState.executionStatus = .completed
            return newState.withUpdatedBackstack(oldState: oldState)

        case .fatalTransactionError(OrderConfirmationServiceError.applePay(ApplePayError.cancelled)):
            return oldState
                .update(keyPath: \.nextEnabled, value: true)
                .update(keyPath: \.executionStatus, value: .inProgress)
                .stateForMovingOneStepBack()

        case .fatalTransactionError(let error):
            Logger.shared.error(error)
            var newState = oldState
            newState.nextEnabled = true
            newState.step = .error
            newState.errorState = .fatalError(FatalTransactionError(error: error))
            newState.executionStatus = .error
            return newState.withUpdatedBackstack(oldState: oldState)

        case .showUxDialogSuggestion(let dialog):
            var newState = oldState
            newState.dialog = dialog
            return newState
                .stateForMovingForward(to: .uxFromUserInteraction)

        case .showErrorRecoverySuggestion:
            if oldState.errorState.isUX {
                return oldState
                    .stateForMovingForward(to: .uxFromErrorState)
            }
            return oldState
                .stateForMovingForward(to: .errorRecoveryInfo)

        case .validateTransaction,
             .validateTransactionAfterKYC:
            return oldState

        case .resetFlow:
            var newState = oldState
            newState.step = .closed
            return newState

        case .returnToPreviousStep:
            var newState = oldState.stateForMovingOneStepBack()
            // HOTFIX: this check fixes a problem when navigating back using a navigation controller's pop mechanism
            if oldState.step == .selectTarget, newState.step == .selectSource {
                // Fixes a crash with precondition in some TransactionEngines like Swap.
                // The issue was caused by the fact we don't clear state when moving back from step to step.
                // This caused the destination never to be removed, so when popping from enter amount to destination picker to source picker,
                // selecting a new source would cause us to move directly to the enter amount screen with the old destination selected.
                // Some transaction engines like swap check for the source and destination currency to match or not not match as a precondition.
                newState.destination = nil
            }
            newState.nextEnabled = oldState.step == .confirmDetail || newState.pendingTransaction?.validationState == .canExecute
            return newState

        case .modifyTransactionConfirmation:
            return oldState
                .update(keyPath: \.nextEnabled, value: false)

        case .invalidateTransaction:
            return oldState
                .update(keyPath: \.pendingTransaction, value: nil)
                .update(keyPath: \.nextEnabled, value: false)
                .update(keyPath: \.quote, value: nil)
                .update(keyPath: \.price, value: nil)
                .update(keyPath: \.priceInput, value: nil)
                .withUpdatedBackstack(oldState: oldState)
        }
    }

    // swiftlint:enable cyclomatic_complexity

    func isValid(for oldState: TransactionState) -> Bool {
        switch self {
        default:
            return true
        }
    }
}

enum FatalTransactionError: Error, Equatable, CustomStringConvertible {
    case rxError(RxError)
    case generic(Error)
    case message(String)

    /// Initializes the enum with the given error, this check if it's an RxError and assigns correctly
    /// - Parameter error: An `Error` to be assigned
    init(error: Error) {
        guard let error = error as? RxError else {
            self = .generic(error)
            return
        }
        self = .rxError(error)
    }

    var error: Error {
        switch self {
        case .generic(let error):
            return error
        case .rxError(let error):
            return error
        default:
            return self
        }
    }

    var rxError: RxError? {
        switch self {
        case .rxError(let error):
            return error
        default:
            return nil
        }
    }

    var description: String {
        switch self {
        case .rxError(let error):
            return error.debugDescription
        case .generic(let error):
            return String(describing: error)
        case .message(let message):
            return message
        }
    }

    var localizedDescription: String {
        switch self {
        case .rxError(let error):
            return "\(LocalizationConstants.Errors.genericError) \n\(error.debugDescription)"
        case .generic(let error):
            return String(describing: error)
        case .message(let message):
            return message
        }
    }

    static func == (lhs: FatalTransactionError, rhs: FatalTransactionError) -> Bool {
        switch (lhs, rhs) {
        case (.rxError(let left), .rxError(let right)):
            return left.debugDescription == right.localizedDescription
        case (.generic(let left), .generic(let right)):
            return left.localizedDescription == right.localizedDescription
        case (.message(let lhs), .message(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension TransactionState {

    fileprivate func stateForMovingForward(to nextStep: TransactionFlowStep) -> TransactionState {
        var newStepsBackStack = stepsBackStack
        if step.addToBackStack {
            newStepsBackStack.append(step)
        }
        return update(keyPath: \.isGoingBack, value: false)
            .update(keyPath: \.step, value: nextStep)
            .update(keyPath: \.stepsBackStack, value: newStepsBackStack)
    }

    fileprivate func stateForMovingOneStepBack() -> TransactionState {
        var stepsBackStack = stepsBackStack
        let previousStep = stepsBackStack.popLast() ?? .initial
        return update(keyPath: \.stepsBackStack, value: stepsBackStack)
            .update(keyPath: \.step, value: previousStep)
            .update(keyPath: \.isGoingBack, value: true)
            // Not sure why we're resetting this to none, but if we're coming back from an error recovery suggestion
            // we don't want to remove that error state so the user can still see the error on screen if needed.
            .update(keyPath: \.errorState, value: step == .errorRecoveryInfo ? errorState : .none)
    }

    fileprivate func withUpdatedBackstack(oldState: TransactionState) -> TransactionState {
        if !isGoingBack, oldState.step != step, oldState.step.addToBackStack {
            var newState = self
            var newStack = oldState.stepsBackStack
            newStack.append(oldState.step)
            newState.stepsBackStack = newStack
            return newState
        }
        return self
    }
}

extension TransactionValidationState {

    var mapToTransactionErrorState: TransactionErrorState {
        switch self {
        case .uninitialized, .canExecute:
            return .none
        case .unknownError:
            return .unknownError
        case .nabuError(let error):
            return .nabuError(error)
        case .insufficientFunds(let balance, let desired, let sourceCurrency, let targetCurrency):
            return .insufficientFunds(balance, desired, sourceCurrency, targetCurrency)
        case .sourceAccountUsageIsBlocked(let ux):
            return .ux(ux)
        case .belowFees(let fees, let balance):
            return .belowFees(fees, balance)
        case .belowMinimumLimit(let minimumLimit):
            return .belowMinimumLimit(minimumLimit)
        case .overMaximumSourceLimit(let maxLimit, let label, let desiredAmount):
            return .overMaximumSourceLimit(maxLimit, label, desiredAmount)
        case .overMaximumPersonalLimit(let effectiveLimit, let available, let suggestedUpgrade):
            return .overMaximumPersonalLimit(effectiveLimit, available, suggestedUpgrade)

        // MARK: Unchecked

        case .addressIsContract:
            return .addressIsContract
        case .invalidAddress:
            return .invalidAddress
        case .invoiceExpired:
            return .unknownError
        case .optionInvalid:
            return .optionInvalid
        case .transactionInFlight:
            return .transactionInFlight
        case .pendingOrdersLimitReached:
            return .pendingOrdersLimitReached
        case .accountIneligible,
             .noSourcesAvailable,
             .incorrectSourceCurrency,
             .incorrectDestinationCurrency,
             .insufficientInterestWithdrawalBalance:
            return .unknownError
        }
    }
}
