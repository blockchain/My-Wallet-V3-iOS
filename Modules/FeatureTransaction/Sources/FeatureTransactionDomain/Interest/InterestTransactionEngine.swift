// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import FeatureStakingDomain
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

public protocol InterestTransactionEngine: TransactionEngine {

    // MARK: - Properties

    var minimumDepositLimits: Single<FiatValue> { get }
}

public protocol EarnTransactionEngine: TransactionEngine {
    var earnAccountService: EarnAccountService { get }
}

extension TransactionEngine {

    public func modifyEngineConfirmations(
        _ pendingTransaction: PendingTransaction,
        termsChecked: Bool,
        agreementChecked: Bool
    ) -> PendingTransaction {
        pendingTransaction
            .insert(
                confirmation: TransactionConfirmations.AnyBoolOption<Bool>(
                    value: termsChecked,
                    type: .agreementInterestTandC
                )
            )
            .insert(
                confirmation: TransactionConfirmations.AnyBoolOption<Bool>(
                    value: agreementChecked,
                    type: .agreementInterestTransfer
                )
            )
    }
}

extension InterestTransactionEngine {

    // MARK: - Public Functions

    public func modifyEngineConfirmations(
        _ pendingTransaction: PendingTransaction,
        termsChecked: Bool,
        agreementChecked: Bool
    ) -> PendingTransaction {
        pendingTransaction
            .insert(
                confirmation: TransactionConfirmations.AnyBoolOption<Bool>(
                    value: termsChecked,
                    type: .agreementInterestTandC
                )
            )
            .insert(
                confirmation: TransactionConfirmations.AnyBoolOption<Bool>(
                    value: agreementChecked,
                    type: .agreementInterestTransfer
                )
            )
    }

    public func checkIfAmountIsBelowMinimumLimit(_ pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable { [transactionTarget, sourceCryptoCurrency] in
            switch transactionTarget?.accountType {
            case .trading:
                let minimum = MoneyValue.zero(currency: sourceCryptoCurrency)
                guard try pendingTransaction.amount > minimum else {
                    throw TransactionValidationFailure(state: .belowMinimumLimit(minimum))
                }
            default:
                let minimum = pendingTransaction.minLimit
                guard try pendingTransaction.amount >= minimum else {
                    throw TransactionValidationFailure(state: .belowMinimumLimit(minimum))
                }
            }
        }
    }

    public func checkIfAvailableBalanceIsSufficient(
        _ pendingTransaction: PendingTransaction,
        balance: MoneyValue
    ) -> Completable {
        Completable.fromCallable { [sourceAccount, transactionTarget] in
            guard try pendingTransaction.amount <= balance else {
                throw TransactionValidationFailure(
                    state: .insufficientFunds(
                        balance,
                        pendingTransaction.amount,
                        sourceAccount!.currencyType,
                        transactionTarget!.currencyType
                    )
                )
            }
        }
    }

    public func getTermsOptionValueFromPendingTransaction(
        _ pendingTransaction: PendingTransaction
    ) -> Bool {
        pendingTransaction
            .termsOptionValue
    }

    public func getTransferAgreementOptionValueFromPendingTransaction(
        _ pendingTransaction: PendingTransaction
    ) -> Bool {
        pendingTransaction
            .agreementOptionValue
    }

    public func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> AnyPublisher<(amount: FiatValue, fees: FiatValue), Error> {
        let amount = pendingTransaction.amount.cryptoValue ?? .zero(currency: sourceCryptoCurrency)
        let fees = pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: sourceCryptoCurrency)
        return sourceExchangeRatePair
            .tryMap { value in
                try value.quote.fiatValue.or(throw: "Expected fiat value.")
            }
            .map { quote -> (FiatValue, FiatValue) in
                let fiatAmount = amount.convert(using: quote)
                let fiatFees = fees.convert(using: quote)
                return (fiatAmount, fiatFees)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Internal

    private var sourceExchangeRatePair: AnyPublisher<MoneyValuePair, Error> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
                    .eraseError()
            }
            .eraseToAnyPublisher()
    }
}
