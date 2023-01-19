// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Errors
import Localization
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

protocol SwapTransactionEngine: TransactionEngine {

    var orderDirection: OrderDirection { get }
    var quotesEngine: QuotesEngineAPI { get }
    var orderCreationRepository: OrderCreationRepositoryAPI { get }
    var transactionLimitsService: TransactionLimitsServiceAPI { get }
}

extension PendingTransaction {

    fileprivate var quoteSubscription: Disposable? {
        engineState.value[.quoteSubscription] as? Disposable
    }
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
        quotesEngine.quotePublisher
            .asObservable()
            .map(weak: self) { (self, pricedQuote) -> MoneyValue in
                MoneyValue.create(minor: pricedQuote.price, currency: self.target.currencyType)
            }
            .map(weak: self) { (self, rate) -> MoneyValuePair in
                MoneyValuePair(base: .one(currency: self.sourceAsset), exchangeRate: rate)
            }
    }

    private func disposeQuotesFetching(pendingTransaction: PendingTransaction) {
        pendingTransaction.quoteSubscription?.dispose()
        pendingTransaction.engineState.mutate { $0[.quoteSubscription] = nil }
        quotesEngine.stop()
    }

    func clearConfirmations(pendingTransaction oldValue: PendingTransaction) -> PendingTransaction {
        let pendingTransaction = oldValue
        let quoteSubscription = pendingTransaction.quoteSubscription
        quoteSubscription?.dispose()
        pendingTransaction.engineState.mutate { $0[.quoteSubscription] = nil }
        return pendingTransaction.update(confirmations: [])
    }

    func stop(pendingTransaction: PendingTransaction) {
        disposeQuotesFetching(pendingTransaction: pendingTransaction)
    }

    func updateLimits(
        pendingTransaction: PendingTransaction,
        pricedQuote: PricedQuote
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
                pendingTransaction.limits = try transactionLimits.update(with: pricedQuote)
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
        return quotesEngine.quotePublisher
            .asSingle()
            .map { [sourceAccount, target] pricedQuote -> (PendingTransaction, PricedQuote) in
                let resultValue = MoneyValue.create(minor: pricedQuote.price, currency: targetAsset.currencyType)
                let swapDestinationValue: MoneyValue = pendingTransaction.amount.convert(using: resultValue)
                let sourceTitle = target.accountType == .trading
                ? LocalizationConstants.Transaction.blockchainAccount
                : sourceAccount!.label
                let destinationTitle = target.accountType == .trading
                ? LocalizationConstants.Transaction.blockchainAccount
                : target.label
                let confirmations: [TransactionConfirmation] = [
                    TransactionConfirmations.QuoteExpirationTimer(
                        expirationDate: pricedQuote.expirationDate
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
                        primaryCurrencyFee: pricedQuote.networkFee,
                        feeType: .withdrawalFee
                    ),
                    TransactionConfirmations.NetworkFee(
                        primaryCurrencyFee: pendingTransaction.feeAmount,
                        feeType: .depositFee
                    )
                ]

                let updatedTransaction = pendingTransaction.update(confirmations: confirmations)
                return (updatedTransaction, pricedQuote)
            }
            .flatMap(weak: self) { (self, tuple) in
                let (pendingTransaction, pricedQuote) = tuple
                return self.updateLimits(pendingTransaction: pendingTransaction, pricedQuote: pricedQuote)
            }
    }

    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        startQuotesFetchingIfNotStarted(pendingTransaction: pendingTransaction)
    }

    private func startQuotesFetchingIfNotStarted(
        pendingTransaction oldValue: PendingTransaction
    ) -> Single<PendingTransaction> {
        guard oldValue.quoteSubscription == nil else {
            return .just(oldValue)
        }
        let pendingTransaction = oldValue
        pendingTransaction.engineState.mutate { $0[.quoteSubscription] = startQuotesFetching(pendingTransaction) }
        return .just(pendingTransaction)
    }

    private func startQuotesFetching(_ pendingTransaction: PendingTransaction) -> Disposable {
        quotesEngine
            .quotePublisher
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Void> in
                self?.askForRefreshConfirmation(true) ?? .empty()
            }
            .subscribe()
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        doBuildConfirmations(pendingTransaction: pendingTransaction)
    }

    // MARK: - Exchange Rates

    func sourceToDestinationTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        sourceExchangeRatePair.asPublisher()
            .map(\.quote)
            .mapError { _ in PriceServiceError.missingPrice(pendingTransaction.missingPriceDescription) }
            .eraseToAnyPublisher()
    }

    // MARK: - SwapTransactionEngine

    func createOrder(pendingTransaction: PendingTransaction) -> Single<SwapOrder> {
        Single.zip(
            target.receiveAddress.asSingle(),
            sourceAccount.receiveAddress.asSingle()
        )
        .flatMap { [weak self] destinationAddress, refundAddress -> Single<SwapOrder> in
            guard let self else { return .never() }
            return self.quotesEngine.quotePublisher
                .asSingle()
                .flatMap { [weak self] quote -> Single<SwapOrder> in
                    guard let self else { return .never() }
                    let destination = self.orderDirection.requiresDestinationAddress ? destinationAddress.address : nil
                    let refund = self.orderDirection.requiresRefundAddress ? refundAddress.address : nil
                    return self.orderCreationRepository
                        .createOrder(
                            direction: self.orderDirection,
                            quoteIdentifier: quote.identifier,
                            volume: pendingTransaction.amount,
                            destinationAddress: destination,
                            refundAddress: refund
                        )
                        .asSingle()
                }
        }
        .do(onSuccess: { [weak self] _ in
            self?.disposeQuotesFetching(pendingTransaction: pendingTransaction)
        })
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
