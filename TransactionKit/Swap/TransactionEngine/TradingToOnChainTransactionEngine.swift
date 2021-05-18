//
//  TradingToOnChainTransactionEngine.swift
//  TransactionKit
//
//  Created by Alex McGregor on 2/2/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingToOnChainTransactionEngine: TransactionEngine {
    
    /// This might need to be `1:1` as there isn't a transaction pair.
    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        .empty()
    }
    
    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }
    
    let fiatCurrencyService: FiatCurrencyServiceAPI
    let priceService: PriceServiceAPI
    let requireSecondPassword: Bool = false
    let isNoteSupported: Bool
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: CryptoAccount!
    var transactionTarget: TransactionTarget!

    var sourceTradingAccount: CryptoTradingAccount! {
        sourceAccount as? CryptoTradingAccount
    }
    
    var target: CryptoAccount { transactionTarget as! CryptoAccount }
    var targetAsset: CryptoCurrency { target.asset }
    var sourceAsset: CryptoCurrency { sourceAccount.asset }
    
    // MARK: - Private Properties
    
    private let transferService: InternalTransferServiceAPI
    
    // MARK: - Init

    init(isNoteSupported: Bool = false,
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         priceService: PriceServiceAPI = resolve(),
         transferService: InternalTransferServiceAPI = resolve()) {
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.isNoteSupported = isNoteSupported
        self.transferService = transferService
    }
    
    func assertInputsValid() {
        precondition(target is CryptoNonCustodialAccount)
        precondition(sourceAccount is CryptoTradingAccount)
        precondition((target as! CryptoNonCustodialAccount).asset == sourceAccount.asset)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<PendingTransaction> in
                .just(
                    .init(
                        amount: .zero(currency: self.sourceAsset),
                        available: .zero(currency: self.sourceAsset),
                        fees: .zero(currency: self.sourceAsset),
                        feeLevel: .none,
                        selectedFiatCurrency: fiatCurrency
                    )
                )
            }
    }
    
    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceTradingAccount != nil else {
            return .just(pendingTransaction)
        }
        return sourceTradingAccount
            .withdrawableBalance
            .map { actionableBalance -> PendingTransaction in
                pendingTransaction.update(amount: amount, available: actionableBalance)
            }
    }
    
    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        fiatAmountAndFees(from: pendingTransaction)
            .map(\.amount)
            .map(weak: self) { (self, amount) -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                var values: [TransactionConfirmation] = [
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .total(.init(total: amount.moneyValue))
                ]
                if self.isNoteSupported {
                    values.append(.destination(.init(value: "")))
                }
                pendingTransaction.confirmations = values
                return pendingTransaction
            }
    }
    
    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }
    
    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        target
            .receiveAddress
            .map(\.address)
            .flatMap(weak: self) { (self, destination) -> Single<TransactionResult> in
                self.transferService
                    .transfer(
                        moneyValue: pendingTransaction.amount,
                        destination: destination
                    )
                    .map(\.identifier)
                    .map { (identifier) -> TransactionResult in
                        TransactionResult.hashed(txHash: identifier, amount: pendingTransaction.amount)
                    }
            }
    }
    
    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        target.onTxCompleted(transactionResult)
    }
    
    // MARK: - Private Functions
    
    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        sourceTradingAccount
            .withdrawableBalance
            .flatMapCompletable(weak: self) { (self, balance) -> Completable in
                guard try pendingTransaction.amount > .zero(currency: self.sourceAsset) else {
                    throw TransactionValidationFailure(state: .invalidAmount)
                }
                guard try balance >= pendingTransaction.amount else {
                    throw TransactionValidationFailure(state: .insufficientFunds)
                }
                return .just(event: .completed)
            }
    }
    
    private func makeFeeSelectionOption(pendingTransaction: PendingTransaction) -> Single<TransactionConfirmation.Model.FeeSelection> {
        fiatAmountAndFees(from: pendingTransaction)
            .map { ($0.fees) }
            .map(weak: self) { (self, fees) -> TransactionConfirmation.Model.FeeSelection in
                /// Fees are zero in this case
                .init(feeState: .valid(absoluteFee: pendingTransaction.fees),
                      exchange: fees.moneyValue,
                      selectedFeeLevel: pendingTransaction.feeLevel,
                      customFeeAmount: .zero(currency: fees.currency),
                      availableLevels: [.none],
                      asset: self.sourceAccount.asset)
            }
    }
    
    private func fiatAmountAndFees(from pendingTransaction: PendingTransaction) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            Single.just(pendingTransaction.amount.cryptoValue ?? .zero(currency: sourceAsset)),
            Single.just(pendingTransaction.fees.cryptoValue ?? .zero(currency: sourceAsset))
        )
        .map({ (quote: ($0.0.quote.fiatValue ?? .zero(currency: .USD)), amount: $0.1, fees: $0.2) })
        .map { (quote: (FiatValue), amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convertToFiatValue(exchangeRate: quote)
            let fiatFees = fees.convertToFiatValue(exchangeRate: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }
    
    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(for: self.sourceAccount.currencyType, in: fiatCurrency)
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceAccount.currencyType), quote: $0) }
            }
    }
}
