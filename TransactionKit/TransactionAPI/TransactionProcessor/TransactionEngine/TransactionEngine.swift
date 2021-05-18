//
//  TransactionEngine.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

public protocol TransactionEngine: AnyObject {
    
    typealias AskForRefreshConfirmation = (_ revalidate: Bool) -> Completable
    
    /// Does this engine accept fiat input amounts
    var canTransactFiat: Bool { get }
    /// askForRefreshConfirmation: Must be set by TransactionProcessor
    var askForRefreshConfirmation: (AskForRefreshConfirmation)! { get set }
    var sourceAccount: CryptoAccount! { get set }
    var transactionTarget: TransactionTarget! { get set }
    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> { get }
    var requireSecondPassword: Bool { get }
    // If the source and target assets are not the same this MAY return a stream of the exchange rates
    // between them. Or it may simply complete.
    var transactionExchangeRatePair: Observable<MoneyValuePair> { get }

    func assertInputsValid()
    func start(sourceAccount: CryptoAccount,
               transactionTarget: TransactionTarget,
               askForRefreshConfirmation: @escaping AskForRefreshConfirmation)
    func stop(pendingTransaction: PendingTransaction)
    func restart(transactionTarget: TransactionTarget, pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Implementation interface:
    /// Call this first to initialise the processor. Construct and initialise a pendingTx object.
    func initializeTransaction() -> Single<PendingTransaction>

    /// Update the transaction with a new amount. This method should check balances, calculate fees and
    /// Return a new PendingTx with the state updated for the UI to update. The pending Tx will
    /// be passed to validate after this call.
    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Process any TxOption updates, if required. The default just replaces the option and returns
    /// the updated pendingTx. Subclasses may want to, eg, update amounts on fee changes etc
    func doOptionUpdateRequest(pendingTransaction: PendingTransaction, newConfirmation: TransactionConfirmation) -> Single<PendingTransaction>

    /// Check the tx is complete, well formed and possible. If it is, set pendingTx to CAN_EXECUTE
    /// Else set it to the appropriate error, and then return the updated PendingTx
    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Check the tx is complete, well formed and possible. If it is, set pendingTx to CAN_EXECUTE
    /// Else set it to the appropriate error, and then return the updated PendingTx
    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Execute the transaction, it will have been validated before this is called, so the expectation
    /// is that it will succeed.
    /// - Parameter secondPassword: The second password or a empty string if not needed.
    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult>

    /// Action to be executed once the transaction has been executed, it will have been validated before this is called, so the expectation
    /// is that it will succeed.
    func doPostExecute(transactionResult: TransactionResult) -> Completable

    /// Action to be executed when confirmations have been built and we want to start checking for updates on them
    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>
}

public extension TransactionEngine {

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        .empty()
    }

    var canTransactFiat: Bool { false }

    func assertInputsValid() { }

    func stop(pendingTransaction: PendingTransaction) { }

    func start(sourceAccount: CryptoAccount,
               transactionTarget: TransactionTarget,
               askForRefreshConfirmation: @escaping (_ revalidate: Bool) -> Completable) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }

    func restart(transactionTarget: TransactionTarget, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultRestart(transactionTarget: transactionTarget, pendingTransaction: pendingTransaction)
    }

    func defaultRestart(transactionTarget: TransactionTarget, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        self.transactionTarget = transactionTarget
        return .just(pendingTransaction)
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    func doOptionUpdateRequest(pendingTransaction: PendingTransaction, newConfirmation: TransactionConfirmation) -> Single<PendingTransaction> {
        defaultDoOptionUpdateRequest(pendingTransaction: pendingTransaction, newConfirmation: newConfirmation)
    }

    func defaultDoOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction.insert(confirmation: newConfirmation))
    }

    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }
}
