// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class DelegatedSelfCustodyTransactionEngine: TransactionEngine {

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    private var cryptoDelegatedCustodyAccount: CryptoDelegatedCustodyAccount {
        sourceAccount as! CryptoDelegatedCustodyAccount
    }

    private var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        switch transactionTarget {
        case let target as BlockchainAccount:
            return target.receiveAddress
        case let target as ReceiveAddress:
            return .just(target)
        default:
            return .failure(ReceiveAddressError.notSupported)
        }
    }

    private let transactionService: DelegatedCustodyTransactionServiceAPI

    // MARK: - Init

    init(
        currencyConversionService: CurrencyConversionServiceAPI,
        transactionService: DelegatedCustodyTransactionServiceAPI,
        walletCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.currencyConversionService = currencyConversionService
        self.transactionService = transactionService
        self.walletCurrencyService = walletCurrencyService
    }

    func assertInputsValid() {
        precondition(sourceAccount is CryptoDelegatedCustodyAccount)
        precondition(transactionTarget is CryptoReceiveAddress)
        precondition(sourceAsset == targetAsset)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        delegatedCustodyTransactionOutput(pendingTransaction: pendingTransaction)
            .zip(sourceExchangeRatePair)
            .tryMap { [sourceAccount, transactionTarget] output, sourceExchangeRate
                -> (DelegatedCustodyTransactionOutput, [TransactionConfirmation]) in
                let amount = MoneyValue.create(
                    minor: output.amount,
                    currency: sourceAccount!.currencyType
                )!
                let absoluteFeeEstimate = MoneyValue.create(
                    minor: output.absoluteFeeEstimate,
                    currency: sourceAccount!.currencyType
                )!
                let confirmations: [TransactionConfirmation] = [
                    TransactionConfirmations.SendDestinationValue(value: amount),
                    TransactionConfirmations.Source(value: sourceAccount!.label),
                    TransactionConfirmations.Destination(value: transactionTarget!.label),
                    try TransactionConfirmations.FeedTotal(
                        amount: amount,
                        amountInFiat: amount.convert(using: sourceExchangeRate),
                        fee: absoluteFeeEstimate,
                        feeInFiat: absoluteFeeEstimate.convert(using: sourceExchangeRate)
                    )
                ]
                return (output, confirmations)
            }
            .map { output, confirmations in
                var pendingTransaction = pendingTransaction.update(confirmations: confirmations)
                pendingTransaction.setDelegatedCustodyTransactionOutput(output)
                return pendingTransaction
            }
            .asSingle()
    }

    // MARK: - Private Functions

    private func delegatedCustodyTransactionOutput(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<DelegatedCustodyTransactionOutput, Error> {
        receiveAddress
            .map { receiveAddress in
                pendingTransaction.delegatedCustodyTransactionInput(
                    destination: receiveAddress.address,
                    memo: receiveAddress.memo
                )
            }
            .flatMap { [transactionService] input in
                transactionService
                    .buildTransaction(input)
                    .eraseError()
            }
            .eraseToAnyPublisher()
    }

    private var sourceExchangeRatePair: AnyPublisher<MoneyValuePair, Error> {
        walletCurrencyService
            .displayCurrency
            .eraseError()
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
                    .eraseError()
            }
            .eraseToAnyPublisher()
    }

    private var validatedPredefinedAmount: MoneyValue {
        guard let predefinedAmount else {
            return .zero(currency: sourceAsset)
        }
        guard predefinedAmount.currencyType == sourceAsset else {
            return .zero(currency: sourceAsset)
        }
        return predefinedAmount
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        walletCurrencyService.displayCurrency.eraseError()
            .zip(sourceAccountBalance)
            .map { [validatedPredefinedAmount, sourceAsset] displayCurrency, balance -> PendingTransaction in
                PendingTransaction(
                    amount: validatedPredefinedAmount,
                    available: balance.moneyValue,
                    feeAmount: .zero(currency: sourceAsset),
                    feeForFullAvailable: .zero(currency: sourceAsset),
                    feeSelection: .empty(asset: sourceAsset),
                    selectedFiatCurrency: displayCurrency
                )
            }
            .asSingle()
    }

    private var sourceAccountBalance: AnyPublisher<CryptoValue, Error> {
        sourceAccount
            .actionableBalance
            .tryMap { moneyValue -> CryptoValue in
                guard let cryptoValue = moneyValue.cryptoValue else {
                    throw PlatformKitError.illegalStateException(
                        message: "BlockchainAccount.actionableBalance not CryptoValue"
                    )
                }
                return cryptoValue
            }
            .eraseToAnyPublisher()
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        sourceAccountBalance
            .map { balance in
                var pendingTransaction = pendingTransaction.update(amount: amount, available: balance.moneyValue)
                pendingTransaction.setDelegatedeCustodySendMax(balance.moneyValue == amount)
                return pendingTransaction
            }
            .asSingle()
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Deferred { [pendingTransaction] () -> AnyPublisher<PendingTransaction, Error> in
            .just(pendingTransaction)
        }
        .tryMap { [sourceAccount, transactionTarget] pendingTransaction -> PendingTransaction in
            guard pendingTransaction.amount.isPositive else {
                let state: TransactionValidationState = .belowMinimumLimit(pendingTransaction.minSpendable)
                throw TransactionValidationFailure(state: state)
            }
            guard try pendingTransaction.amount <= pendingTransaction.available else {
                let state: TransactionValidationState = .insufficientFunds(
                    pendingTransaction.available,
                    pendingTransaction.amount,
                    sourceAccount!.currencyType,
                    transactionTarget!.currencyType
                )
                throw TransactionValidationFailure(state: state)
            }
            return pendingTransaction
        }
        .asSingle()
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        guard let transactionOutput = pendingTransaction.delegatedCustodyTransactionOutput else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        let currency = sourceCryptoCurrency
        return transactionService.sign(
            transactionOutput,
            privateKey: cryptoDelegatedCustodyAccount.delegatedCustodyAccount.privateKey
        )
        .publisher
        .flatMap { [transactionService] signedOutput in
            transactionService.pushTransaction(signedOutput, currency: currency)
        }
        .map { transactionID in
            let amount = pendingTransaction.amount
            return .hashed(txHash: transactionID, amount: amount.isZero ? nil : amount)
        }
        .asSingle()
    }
}

