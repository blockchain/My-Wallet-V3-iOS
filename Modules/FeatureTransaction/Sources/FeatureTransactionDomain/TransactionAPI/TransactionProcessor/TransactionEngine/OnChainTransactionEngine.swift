// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxSwift

public protocol OnChainTransactionEngine: TransactionEngine {
    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> { get }
}

extension OnChainTransactionEngine {

    public var sourceCryptoAccount: CryptoAccount {
        sourceAccount as! CryptoAccount
    }

    /// A default implementation for `assertInputsValid()` that validates that `transactionTarget`
    /// is a `CryptoReceiveAddress` and that its address isn't empty, and that the source account and
    /// target account have the same asset.
    public func defaultAssertInputsValid() {
        switch transactionTarget {
        case let target as CryptoReceiveAddress:
            precondition(
                !target.address.isEmpty,
                "Target address is empty."
            )
            precondition(
                sourceCryptoAccount.asset == target.asset,
                "Source asset '\(sourceCryptoAccount.asset.code)' is not equal to target asset '\(target.asset.code)'."
            )
        case let target as CryptoAccount:
            precondition(
                sourceCryptoAccount.asset == target.asset,
                "Source asset '\(sourceCryptoAccount.asset.code)' is not equal to target asset '\(target.asset.code)'."
            )
        default:
            preconditionFailure(
                "\(String(describing: transactionTarget)) is not CryptoReceiveAddress nor SingleAccount."
            )
        }
    }

    public func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        if pendingTransaction.hasFeeLevelChanged(newLevel: level, newAmount: customFeeAmount) {
            return updateFeeSelection(
                pendingTransaction: pendingTransaction,
                newFeeLevel: level,
                customFeeAmount: customFeeAmount
            )
        } else {
            return .just(pendingTransaction)
        }
    }

    public func updateFeeSelection(
        pendingTransaction: PendingTransaction,
        newFeeLevel: FeeLevel,
        customFeeAmount: MoneyValue?
    ) -> Single<PendingTransaction> {
        let pendingTransaction = pendingTransaction
            .update(selectedFeeLevel: newFeeLevel, customFeeAmount: customFeeAmount)

        return update(amount: pendingTransaction.amount, pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, updatedTransaction) -> Single<PendingTransaction> in
                self.validateAmount(pendingTransaction: updatedTransaction)
            }
            .flatMap(weak: self) { (self, validatedTransaction) -> Single<PendingTransaction> in
                self.doBuildConfirmations(pendingTransaction: validatedTransaction)
            }
    }

    public func getFeeState(
        pendingTransaction: PendingTransaction,
        feeOptions: FeeOptions? = nil
    ) -> AnyPublisher<FeeState, Error> {
        do {
            return try .just(
                getFeeState(
                    pendingTransaction: pendingTransaction,
                    feeOptions: feeOptions
                )
            )
        } catch {
            return .failure(error)
        }
    }

    public func getFeeState(
        pendingTransaction: PendingTransaction,
        feeOptions: FeeOptions? = nil
    ) throws -> FeeState {
        switch (pendingTransaction.feeLevel, pendingTransaction.customFeeAmount) {
        case (.custom, nil):
            return .validCustomFee
        case (.custom, .some(let amount)):
            let currency = pendingTransaction.amount.currency
            let zero: MoneyValue = .zero(currency: currency)
            let minimum = MoneyValue.create(minor: 1, currency: pendingTransaction.amount.currency)

            switch amount {
            case _ where try amount < minimum:
                return FeeState.feeUnderMinLimit
            case _ where try amount >= minimum && amount <= (feeOptions?.minLimit ?? zero):
                return .feeUnderRecommended
            case _ where try amount >= (feeOptions?.maxLimit ?? zero):
                return .feeOverRecommended
            default:
                return .validCustomFee
            }
        default:
            if try pendingTransaction.available < pendingTransaction.amount {
                return .feeTooHigh
            }
            return .valid(absoluteFee: pendingTransaction.feeAmount)
        }
    }
}

// TODO: Revisit
public struct FeeOptions {
    var minLimit: MoneyValue
    var maxLimit: MoneyValue
}
