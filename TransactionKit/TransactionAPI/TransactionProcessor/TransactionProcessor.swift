//
//  TransactionProcessor.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class TransactionProcessor {
    
    // MARK: - Public properties
    
    public var canTransactFiat: Bool {
        engine.canTransactFiat
    }

    public var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        engine.fiatExchangeRatePairs
    }

    // If the source and target assets are not the same this MAY return a stream of the exchange rates
    // between them. Or it may simply complete.
    public var transactionExchangeRatePair: Observable<MoneyValuePair> {
        engine.transactionExchangeRatePair
    }

    // Initialise the transaction as required.
    // This will start propagating the pendingTx to the client code.
    public var initializeTransaction: Observable<PendingTransaction> {
        engine
            .initializeTransaction()
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .asObservable()
            .flatMap(weak: self) { (self, _) -> Observable<PendingTransaction> in
                self.pendingTxSubject
            }
    }
    
    // MARK: - Private properties

    private let engine: TransactionEngine
    private let pendingTxSubject: BehaviorSubject<PendingTransaction>
    private let disposeBag = DisposeBag()
    
    // MARK: - Init

    init(sourceAccount: CryptoAccount,
         transactionTarget: TransactionTarget,
         engine: TransactionEngine) {
        self.engine = engine
        pendingTxSubject = BehaviorSubject(value: .zero(currencyType: sourceAccount.currencyType))
        self.engine.start(
            sourceAccount: sourceAccount,
            transactionTarget: transactionTarget,
            askForRefreshConfirmation: { [weak self] revalidate in
                guard let self = self else {
                    return .empty()
                }
                return self.refreshConfirmations(revalidate: revalidate)
            }
        )
        self.engine.assertInputsValid()
    }
    
    // MARK: - Public methods

    public func reset() {
        do {
            engine.stop(pendingTransaction: try pendingTxSubject.value())
        } catch { }
    }
    
    // Set the option to the passed option value. If the option is not supported, it will not be
    // in the original list when the pendingTx is created. And if it is not supported, then trying to
    // update it will cause an error.
    public func set(transactionOptionValue: TransactionConfirmation) -> Completable {
        do {
            let pendingTx = try pendingTxSubject.value()
            if !pendingTx.confirmations.contains(transactionOptionValue) {
                return .just(event: .error(PlatformKitError.illegalArgument))
            }
            return engine
                .doOptionUpdateRequest(
                    pendingTransaction: pendingTx,
                    newConfirmation: transactionOptionValue
                )
                .flatMap(weak: self) { (self, transaction) -> Single<PendingTransaction> in
                    self.engine.doValidateAll(pendingTransaction: transaction)
                }
                .do(onSuccess: { [weak self] transaction in
                    guard let self = self else { return }
                    self.updatePendingTx(transaction)
                })
                .asObservable()
                .ignoreElements()
        } catch let error {
            return .just(event: .error(error))
        }
    }
    
    public func updateAmount(amount: MoneyValue) -> Completable {
        do {
            if !canTransactFiat, amount.isFiat {
                throw PlatformKitError.illegalStateException(
                    message: "Engine.canTransactFiat \(canTransactFiat) but amount.isFiat: \(amount.isFiat)"
                )
            }
            return engine
                .update(amount: amount, pendingTransaction: try pendingTxSubject.value())
                .flatMap(weak: self) { (self, transaction) -> Single<PendingTransaction> in
                    let isFreshTx = transaction.validationState == .uninitialized
                    return self.engine
                        .validateAmount(pendingTransaction: transaction)
                        .map { transaction -> PendingTransaction in
                            // Remove initial "insufficient funds' warning
                            if transaction.amount.isZero && isFreshTx {
                                var newTx = transaction
                                newTx.validationState = .uninitialized
                                return newTx
                            } else {
                                return transaction
                            }
                        }
                }
                .do(onSuccess: { [weak self] pendingTransaction in
                    self?.updatePendingTx(pendingTransaction)
                })
                .asCompletable()

        } catch let error {
            return .just(event: .error(error))
        }
    }

    public func execute(secondPassword: String) -> Single<TransactionResult> {
        do {
            if engine.requireSecondPassword, secondPassword.isEmpty {
                throw PlatformKitError.illegalStateException(message: "Second password not supplied")
            }
            let pendingTransaction = try pendingTxSubject.value()
            return engine
                .doValidateAll(pendingTransaction: pendingTransaction)
                .do(onSuccess: { transaction in
                    guard transaction.validationState == .canExecute else {
                        throw PlatformKitError.illegalStateException(message: "PendingTx is not executable")
                    }
                })
                .flatMap(weak: self) { (self, transaction) -> Single<TransactionResult> in
                    self.engine.execute(pendingTransaction: transaction, secondPassword: secondPassword)
                }
        } catch let error {
            return .error(error)
        }
    }

    public func validateAll() -> Completable {
        guard let pendingTransaction = try? self.pendingTransaction() else {
            preconditionFailure("We should always have a pending transaction when validating")
        }
        return engine.doBuildConfirmations(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                self.engine.doValidateAll(pendingTransaction: pendingTransaction)
            }
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                self.engine.startConfirmationsUpdate(pendingTransaction: pendingTransaction)
            }
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .asCompletable()
    }
    
    // MARK: - Private methods

    // Called back by the engine if it has received an external signal and the existing confirmation set
    // requires a refresh
    private func refreshConfirmations(revalidate: Bool) -> Completable {
        guard let pendingTransaction = try? self.pendingTransaction() else {
            return .empty() // TODO: or error?
        }
        guard !pendingTransaction.confirmations.isEmpty else {
            return .empty()
        }
        return engine.doRefreshConfirmations(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                if revalidate {
                    return self.engine.doValidateAll(pendingTransaction: pendingTransaction)
                }
                return .just(pendingTransaction)
            }
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .asCompletable()
    }

    private func pendingTransaction() throws -> PendingTransaction {
        try pendingTxSubject.value()
    }

    private func updatePendingTx(_ transaction: PendingTransaction) {
        pendingTxSubject.on(.next(transaction))
    }
}
