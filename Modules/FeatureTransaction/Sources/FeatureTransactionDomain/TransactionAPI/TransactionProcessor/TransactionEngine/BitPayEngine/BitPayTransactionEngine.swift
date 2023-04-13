// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class BitPayTransactionEngine: TransactionEngine {

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    var askForRefreshConfirmation: AskForRefreshConfirmation!

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        onChainEngine
            .fiatExchangeRatePairs
    }

    // MARK: - Private Properties

    /// This is due to the fact that the validation of the timeout occurs on completion of
    /// the `Observable<Int>.interval` method from Rx, we kill the interval a second earlier so that we
    /// validate the transaction/invoice on the correct beat.
    private static let timeoutStop: TimeInterval = 1

    private let onChainEngine: OnChainTransactionEngine
    private let bitpayRepository: BitPayRepositoryAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private var bitpayInvoice: BitPayInvoiceTarget {
        transactionTarget as! BitPayInvoiceTarget
    }

    private var bitpayClientEngine: BitPayClientEngine {
        onChainEngine as! BitPayClientEngine
    }

    private var timeRemainingSeconds: TimeInterval {
        bitpayInvoice
            .expirationTimeInSeconds
    }

    private let stopCountdown = PublishSubject<Void>()

    init(
        onChainEngine: OnChainTransactionEngine,
        bitpayRepository: BitPayRepositoryAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.onChainEngine = onChainEngine
        self.bitpayRepository = bitpayRepository
        self.analyticsRecorder = analyticsRecorder
        self.currencyConversionService = currencyConversionService
        self.walletCurrencyService = walletCurrencyService
    }

    func start(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmation
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
        onChainEngine.start(
            sourceAccount: sourceAccount,
            transactionTarget: transactionTarget,
            askForRefreshConfirmation: askForRefreshConfirmation
        )
    }

    func assertInputsValid() {
        precondition(sourceAccount is CryptoNonCustodialAccount)
        precondition(sourceCryptoCurrency == .bitcoin)
        precondition(transactionTarget is BitPayInvoiceTarget)
        precondition(onChainEngine is BitPayClientEngine)
        onChainEngine.assertInputsValid()
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        onChainEngine
            .initializeTransaction()
            .map(weak: self) { (self, pendingTransaction) in
                pendingTransaction
                    .update(availableFeeLevels: [.priority])
                    .update(selectedFeeLevel: .priority)
                    .update(amount: self.bitpayInvoice.amount.moneyValue)
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine
            .update(
                amount: bitpayInvoice.amount.moneyValue,
                pendingTransaction: pendingTransaction
            )
            .flatMap(weak: self) { (self, pendingTransaction) in
                self.onChainEngine
                    .doBuildConfirmations(pendingTransaction: pendingTransaction)
            }
            .map(weak: self) { (self, pendingTransaction) in
                self.startTimeIfNotStarted(pendingTransaction)
            }
            .map(weak: self) { (self, pendingTransaction) in
                pendingTransaction
                    .insert(
                        confirmation: TransactionConfirmations.BitPayCountdown(
                            secondsRemaining: self.timeRemainingSeconds
                        ),
                        prepend: true
                    )
            }
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(
            pendingTransaction
                .insert(
                    confirmation: TransactionConfirmations.BitPayCountdown(secondsRemaining: timeRemainingSeconds),
                    prepend: true
                )
        )
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        /// Don't set the amount here.
        /// It is fixed so we can do it in the confirmation building step
        .just(pendingTransaction)
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine
            .validateAmount(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        doValidateTimeout(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTx) -> Single<PendingTransaction> in
                self.onChainEngine.doValidateAll(pendingTransaction: pendingTx)
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        bitpayClientEngine
            .doPrepareBitPayTransaction(pendingTransaction: pendingTransaction)
            .subscribe(on: MainScheduler.instance)
            .flatMap(weak: self) { (self, transaction) -> Single<String> in
                self.doExecuteTransaction(
                    invoiceId: self.bitpayInvoice.invoiceId,
                    transaction: transaction
                )
            }
            .do(onSuccess: { [weak self] _ in
                guard let self else { return }
                // TICKET: IOS-4492 - Analytics
                bitpayClientEngine.doOnBitPayTransactionSuccess(
                    pendingTransaction: pendingTransaction
                )
            }, onError: { [weak self] error in
                guard let self else { return }
                // TICKET: IOS-4492 - Analytics
                bitpayClientEngine.doOnBitPayTransactionFailed(
                    pendingTransaction: pendingTransaction,
                    error: error
                )
            }, onSubscribe: { [weak self] in
                guard let self else { return }
                stopCountdown.on(.next(()))
            })
            .map { TransactionResult.hashed(txHash: $0, amount: pendingTransaction.amount) }
    }

    func doUpdateFeeLevel(pendingTransaction: PendingTransaction, level: FeeLevel, customFeeAmount: MoneyValue) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func doExecuteTransaction(invoiceId: String, transaction: BitPayClientEngineTransaction) -> Single<String> {
        bitpayRepository
            .verifySignedTransaction(
                invoiceId: invoiceId,
                currency: sourceCryptoCurrency,
                transactionHex: transaction.txHash,
                transactionSize: transaction.msgSize
            )
            .asObservable()
            .ignoreElements()
            .asCompletable()
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .andThen(
                bitpayRepository
                    .submitBitPayPayment(
                        invoiceId: invoiceId,
                        currency: sourceCryptoCurrency,
                        transactionHex: transaction.txHash,
                        transactionSize: transaction.msgSize
                    )
                    .asObservable()
                    .asSingle()
            )
            .map(\.memo)
    }

    private func doValidateTimeout(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.just(pendingTransaction)
            .map(weak: self) { (self, pendingTx) in
                guard self.timeRemainingSeconds > Self.timeoutStop else {
                    throw TransactionValidationFailure(state: .invoiceExpired)
                }
                return pendingTx
            }
    }

    private func startTimeIfNotStarted(_ pendingTransaction: PendingTransaction) -> PendingTransaction {
        guard pendingTransaction.bitpayTimer == nil else { return pendingTransaction }
        var transaction = pendingTransaction
        transaction.setCountdownTimer(timer: startCountdownTimer(timeRemaining: timeRemainingSeconds))
        return transaction
    }

    private func startCountdownTimer(timeRemaining: TimeInterval) -> Disposable {
        guard let remaining = Int(exactly: timeRemaining) else {
            fatalError("Expected an Int value: \(timeRemaining)")
        }
        return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(until: stopCountdown)
            .map { remaining - $0 }
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                _ = askForRefreshConfirmation(false)
                    .subscribe()
            })
            .take(until: { $0 <= Int(Self.timeoutStop) }, behavior: .inclusive)
            .do(onCompleted: { [weak self] in
                guard let self else { return }
                Logger.shared.debug("BitPay Invoice Countdown expired")
                _ = askForRefreshConfirmation(true)
                    .subscribe()
            })
            .subscribe()
    }
}

extension PendingTransaction {
    fileprivate mutating func setCountdownTimer(timer: Disposable) {
        engineState.mutate { $0[.bitpayTimer] = timer }
    }

    var bitpayTimer: Disposable? {
        engineState.value[.bitpayTimer] as? Disposable
    }
}
