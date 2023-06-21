// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureOpenBankingDomain
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public final class TransactionModel {

    // MARK: - Private Properties

    private var mviModel: MviModel<TransactionState, TransactionAction>!
    internal let interactor: TransactionInteractor
    internal private(set) var hasInitializedTransaction = false

    private let app: AppProtocol
    private let analyticsHook: TransactionAnalyticsHook
    private let sendEmailNotificationService: SendEmailNotificationServiceAPI
    private var cancellables = Set<AnyCancellable>()
    private var bag = DisposeBag()

    // MARK: - Public Properties

    var state: Observable<TransactionState> {
        mviModel.state
    }

    var actions: Observable<TransactionAction> {
        mviModel.actions
    }

    // MARK: - Init

    init(
        app: AppProtocol = resolve(),
        initialState: TransactionState,
        transactionInteractor: TransactionInteractor,
        analyticsHook: TransactionAnalyticsHook = resolve(),
        sendEmailNotificationService: SendEmailNotificationServiceAPI = resolve()
    ) {
        self.app = app
        self.analyticsHook = analyticsHook
        self.sendEmailNotificationService = sendEmailNotificationService
        self.interactor = transactionInteractor
        self.mviModel = MviModel(
            initialState: initialState,
            performAction: { [weak self] state, action -> Disposable? in
                self?.perform(previousState: state, action: action)
            }
        )
        setup()
    }

    private func setup() {
        streamPrices().disposed(by: bag)
    }

    // MARK: - Internal methods

    func process(action: TransactionAction) {
        mviModel.process(action: action)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func perform(previousState: TransactionState, action: TransactionAction) -> Disposable? {
        switch action {
        case .pendingTransactionStarted:
            return streamQuotes()

        case .initialiseWithSourceAndTargetAccount(let action, let sourceAccount, let target):
            return Disposables.create(
                processTargetSelectionConfirmed(
                    sourceAccount: sourceAccount,
                    transactionTarget: target,
                    amount: (target as? CryptoActiveRewardsWithdrawTarget)?.amount,
                    action: action
                ), processSourceAccountsListUpdate(
                    action: action,
                    targetAccount: target
                ), processTargetAccountsListUpdate(
                    fromAccount: sourceAccount,
                    action: action
                )
            )

        case .initialiseWithSourceAndPreferredTarget(let action, let sourceAccount, let target):
            return processTargetSelectionConfirmed(
                sourceAccount: sourceAccount,
                transactionTarget: target,
                amount: nil,
                action: action
            )

        case .initialiseWithNoSourceOrTargetAccount(let action):
            if action == .swap && app.remoteConfiguration.yes(if: blockchain.app.configuration.new.swap.flow.is.enabled) {
                return nil
            }

            return processSourceAccountsListUpdate(
                action: action,
                targetAccount: nil
            )

        case .initialiseWithTargetAndNoSource(let action, let target):
            if action == .swap && app.remoteConfiguration.yes(if: blockchain.app.configuration.new.swap.flow.is.enabled) {
                return nil
            }

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

        case .cardLinkingFlowCompleted(let data):
            app.state.set(blockchain.ux.transaction.previous.payment.method.id, to: data.identifier)
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

        case .initialiseWithSourceAccount(let action, let sourceAccount):
            if action == .swap && app.remoteConfiguration.yes(if: blockchain.app.configuration.new.swap.flow.is.enabled) {
                return nil
            }
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
        case .pendingTransactionUpdated(let pendingTransaction):
            return validateTransactionIfNeeded(pendingTransaction, for: previousState.action)
        case .performKYCChecks:
            return nil
        case .validateSourceAccount:
            return nil
        case .prepareTransaction:
            return processValidateTransactionForCheckout(oldState: previousState)
        case .showCheckout:
            return nil
        case .executeTransaction:
            analyticsHook.onTransactionSubmitted(with: previousState)
            return processExecuteTransaction(
                source: previousState.source,
                order: previousState.order
            )
        case .authorizedOpenBanking:
            return nil
        case .updateTransactionPending:
            return nil
        case .updateTransactionComplete:
            return nil
        case .updateRecurringBuyFrequency(let frequency):
            return processRecurringBuyFrequencyUpdated(frequency)
        case .showRecurringBuyFrequencySelector:
            return nil
        case .fetchTransactionExchangeRates:
            return processFetchExchangeRates()
        case .transactionExchangeRatesFetched:
            return nil
        case .fetchUserKYCInfo:
            return processFetchKYCStatus()
        case .userKYCInfoFetched:
            return nil
        case .fatalTransactionError, .validationError:
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
            if previousState.executionStatus != .inProgress {
                process(action: .showCheckout)
            }
            return nil
        case .orderCancelled:
            interactor.resetProcessor()
            return initializeTransaction(
                sourceAccount: previousState.source!,
                transactionTarget: previousState.destination!,
                amount: previousState.amount,
                action: previousState.action
            )
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
            let shouldCancelOrder = isConfirmDetail && previousState.order.isNotNil
            if shouldCancelOrder {
                return processCancelOrder(state: previousState)
            }

            // If no check passed, we stop here (no further actions required).
            return processValidateTransaction()
        case .sourceAccountSelected(let sourceAccount):
            if let target = previousState.destination, previousState.availableTargets?.isEmpty == false {
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
        case .performSecurityChecks:
            return nil
        case .performSecurityChecksForTransaction:
            return nil
        case .securityChecksCompleted:
            guard let order = previousState.order else {
                return perform(
                    previousState: previousState,
                    action: .updateTransactionComplete
                )
            }
            return processPollOrderStatus(orderId: order.identifier, state: previousState)
        case .startPollingOrderStatus(let orderId):
            return processPollOrderStatus(orderId: orderId, state: previousState)
        case .invalidateTransaction:
            return processInvalidateTransaction()
        case .showSourceSelection:
            return nil
        case .showTargetSelection:
            return nil
        case .showEnterAmount:
            return nil
        case .showUxDialogSuggestion:
            return nil
        case .updateQuote(let quote):
            return updateQuote(quote)
        case .updatePrice(let price):
            return updatePrice(price)
        case .fetchPrice:
            return nil
        case .refreshPendingTransaction:
            return refresh()
        case .confirmSwap:
            return processValidateTransactionForCheckout(oldState: previousState)
        }
    }

    func destroy() {
        mviModel.destroy()
    }

    func refresh() -> Disposable {
        Disposables.create { [weak self] in
            guard let self, let tx = interactor.refresh() else { return }
            process(action: .pendingTransactionUpdated(tx))
        }
    }

    // MARK: - Private methods

    func streamPrices() -> Disposable {
        state.publisher.ignoreFailure(setFailureType: Never.self)
            .map { [app] state in Pair(state.pricesRequest(app), state.isStreamingPrices) }
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map(\.tuple)
            .map { [interactor] quote, isStreamingPrices -> AnyPublisher<Result<BrokerageQuote.Price, UX.Error>?, Never> in
                guard let quote else { return .just(nil) }
                return isStreamingPrices
                    ? interactor.prices(quote).map(Optional.some).eraseToAnyPublisher()
                    : .just(nil)
            }
            .switchToLatest()
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .compacted()
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [weak self] result in
                    switch result {
                    case .success(let price):
                        self?.process(action: .updatePrice(price))
                    case .failure(let error):
                        self?.process(action: .validationError(error))
                    }
                },
                onError: { [app] error in
                    app.post(error: error)
                }
            )
    }

    func streamQuotes() -> Disposable {
        state.publisher.ignoreFailure(setFailureType: Never.self)
            .map { [app] state in Pair(state.quoteRequest(app), state.isStreamingQuotes) }
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map(\.tuple)
            .map { [interactor] quote, isStreamingQuotes -> AnyPublisher<Result<BrokerageQuote, UX.Error>?, Never> in
                guard let quote else { return .just(nil) }
                return isStreamingQuotes
                    ? interactor.quotes(quote).map(Optional.some).eraseToAnyPublisher()
                    : .just(nil)
            }
            .switchToLatest()
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .compacted()
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [weak self] output in
                    switch output {
                    case .success(let quote):
                        self?.app.state.set(blockchain.ux.transaction.source.target.quote.value, to: quote)
                        self?.process(action: .updateQuote(quote))
                    case .failure(let error):
                        self?.process(action: .fatalTransactionError(error))
                    }
                },
                onError: { [app] error in
                    app.post(error: error)
                }
            )
    }

    func updateQuote(_ quote: BrokerageQuote) -> Disposable {
        interactor.updateQuote(quote)
            .subscribe(
                onError: { _ in
                    Logger.shared.error("!TRANSACTION!> Unable to update quote")
                }
            )
    }

    func updatePrice(_ quote: BrokerageQuote.Price) -> Disposable {
        interactor.updatePrice(quote)
            .subscribe(
                onError: { _ in
                    Logger.shared.error("!TRANSACTION!> Unable to update quote price")
                }
            )
    }

    private func processModifyTransactionConfirmation(confirmation: TransactionConfirmation) -> Disposable {
        interactor
            .modifyTransactionConfirmation(confirmation)
            .subscribe(
                onError: { error in
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

                    let previousMethod = try? self?.interactor.app.state.get(
                        blockchain.ux.transaction.previous.payment.method.id
                    ) as? String

                    if action == .buy, let first = sourceAccounts.first(
                        where: { ($0 as? PaymentMethodAccount)?.paymentMethodType.method.rawType == preferredMethod }
                    ) ?? sourceAccounts.first(
                        where: { account in (account.identifier as? String) == previousMethod }
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
            guard let self else { return }
            // refresh the sources so the accounts and limits get updated
            process(action: .availableSourceAccountsListUpdated(sources))
            // update the kyc status on the transaction
            process(action: .userKYCInfoFetched(kycStatus))
            // update the amount as a way force the validation of the pending transaction
            process(action: .updateAmount(oldState.amount))
            // finally, update the state so the user can move to checkout
            process(action: .returnToPreviousStep) // clears the kycChecks step
        } onFailure: { [weak self] error in
            Logger.shared.debug("!TRANSACTION!> Invalid transaction: \(String(describing: error))")
            self?.process(action: .fatalTransactionError(error))
        }
    }

    private func processRecurringBuyFrequencyUpdated(_ frequency: RecurringBuy.Frequency) -> Disposable {
        guard app.remoteConfiguration.yes(if: blockchain.app.configuration.recurring.buy.is.enabled) else {
            Logger.shared.debug("!TRANSACTION!> Recurring buy feature flag disabled.")
            return Disposables.create()
        }
        return interactor
            .updateRecurringBuyFrequency(frequency)
            .subscribe { [app] _ in
                app.state.transaction { state in
                    state.set(blockchain.ux.transaction.checkout.recurring.buy.frequency.localized, to: frequency.description)
                    state.set(blockchain.ux.transaction.checkout.recurring.buy.frequency, to: frequency.rawValue)
                }
                Logger.shared.debug("!TRANSACTION!> Tx recurringBuyFrequency complete")
            } onFailure: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to set recurringBuyFrequency: \(String(describing: error))")
                self?.process(action: .fatalTransactionError(error))
            }
    }

    private func validateTransactionIfNeeded(_ transaction: PendingTransaction, for action: AssetAction) -> Disposable? {
        guard transaction.confirmations.isEmpty, action == .activeRewardsWithdraw else {
            return nil
        }
        return interactor.validateTransaction.subscribe()
    }

    private func processValidateTransactionForCheckout(oldState: TransactionState) -> Disposable {
        interactor
            .validateTransaction
            .subscribe { [weak self] in
                self?.process(action: .showCheckout)
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
        order: TransactionOrder?
    ) -> Disposable {

        // If we are processing an OpenBanking transaction we do not want to execute the transaction
        // as this is done by the backend once the customer has authorised the payment via open banking
        // and we have submitted the consent token from the deep link
        if order == nil, source?.isYapily == true {
            return processCreateOrder()
        }

        return interactor.verifyAndExecute(order: order)
            .subscribe(
                onSuccess: { [weak self] result in
                    self?.triggerSendEmailNotification(source: source, transactionResult: result)
                    switch result {
                    case .unHashed(_, let orderId, let orderOpaque):
                        if let orderDetails = orderOpaque as? OrderDetails, orderDetails.isPending3DSCardOrder {
                            self?.process(action: .performSecurityChecksForTransaction(result))
                        } else if let orderId {
                            self?.process(action: .startPollingOrderStatus(orderId: orderId))
                        } else {
                            self?.process(action: .updateTransactionComplete)
                        }
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

    private func triggerSendEmailNotification(
        source: BlockchainAccount?,
        transactionResult: TransactionResult
    ) {
        guard source?.accountType == .nonCustodial else {
            return
        }
        switch transactionResult {
        case .hashed(txHash: let txHash, amount: .some(let amount)):
            sendEmailNotificationService
                .postSendEmailNotificationTrigger(
                    moneyValue: amount,
                    txHash: txHash
                )
                .subscribe()
                .store(in: &cancellables)
        default:
            break
        }
    }

    private func processPollOrderStatus(orderId: String, state: TransactionState) -> Disposable? {
        if state.action == .buy {
            return interactor
                .pollBuyOrderStatusUntilDoneOrTimeout(orderId: orderId)
                .handleEvents(receiveSubscription: { [app] _ in
                    let eventCVVPayment = blockchain.ux.payment.method.vgs.cvv.sent.payment.ids
                    let eventCVVPaymentIds = (try? app.state.get(eventCVVPayment, as: [String].self)) ?? []
                    app.state.set(eventCVVPayment, to: eventCVVPaymentIds)

                    let event3DSPayment = blockchain.ux.payment.method.vgs.security.check.sent.payment.ids
                    let event3DSPaymentIds = (try? app.state.get(event3DSPayment, as: [String].self)) ?? []
                    app.state.set(event3DSPayment, to: event3DSPaymentIds)
                })
                .asObservable()
                .subscribe(onNext: { [weak self, app] order in
                    let isVGSEnabled: Bool = isVGSEnabledOrUserHasCassyTagOnAlpha(app)
                    if isVGSEnabled {

                        if order.needCvv, app.state.doesNotContain(blockchain.ux.payment.method.vgs.order[orderId].sent.cvv) {
                            app.post(
                                event: blockchain.ux.payment.method.vgs.cvv.is.required,
                                context: [
                                    blockchain.ux.payment.method.vgs.cvv.is.required.payment.id: orderId,
                                    blockchain.ux.payment.method.vgs.cvv.is.required.payment.method.id: order.paymentMethodId
                                ]
                            )

                            self?.waitForCvvToBeSent(for: orderId)
                            return
                        }

                        if order.isPending3DSCardOrder {
                            let event = blockchain.ux.payment.method.vgs.security.check.sent.payment.ids
                            var ids = (try? app.state.get(event, as: [String].self)) ?? []

                            // If ids contains the orderId, means we already asked for 3DS for this order.
                            if ids.doesNotContain(orderId) {
                                ids.append(orderId)

                                app.state.transaction { state in
                                    state.set(event, to: ids)
                                }

                                self?.process(action: .performSecurityChecks(order))
                                return
                            }
                        }
                    }
                    switch order.state {
                    case .failed, .expired, .cancelled:
                        if let error = order.ux {
                            self?.process(
                                action: .fatalTransactionError(UX.Error(nabu: error))
                            )
                        } else if let error = order.error {
                            self?.process(
                                action: .fatalTransactionError(OpenBanking.Error.code(error))
                            )
                        } else {
                            self?.process(
                                action: .fatalTransactionError(
                                    FatalTransactionError.message(LocalizationConstants.Transaction.Error.generic)
                                )
                            )
                        }
                    case .depositMatched, .pendingConfirmation, .pendingDeposit:
                        self?.process(action: .updateTransactionPending)
                    case .finished:
                        self?.clearVGSPendingPaymentIds()
                        self?.process(action: .updateTransactionComplete)
                    }
                }, onError: { [weak self] error in
                    self?.clearVGSPendingPaymentIds()
                    self?.process(action: .fatalTransactionError(error))
                })
        } else {
            return interactor
                .pollSwapOrderStatusUntilDoneOrTimeout(orderId: orderId)
                .asObservable()
                .subscribe(onNext: { [weak self] finalOrderStatus in
                    switch finalOrderStatus {
                    case .expired, .pendingRefund, .refunded, .delayed, .none:
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
                    case .inProgress:
                        self?.process(action: .updateTransactionPending)
                    case .complete:
                        self?.process(action: .updateTransactionComplete)
                    }
                }, onError: { [weak self] error in
                    self?.process(action: .fatalTransactionError(error))
                })
        }
    }

    private func clearVGSPendingPaymentIds() {
        app.state.set(blockchain.ux.payment.method.vgs.cvv.sent.payment.ids, to: Array<String>())
        app.state.set(blockchain.ux.payment.method.vgs.security.check.sent.payment.ids, to: Array<String>())
    }

    private func processAmountChanged(amount: MoneyValue) -> Disposable? {
        guard hasInitializedTransaction else {
            return nil
        }
        return interactor.update(amount: amount)
            .subscribe(on: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onError: { [weak self] error in
                    Logger.shared.error("!TRANSACTION!> Unable to process amount: \(error)")
                    self?.process(action: .fatalTransactionError(error))
                }
            )
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
        app.state.transaction { state in
            state.set(blockchain.ux.transaction.source.id, to: sourceAccount.currencyType.code)
            state.set(blockchain.ux.transaction.source.target.id, to: transactionTarget.currencyType.code)
        }
        return interactor
            .initializeTransaction(sourceAccount: sourceAccount, transactionTarget: transactionTarget, action: action)
            .do(onNext: { [weak self] pendingTransaction in
                guard let self else { return }
                guard !hasInitializedTransaction else { return }
                hasInitializedTransaction.toggle()
                onFirstUpdate(
                    amount: amount ?? pendingTransaction.amount
                )
            })
            .subscribe(
                onNext: { [weak self] transaction in
                    guard let self else { return }
                    Task {
                        try await self.app.set(blockchain.ux.transaction.source.account.id, to: sourceAccount.identifier, debug: true)
                        try await self.app.set(blockchain.ux.transaction.source.target.account.id, to: (transactionTarget as? BlockchainAccount)?.identifier, debug: true)
                        self.process(action: .pendingTransactionUpdated(transaction))
                    }
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
        if amount.isPositive {
            process(action: .updateAmount(amount))
        }
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

    private func waitForCvvToBeSent(for orderId: String) {
        guard isVGSEnabledOrUserHasCassyTagOnAlpha(app) else {
            return
        }
        app.on(
            blockchain.ux.payment.method.vgs.cvv.sent
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self, app] event in
            if let error: NabuError = try? event.context[blockchain.ux.payment.method.vgs.cvv.sent.failed.with.error].decode() {
                self?.process(
                    action: .fatalTransactionError(UX.Error(nabu: error))
                )
            } else {
                app.state.set(blockchain.ux.payment.method.vgs.order[orderId].sent.cvv, to: true)
                self?.process(action: .startPollingOrderStatus(orderId: orderId))
            }
        })
        .store(in: &cancellables)
    }
}

extension TransactionState {

    var profile: BrokerageQuote.Profile? {
        switch action {
        case .buy:
            return .buy
        case .sell:
            switch source {
            case is NonCustodialAccount:
                return .swapPKWToTrading
            case is TradingAccount:
                return .swapTradingToTrading
            default:
                return nil
            }
        case .swap:
            switch (source, destination) {
            case (is NonCustodialAccount, is NonCustodialAccount):
                return .swapPKWToPKW
            case (is NonCustodialAccount, is TradingAccount):
                return .swapPKWToTrading
            case (is TradingAccount, is TradingAccount):
                return .swapTradingToTrading
            default:
                return nil
            }
        default:
            return nil
        }
    }

    func pricesRequest(_ app: AppProtocol) -> BrokerageQuote.Request? {
        guard let request = quoteRequest(app) else {
            return nil
        }
        return request.transform(
            input: priceInput,
            sourceToDestinationPair: sourceToDestinationPair,
            sourceToFiatPair: sourceToFiatPair
        )
    }

    func quoteRequest(_ app: AppProtocol) -> BrokerageQuote.Request? {
        var sourceCurrency: CurrencyType? = source?.currencyType
        if source is PaymentMethodAccount {
            sourceCurrency = try? app.state.get(blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self).currencyType
        }
        guard let sourceCurrency else { return nil }
        guard let destinationCurrency = destination?.currencyType else { return nil }
        guard let profile else { return nil }
        let (base, quote) = (sourceCurrency, destinationCurrency)
        return BrokerageQuote.Request(
            amount: amount,
            base: base,
            quote: quote,
            paymentMethod: (source as? PaymentMethodAccount)?.quote ?? ((source is NonCustodialAccount) ? .deposit : .funds),
            paymentMethodId: (source as? PaymentMethodAccount)?.paymentMethodType.methodId,
            profile: profile
        )
        .transform(
            input: amount,
            sourceToDestinationPair: sourceToDestinationPair,
            sourceToFiatPair: sourceToFiatPair
        )
    }
}

extension BrokerageQuote.Request {

    func transform(input priceInput: MoneyValue? = nil, sourceToDestinationPair: MoneyValuePair?, sourceToFiatPair: MoneyValuePair?) -> BrokerageQuote.Request? {
        guard let input = amount.isPositive ? amount : priceInput else {
            return nil
        }
        var request = self
        if input.currency == request.base {
            request.amount ?= input
        } else if input.currency == request.quote, let sourceToDestinationPair {
            request.amount ?= try? input.convert(using: sourceToDestinationPair.inverseExchangeRate)
        } else if let sourceToFiatPair, input.isFiat {
            request.amount ?= try? input.convert(using: sourceToFiatPair.inverseExchangeRate)
        }
        return request
    }
}

extension PaymentMethodAccount {
    var isYapily: Bool {
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

    var quote: BrokerageQuote.PaymentMethod {
        switch paymentMethodType {
        case .linkedBank:
            return .transfer
        case .applePay, .card:
            return .card
        case .account:
            return .funds
        case .suggested(let suggestion):
            switch suggestion.type {
            case .card, .applePay:
                return .card
            case .funds, .bankAccount, .bankTransfer:
                return .funds
            }
        }
    }
}

extension LinkedBankData {
    var isYapily: Bool {
        partner == .yapily
    }
}

extension LinkedBankAccount {
    fileprivate var isYapily: Bool {
        partner == .yapily
    }
}

extension BlockchainAccount {

    var isYapily: Bool {
        switch self {
        case let linkedBank as LinkedBankAccount where linkedBank.isYapily:
            return true
        case let paymentMethod as PaymentMethodAccount where paymentMethod.isYapily:
            return true
        default:
            return false
        }
    }
}
