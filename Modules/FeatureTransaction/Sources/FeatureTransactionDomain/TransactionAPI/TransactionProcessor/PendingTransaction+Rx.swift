// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

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

    private func updateOptionsWithValidityWarning(pendingTransaction: PendingTransaction) -> PendingTransaction {
        switch pendingTransaction.validationState {
        case .canExecute,
             .uninitialized:
            return pendingTransaction.remove(optionType: .errorNotice)
        default:
            let isBelowMinimumState: Bool = if case .belowMinimumLimit = pendingTransaction.validationState {
                true
            } else {
                false
            }
            let error = TransactionConfirmations.ErrorNotice(
                validationState: pendingTransaction.validationState,
                moneyValue: isBelowMinimumState ? pendingTransaction.minLimit : nil
            )
            return pendingTransaction.insert(confirmation: error)
        }
    }
}
