// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Blockchain
import Combine
import DIKit
import Errors
import Localization
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

protocol SwapTransactionEngine: TransactionEngine {

    var app: AppProtocol { get }
    var orderDirection: OrderDirection { get }
    var orderCreationRepository: OrderCreationRepositoryAPI { get }
    var transactionLimitsService: TransactionLimitsServiceAPI { get }
}

extension SwapTransactionEngine {

    var target: CryptoAccount { transactionTarget as! CryptoAccount }
    var targetAsset: CryptoCurrency { target.asset }
    var sourceAsset: CryptoCurrency { sourceCryptoCurrency }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currencyType,
            destinationCurrencyType: target.asset.currencyType
        )
    }

    // MARK: - TransactionEngine

    func validateUpdateAmount(_ amount: MoneyValue) -> Single<MoneyValue> {
        currencyConversionService
            .convert(amount, to: sourceAsset.currencyType)
            .asSingle()
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        Single.zip(sourceExchangeRatePair, destinationExchangeRatePair)
            .map { tuple -> TransactionMoneyValuePairs in
                let (source, destination) = tuple
                return TransactionMoneyValuePairs(
                    source: source,
                    destination: destination
                )
            }
            .asObservable()
    }

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        app.publisher(for: blockchain.ux.transaction.source.target.quote.price)
            .decode(BrokerageQuote.Price.self)
            .compactMap { [source = sourceAsset, target = targetAsset] quote -> MoneyValuePair? in
                MoneyValue.create(minor: quote.price, currency: target.currencyType)
                    .map { price in
                        MoneyValuePair(base: .one(currency: source), exchangeRate: price)
                    }
            }
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
    }

    func clearConfirmations(pendingTransaction: PendingTransaction) -> PendingTransaction {
        pendingTransaction.update(confirmations: [])
    }

    func update(price: BrokerageQuote.Price, on pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        updateLimits(
            pendingTransaction: pendingTransaction,
            quote: price
        )
        .handlePendingOrdersError(initialValue: pendingTransaction)
    }

    func updateLimits(
        pendingTransaction: PendingTransaction,
        quote: BrokerageQuote
    ) -> Single<PendingTransaction> {
        let limitsPublisher = transactionLimitsService.fetchLimits(
            source: LimitsAccount(
                currency: sourceAsset.currencyType,
                accountType: orderDirection.isFromCustodial ? .custodial : .nonCustodial
            ),
            destination: LimitsAccount(
                currency: targetAsset.currencyType,
                accountType: orderDirection.isToCustodial ? .custodial : .nonCustodial
            ),
            product: .swap(orderDirection)
        )
        return limitsPublisher
            .asSingle()
            .map { transactionLimits -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                pendingTransaction.limits = try transactionLimits.update(with: quote)
                return pendingTransaction
            }
    }

    func updateLimits(
        pendingTransaction: PendingTransaction,
        quote: BrokerageQuote.Price
    ) -> Single<PendingTransaction> {
        let limitsPublisher = transactionLimitsService.fetchLimits(
            source: LimitsAccount(
                currency: sourceAsset.currencyType,
                accountType: orderDirection.isFromCustodial ? .custodial : .nonCustodial
            ),
            destination: LimitsAccount(
                currency: targetAsset.currencyType,
                accountType: orderDirection.isToCustodial ? .custodial : .nonCustodial
            ),
            product: .swap(orderDirection)
        )
        return limitsPublisher
            .asSingle()
            .map { transactionLimits -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                pendingTransaction.limits = try transactionLimits.update(with: quote)
                return pendingTransaction
            }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultDoValidateAll(pendingTransaction: pendingTransaction)
    }

    func defaultDoValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        let sourceAsset = sourceAsset, targetAsset = targetAsset
        do {
            guard let pricedQuote = pendingTransaction.quote else {
                return .just(pendingTransaction.update(confirmations: []))
            }
            let resultValue = try MoneyValue.create(minor: pricedQuote.price, currency: targetAsset.currencyType)
                .or(throw: "No price")
            let swapDestinationValue: MoneyValue = pendingTransaction.amount.convert(using: resultValue)
            let sourceTitle = target.accountType == .trading
                ? LocalizationConstants.Transaction.blockchainAccount
                : sourceAccount!.label
            let destinationTitle = target.accountType == .trading
                ? LocalizationConstants.Transaction.blockchainAccount
                : target.label
            let confirmations: [TransactionConfirmation] = [
                TransactionConfirmations.QuoteExpirationTimer(
                    expirationDate: pricedQuote.date.expiresAt ?? Date()
                ),
                TransactionConfirmations.SwapSourceValue(cryptoValue: pendingTransaction.amount.cryptoValue!),
                TransactionConfirmations.SwapDestinationValue(cryptoValue: swapDestinationValue.cryptoValue!),
                TransactionConfirmations.SwapExchangeRate(
                    baseValue: .one(currency: sourceAsset),
                    resultValue: resultValue
                ),
                TransactionConfirmations.Source(value: sourceTitle),
                TransactionConfirmations.Destination(value: destinationTitle),
                TransactionConfirmations.NetworkFee(
                    primaryCurrencyFee: pricedQuote.fee.network,
                    feeType: .withdrawalFee
                ),
                TransactionConfirmations.NetworkFee(
                    primaryCurrencyFee: pendingTransaction.feeAmount,
                    feeType: .depositFee
                )
            ]

            let updatedTransaction = pendingTransaction.update(confirmations: confirmations)
            return updateLimits(pendingTransaction: updatedTransaction, quote: pricedQuote)
        } catch {
            return .error(error)
        }
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        doBuildConfirmations(pendingTransaction: pendingTransaction)
    }

    // MARK: - SwapTransactionEngine

    func createOrder(pendingTransaction: PendingTransaction) -> Single<SwapOrder> {
        Single.zip(
            target.receiveAddress.asSingle(),
            sourceAccount.receiveAddress.asSingle()
        )
        .flatMap { [weak self] destinationAddress, refundAddress throws -> Single<SwapOrder> in
            guard let self else { return .never() }
            let destination = self.orderDirection.requiresDestinationAddress ? destinationAddress.address : nil
            let refund = self.orderDirection.requiresRefundAddress ? refundAddress.address : nil
            return try self.orderCreationRepository
                .createOrder(
                    direction: self.orderDirection,
                    quoteIdentifier: pendingTransaction.quote.or(throw: "No quote").id,
                    volume: pendingTransaction.amount,
                    destinationAddress: destination,
                    refundAddress: refund
                )
                .asSingle()
        }
    }

    // MARK: - Private Functions

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        transactionExchangeRatePair
            .take(1)
            .asSingle()
    }

    private var destinationExchangeRatePair: Single<MoneyValuePair> {
        transactionExchangeRatePair
            .take(1)
            .asSingle()
            .map(\.inverseExchangeRate)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == PendingTransaction {

    /// Checks if `pendingOrdersLimitReached` error occured and passes that down the stream, otherwise
    ///  - in case the error is not a `NabuNetworkError` it throws the erro
    ///  - if the error is a `NabuNetworkError` and it is not a `pendingOrdersLimitReached`,
    ///    it passes a `nabuError` which contains the raw nabu error
    /// - Parameter initialValue: The current `PendingTransaction` to be updated
    /// - Returns: An `Single<PendingTransaction>` with updated `validationState`
    func handlePendingOrdersError(initialValue: PendingTransaction) -> Single<PendingTransaction> {
        `catch` { error -> Single<PendingTransaction> in
            guard let nabuError = error as? NabuNetworkError else {
                throw error
            }
            guard nabuError.code == .pendingOrdersLimitReached else {
                var initialValue = initialValue
                initialValue.validationState = .nabuError(nabuError)
                return .just(initialValue)
            }
            var initialValue = initialValue
            initialValue.validationState = .pendingOrdersLimitReached
            return .just(initialValue)
        }
    }
}
