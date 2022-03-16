// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

// swiftlint:disable type_body_length
final class TransactionModel {

    // MARK: - Private Properties

    private var mviModel: MviModel<TransactionState, TransactionAction>!
    private let interactor: TransactionInteractor
    private var hasInitializedTransaction = false

    // MARK: - Public Properties

    var state: Observable<TransactionState> {
        mviModel.state
    }

    // MARK: - Init

    init(initialState: TransactionState, transactionInteractor: TransactionInteractor) {
        interactor = transactionInteractor
        mviModel = MviModel(
            initialState: initialState,
            performAction: { [weak self] state, action -> Disposable? in
                self?.perform(previousState: state, action: action)
            }
        )
    }

    // MARK: - Internal methods

    func process(action: TransactionAction) {
        mviModel.process(action: action)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func perform(previousState: TransactionState, action: TransactionAction) -> Disposable? {
        switch action {
        case .pendingTransactionStarted:
            return nil

        case .initialiseWithSourceAndTargetAccount(let action, let sourceAccount, let target, _):
            return processTargetSelectionConfirmed(
                sourceAccount: sourceAccount,
                transactionTarget: target,
                amount: nil,
                action: action
            )

        case .initialiseWithSourceAndPreferredTarget(let action, let sourceAccount, let target, _):
            return processTargetSelectionConfirmed(
                sourceAccount: sourceAccount,
                transactionTarget: target,
                amount: nil,
                action: action
            )

        case .initialiseWithNoSourceOrTargetAccount(let action, _):
            return processSourceAccountsListUpdate(
                action: action,
                targetAccount: nil
            )

        case .initialiseWithTargetAndNoSource(let action, let target, _):
            return processSourceAccountsListUpdate(
                action: action,
                targetAccount: target
            )

        case .availableSourceAccountsListUpdated:
            return nil

        case .availableDestinationAccountsListUpdated:
            return processAvailableDestinationAccountsListUpdated(state: previousState)

        case .showAddAccountFlow:
            return nil

        case .showCardLinkingFlow:
            return nil

        case .cardLinkingFlowCompleted:
            return processSourceAccountsListUpdate(
                action: previousState.action,
                targetAccount: nil
            )

        case .bankAccountLinked(let action):
            return processSourceAccountsListUpdate(action: action, targetAccount: nil, preferredMethod: .bankTransfer)

        case .bankAccountLinkedFromSource(let source, let action):
            switch action {
            case .buy:
                return nil
            default:
                return processTargetAccountsListUpdate(fromAccount: source, action: action)
            }

        case .showBankLinkingFlow,
             .bankLinkingFlowDismissed:
            return nil

        case .showBankWiringInstructions:
            return nil

        case .initialiseWithSourceAccount(let action, let sourceAccount, _):
            return processTargetAccountsListUpdate(fromAccount: sourceAccount, action: action)
        case .targetAccountSelected(let destinationAccount):
            guard let source = previousState.source else {
                fatalError("You should have a sourceAccount.")
            }
            let sourceCurrency = source.currencyType
            let isAmountValid = previousState.amount.currency == sourceCurrency
            let amount: MoneyValue? = isAmountValid ? previousState.amount : nil
            // If the `amount` `currencyType` differs from the source, we should
            // use `zero` as the amount. If not, it is safe to use the
            // `previousState.amount`.
            // The `amount` should always be the same `currencyType` as the `source`.
            return processTargetSelectionConfirmed(
                sourceAccount: source,
                transactionTarget: destinationAccount,
                amount: amount,
                action: previousState.action
            )
        case .updateAmount(let amount):
            return processAmountChanged(amount: amount)
        case .updateFeeLevelAndAmount(let feeLevel, let amount):
            return processSetFeeLevel(feeLevel, amount: amount)
        case .pendingTransactionUpdated:
            return nil
        case .performKYCChecks:
            return nil
        case .validateSourceAccount:
            return nil
        case .prepareTransaction:
            return processValidateTransactionForCheckout(oldState: previousState)
        case .showCheckout:
            return nil
        case .executeTransaction:
            return processExecuteTransaction(
                source: previousState.source,
                order: previousState.order,
                secondPassword: previousState.secondPassword
            )
        case .authorizedOpenBanking:
            return nil
        case .updateTransactionPending:
            return nil
        case .updateTransactionComplete:
            return nil
        case .fetchTransactionExchangeRates:
            return processFetchExchangeRates()
        case .transactionExchangeRatesFetched:
            return nil
        case .fetchUserKYCInfo:
            return processFetchKYCStatus()
        case .userKYCInfoFetched:
            return nil
        case .fatalTransactionError:
            return nil
        case .showErrorRecoverySuggestion:
            return nil
        case .validateTransaction:
            return processValidateTransaction()
        case .validateTransactionAfterKYC:
            return processValidateTransactionAfterKYC(oldState: previousState)
        case .createOrder:
            return processCreateOrder()
        case .orderCreated:
            process(action: .showCheckout)
            return nil
        case .orderCancelled:
            return nil
        case .resetFlow:
            interactor.reset()
            return nil
        case .returnToPreviousStep:
            let isAmountScreen = previousState.step == .enterAmount
            let isConfirmDetail = previousState.step == .confirmDetail
            let isStaticTarget = previousState.destination is StaticTransactionTarget
            // We should invalidate the transaction if
            // - we are on the amount screen; or
            // - we are on the Confirmation screen and the target is StaticTransactionTarget (a target that can't be modified).
            let shouldInvalidateTransaction = isAmountScreen || (isConfirmDetail && isStaticTarget)
            if shouldInvalidateTransaction {
                return processTransactionInvalidation(state: previousState)
            }

            // We should cancel the order if we are on the Confirmation screen.
            let shouldCancelOrder = isConfirmDetail
            if shouldCancelOrder {
                return processCancelOrder(state: previousState)
            }

            // If no check passed, we stop here (no further actions required).
            return nil
        case .sourceAccountSelected(let sourceAccount):
            if let target = previousState.destination, !previousState.availableTargets.isEmpty {
                // This is going to initialize a new PendingTransaction with a 0 amount.
                // This makes sense for transaction types like Swap where changing the source would invalidate the amount entirely.
                // For Buy, though we can simply use the amount we have in `previousState`, so the transaction ca be re-validated.
                // This also fixes an issue where the enter amount screen has the "next" button disabled after user switches source account in Buy.
                let newAmount: MoneyValue?
                if let amount = previousState.pendingTransaction?.amount, previousState.action != .swap {
                    newAmount = amount
                } else {
                    newAmount = nil
                }
                // The user has already selected a destination such as through `Deposit`. In this case we want to
                // go straight to the Enter Amount screen, since we have both target and source.
                return processTargetSelectionConfirmed(
                    sourceAccount: sourceAccount,
                    transactionTarget: target,
                    amount: newAmount,
                    action: previousState.action
                )
            }
            // If the user still has to select a destination or a list of possible destinations is not available, that's the next step.
            return processTargetAccountsListUpdate(
                fromAccount: sourceAccount,
                action: previousState.action
            )
        case .modifyTransactionConfirmation(let confirmation):
            return processModifyTransactionConfirmation(confirmation: confirmation)
        case .performSecurityChecksForTransaction:
            return nil
        case .securityChecksCompleted,
             .startPollingOrderStatus:
            guard let order = previousState.order else {
                return perform(
                    previousState: previousState,
                    action: .updateTransactionComplete
                )
            }
            return processPollOrderStatus(order: order)
        case .invalidateTransaction:
            return processInvalidateTransaction()
        case .showSourceSelection:
            return nil
        case .showTargetSelection:
            return nil
        }
    }

    func destroy() {
        mviModel.destroy()
    }

    // MARK: - Private methods

    private func processModifyTransactionConfirmation(confirmation: TransactionConfirmation) -> Disposable {
        interactor
            .modifyTransactionConfirmation(confirmation)
            .subscribe(
                onError: { error in
                    // swiftlint:disable:next line_length
                    Logger.shared.error("!TRANSACTION!> Unable to modify transaction confirmation: \(String(describing: error))")
                }
            )
    }

    private func processSetFeeLevel(_ feeLevel: FeeLevel, amount: MoneyValue?) -> Disposable {
        interactor.updateTransactionFees(with: feeLevel, amount: amount)
            .subscribe(onCompleted: {
                Logger.shared.debug("!TRANSACTION!> Tx setFeeLevel complete")
            }, onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to set feeLevel: \(String(describing: error))")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processSourceAccountsListUpdate(
        action: AssetAction,
        targetAccount: TransactionTarget?,
        preferredMethod: PaymentMethodPayloadType? = nil
    ) -> Disposable {
        interactor
            .getAvailableSourceAccounts(
                action: action,
                transactionTarget: targetAccount
            )
            .subscribe(
                onSuccess: { [weak self] sourceAccounts in
                    guard action != .buy || !sourceAccounts.isEmpty else {
                        self?.process(
                            action: .fatalTransactionError(
                                TransactionValidationFailure(state: .noSourcesAvailable)
                            )
                        )
                        return
                    }
                    self?.process(action: .availableSourceAccountsListUpdated(sourceAccounts))
                    if action == .buy, let first = sourceAccounts.first(
                        where: { ($0 as? PaymentMethodAccount)?.paymentMethodType.method.rawType == preferredMethod }
                    ) ?? sourceAccounts.first {
                        // For buy, we don't want to display the list of possible sources straight away.
                        // Instead, we want to select the default payment method returned by the API.
                        // Therefore, once we know what payment methods the user has avaialble, we should select the top one.
                        // This assumes that the API or the Service used for it sorts the payment methods so the default one is the first.
                        self?.process(action: .sourceAccountSelected(first))
                    }
                },
                onFailure: { [weak self] error in
                    Logger.shared.error("!TRANSACTION!> Unable to get source accounts: \(String(describing: error))")
                    self?.process(action: .fatalTransactionError(error))
                }
            )
    }

    private func processValidateTransaction() -> Disposable? {
        guard hasInitializedTransaction else {
            return nil
        }
        return interactor.validateTransaction
            .subscribe(onCompleted: {
                Logger.shared.debug("!TRANSACTION!> Tx validation complete")
            }, onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to processValidateTransaction: \(String(describing: error))")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processValidateTransactionAfterKYC(oldState: TransactionState) -> Disposable {
        Single.zip(
            interactor.fetchUserKYCStatus().asSingle(),
            interactor.getAvailableSourceAccounts(action: oldState.action, transactionTarget: oldState.destination)
        )
        .subscribe(on: MainScheduler.asyncInstance)
        .subscribe { [weak self] kycStatus, sources in
            guard let self = self else { return }
            // refresh the sources so the accounts and limits get updated
            self.process(action: .availableSourceAccountsListUpdated(sources))
            // update the kyc status on the transaction
            self.process(action: .userKYCInfoFetched(kycStatus))
            // update the amount as a way force the validation of the pending transaction
            self.process(action: .updateAmount(oldState.amount))
            // finally, update the state so the user can move to checkout
            self.process(action: .returnToPreviousStep) // clears the kycChecks step
        } onFailure: { [weak self] error in
            Logger.shared.debug("!TRANSACTION!> Invalid transaction: \(String(describing: error))")
            self?.process(action: .fatalTransactionError(error))
        }
    }

    private func processValidateTransactionForCheckout(oldState: TransactionState) -> Disposable {
        interactor.validateTransaction
            .subscribe { [weak self] in
                self?.process(action: .createOrder)
            } onError: { [weak self] error in
                Logger.shared.debug("!TRANSACTION!> Invalid transaction: \(String(describing: error))")
                self?.process(action: .fatalTransactionError(error))
            }
    }

    private func processCreateOrder() -> Disposable {
        interactor.createOrder()
            .subscribe { [weak self] order in
                self?.process(action: .orderCreated(order))
            } onFailure: { [weak self] error in
                self?.process(action: .fatalTransactionError(error))
            }
    }

    private func processExecuteTransaction(
        source: BlockchainAccount?,
        order: TransactionOrder?,
        secondPassword: String
    ) -> Disposable {
        // If we are processing an OpenBanking transaction we do not want to execute the transaction
        // as this is done by the backend once the customer has authorised the payment via open banking
        // and we have submitted the consent token from the deep link
        switch source {
        case let linkedBank as LinkedBankAccount where linkedBank.isYapily:
            return Disposables.create()
        case let paymentMethod as PaymentMethodAccount where paymentMethod.isYapily:
            return Disposables.create()
        default:
            break
        }

        return interactor
            .verifyAndExecute(order: order, secondPassword: secondPassword)
            .subscribe(
                onSuccess: { [weak self] result in
                    switch result {
                    case .unHashed(_, let order) where order?.isPending3DSCardOrder == true:
                        self?.process(action: .performSecurityChecksForTransaction(result))
                    case .unHashed:
                        self?.process(action: .startPollingOrderStatus)
                    case .signed,
                         .hashed:
                        self?.process(action: .updateTransactionComplete)
                    }
                },
                onFailure: { [weak self] error in
                    Logger.shared.error(
                        "!TRANSACTION!> Unable to processExecuteTransaction: \(String(describing: error))"
                    )
                    self?.process(action: .fatalTransactionError(error))
                }
            )
    }

    private func processPollOrderStatus(order: TransactionOrder) -> Disposable? {
        interactor
            .pollOrderStatusUntilDoneOrTimeout(orderId: order.identifier)
            .asSingle()
            .subscribe(on: MainScheduler.instance)
            .subscribe { [weak self] finalOrderStatus in
                switch finalOrderStatus {
                case .cancelled, .expired:
                    self?.process(
                        action: .fatalTransactionError(
                            FatalTransactionError.message(LocalizationConstants.Transaction.Error.unknownError)
                        )
                    )
                case .failed:
                    self?.process(
                        action: .fatalTransactionError(
                            FatalTransactionError.message(LocalizationConstants.Transaction.Error.generic)
                        )
                    )
                case .depositMatched, .pendingConfirmation, .pendingDeposit:
                    self?.process(action: .updateTransactionPending)
                case .finished:
                    self?.process(action: .updateTransactionComplete)
                }
            } onFailure: { [weak self] error in
                self?.process(action: .fatalTransactionError(error))
            }
    }

    private func processAmountChanged(amount: MoneyValue) -> Disposable? {
        guard hasInitializedTransaction else {
            return nil
        }
        return interactor.update(amount: amount)
            .subscribe(onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to process amount: \(error)")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processTargetSelectionConfirmed(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        amount: MoneyValue?,
        action: AssetAction
    ) -> Disposable {
        // since we have both source and destination we can simply initialize a `PendingTransaction`
        initializeTransaction(
            sourceAccount: sourceAccount,
            transactionTarget: transactionTarget,
            amount: amount,
            action: action
        )
    }

    // At this point we can build a transactor object from coincore and configure
    // the state object a bit more; depending on whether it's an internal, external,
    // bitpay or BTC Url address we can set things like note, amount, fee schedule
    // and hook up the correct processor to execute the transaction.
    private func initializeTransaction(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        amount: MoneyValue?,
        action: AssetAction
    ) -> Disposable {
        hasInitializedTransaction = false
        return interactor
            .initializeTransaction(sourceAccount: sourceAccount, transactionTarget: transactionTarget, action: action)
            .do(onNext: { [weak self] pendingTransaction in
                guard let self = self else { return }
                guard !self.hasInitializedTransaction else { return }
                self.hasInitializedTransaction.toggle()
                self.onFirstUpdate(
                    amount: amount ?? pendingTransaction.amount
                )
            })
            .subscribe(
                onNext: { [weak self] transaction in
                    self?.process(action: .pendingTransactionUpdated(transaction))
                },
                onError: { [weak self] error in
                    Logger.shared.error("!TRANSACTION!> Unable to initialize transaction: \(String(describing: error))")
                    self?.process(action: .fatalTransactionError(error))
                }
            )
    }

    private func onFirstUpdate(amount: MoneyValue) {
        process(action: .pendingTransactionStarted(allowFiatInput: interactor.canTransactFiat))
        process(action: .fetchTransactionExchangeRates)
        process(action: .fetchUserKYCInfo)
        process(action: .updateAmount(amount))
    }

    private func processTargetAccountsListUpdate(fromAccount: BlockchainAccount, action: AssetAction) -> Disposable {
        interactor
            .getTargetAccounts(sourceAccount: fromAccount, action: action)
            .subscribe { [weak self] accounts in
                self?.process(action: .availableDestinationAccountsListUpdated(accounts))
            }
    }

    private func processFetchExchangeRates() -> Disposable {
        interactor
            .transactionExchangeRates
            .subscribe { [weak self] rates in
                self?.process(action: .transactionExchangeRatesFetched(rates))
            }
    }

    private func processFetchKYCStatus() -> Disposable {
        interactor
            .fetchUserKYCStatus()
            .asSingle()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] userKYCStatus in
                self?.process(action: .userKYCInfoFetched(userKYCStatus))
            }
    }

    private func processTransactionInvalidation(state: TransactionState) -> Disposable {
        let cancelOrder: Single<Void>
        if let order = state.order {
            cancelOrder = interactor.cancelOrder(with: order.identifier)
        } else {
            cancelOrder = .just(())
        }
        return cancelOrder.subscribe(onSuccess: { [weak self] _ in
            self?.process(action: .invalidateTransaction)
        })
    }

    private func processCancelOrder(state: TransactionState) -> Disposable {
        let cancelOrder: Single<Void>
        if let order = state.order {
            cancelOrder = interactor.cancelOrder(with: order.identifier)
        } else {
            cancelOrder = .just(())
        }
        return cancelOrder.subscribe(onSuccess: { [weak self] _ in
            self?.process(action: .orderCancelled)
        })
    }

    private func processInvalidateTransaction() -> Disposable {
        interactor.invalidateTransaction()
            .subscribe()
    }

    private func processAvailableDestinationAccountsListUpdated(state: TransactionState) -> Disposable? {
        if let destination = state.destination, state.action == .buy {
            // If we refreshed the list of possible accounts we need to proceed to enter amount
            // That said, the current implementation doesn't initialize a `PendingTransaction` until
            // a target is selected. A target was already selected in this case, but the exchange rate data
            // was not updated. Triggering this action will refresh the transaction and make it load.
            // NOTE: This may not be the best approach, but it's the same used in `sourceAccountSelected` for deposit.
            // NOTE: Trying another approach like loading the fiat rates causes a crash as the transaction is not yet properly initialized.
            return Observable.just(())
                .subscribe(onNext: { [weak self] in
                    self?.process(action: .targetAccountSelected(destination))
                })
        }
        return nil
    }
}

extension PaymentMethodAccount {
    fileprivate var isYapily: Bool {
        switch paymentMethodType {
        case .linkedBank(let linkedBank):
            return linkedBank.isYapily
        case .account,
             .applePay,
             .card,
             .suggested:
            return false
        }
    }
}

extension LinkedBankData {
    fileprivate var isYapily: Bool {
        switch partner {
        case .yapily:
            return true
        case .none,
             .yodlee:
            return false
        }
    }
}

extension LinkedBankAccount {
    fileprivate var isYapily: Bool {
        switch partner {
        case .yapily:
            return true
        case .none,
             .yodlee:
            return false
        }
    }
}