extension PendingTransaction {

    fileprivate func delegatedCustodyTransactionInput(
        destination: String,
        memo: String?
    ) -> DelegatedCustodyTransactionInput {
        DelegatedCustodyTransactionInput(
            account: 0,
            amount: delegatedeCustodySendMax ? .max : .custom(amount.minorString),
            currency: amount.currency.code,
            destination: destination,
            fee: delegatedeCustodyFee ?? .normal,
            feeCurrency: amount.currency.code,
            maxVerificationVersion: 1,
            memo: memo ?? "",
            type: "PAYMENT"
        )
    }
}

extension PendingTransaction {

    // MARK: Store DelegatedCustodyTransactionOutput

    fileprivate mutating func setDelegatedCustodyTransactionOutput(_ value: DelegatedCustodyTransactionOutput) {
        engineState.mutate { $0[.delegatedeCustodyData] = value }
    }

    fileprivate var delegatedCustodyTransactionOutput: DelegatedCustodyTransactionOutput? {
        engineState.value[.delegatedeCustodyData] as? DelegatedCustodyTransactionOutput
    }

    // MARK: Store DelegatedCustody

    private mutating func setDelegatedeCustodyFee(_ value: DelegatedCustodyFee) {
        engineState.mutate { $0[.delegatedeCustodyFee] = value }
    }

    private var delegatedeCustodyFee: DelegatedCustodyFee? {
        engineState.value[.delegatedeCustodyFee] as? DelegatedCustodyFee
    }

    // MARK: Store Send Max

    fileprivate mutating func setDelegatedeCustodySendMax(_ value: Bool) {
        engineState.mutate { $0[.delegatedeCustodySendMax] = value }
    }

    private var delegatedeCustodySendMax: Bool {
        engineState.value[.delegatedeCustodySendMax] as? Bool ?? false
    }
}
