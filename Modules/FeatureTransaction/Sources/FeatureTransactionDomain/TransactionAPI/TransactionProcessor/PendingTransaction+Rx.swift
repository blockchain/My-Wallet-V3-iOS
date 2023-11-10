// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

extension Publisher where Output == Void, Failure: Error {

    public func updateTxValidity(pendingTransaction: PendingTransaction) -> AnyPublisher<PendingTransaction, Error> {
        flatMap { _ -> AnyPublisher<PendingTransaction, Failure> in
            .just(pendingTransaction.update(validationState: .canExecute))
        }
        .updateTxValidity(pendingTransaction: pendingTransaction)
    }
}

extension Publisher where Output == PendingTransaction, Failure: Error {

    public func updateTxValidity(pendingTransaction: PendingTransaction) -> AnyPublisher<PendingTransaction, Error> {
        `catch` { error -> AnyPublisher<PendingTransaction, Error> in
            switch error {
            case let error as TransactionValidationFailure:
                return .just(pendingTransaction.update(validationState: error.state))
            default:
                return .failure(error)
            }
        }
        .map { pendingTransaction -> PendingTransaction in
            if pendingTransaction.confirmations.isEmpty {
                pendingTransaction
            } else {
                updateOptionsWithValidityWarning(pendingTransaction: pendingTransaction)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Completable {

    public func updateTxValidityCompletable(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        flatMapSingle { () -> Single<PendingTransaction> in
            .just(pendingTransaction.update(validationState: .canExecute))
        }
        .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == PendingTransaction {

    public func updateTxValiditySingle(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        `catch` { error -> Single<PendingTransaction> in
            guard let validationError = error as? TransactionValidationFailure else {
                throw error
            }
            return .just(pendingTransaction.update(validationState: validationError.state))
        }
        .map { pendingTransaction -> PendingTransaction in
            if pendingTransaction.confirmations.isEmpty {
                pendingTransaction
            } else {
                updateOptionsWithValidityWarning(pendingTransaction: pendingTransaction)
            }
        }
    }
}

fileprivate func updateOptionsWithValidityWarning(pendingTransaction: PendingTransaction) -> PendingTransaction {
    switch pendingTransaction.validationState {
    case .canExecute,
         .uninitialized:
        return pendingTransaction.remove(optionType: .errorNotice)
    default:
        let isBelowMinimumState = pendingTransaction.validationState.isBelowMinimumLimit
        let error = TransactionConfirmations.ErrorNotice(
            validationState: pendingTransaction.validationState,
            moneyValue: isBelowMinimumState ? pendingTransaction.minLimit : nil
        )
        return pendingTransaction.insert(confirmation: error)
    }
}

extension TransactionValidationState {
    fileprivate var isBelowMinimumLimit: Bool {
        switch self {
        case .belowMinimumLimit:
            return true
        default:
            return false
        }
    }
}
