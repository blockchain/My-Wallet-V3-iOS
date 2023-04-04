// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import Foundation
import MoneyKit
import PlatformKit
import RxSwift

protocol SellTransactionEngine: TransactionEngine {

    var app: AppProtocol { get }
    var orderDirection: OrderDirection { get }
    var transactionLimitsService: TransactionLimitsServiceAPI { get }
    var orderCreationRepository: OrderCreationRepositoryAPI { get }
}

extension SellTransactionEngine {

    var target: FiatAccount {
        transactionTarget as! FiatAccount
    }

    var sourceAsset: CryptoCurrency { sourceCryptoCurrency }
    var targetAsset: FiatCurrency { target.fiatCurrency }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currencyType,
            destinationCurrencyType: target.fiatCurrency.currencyType
        )
    }

    // MARK: - TransactionEngine

    func validateUpdateAmount(_ amount: MoneyValue) -> Single<MoneyValue> {
        sourceExchangeRatePair.map { exchangeRate -> MoneyValue in
            if amount.isFiat {
                return amount.convert(using: exchangeRate.inverseQuote.quote)
            } else {
                return amount
            }
        }
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { source -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: source,
                    destination: source.inverseExchangeRate
                )
            }
            .asObservable()
    }

    var sourceExchangeRatePair: Single<MoneyValuePair> {
        transactionExchangeRatePair
            .take(1)
            .asSingle()
    }

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        app.publisher(for: blockchain.ux.transaction.source.target.quote.price)
            .decode(BrokerageQuote.Price.self)
            .compactMap { [target] quote -> MoneyValue? in
                .create(minor: quote.price, currency: target.currencyType)
            }
            .map { [sourceAsset] rate -> MoneyValuePair in
                MoneyValuePair(base: .one(currency: sourceAsset), exchangeRate: rate)
            }
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
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
            product: .sell(orderDirection)
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
            product: .sell(orderDirection)
        )
        return limitsPublisher
            .asSingle()
            .map { transactionLimits -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                pendingTransaction.limits = try transactionLimits.update(with: quote)
                return pendingTransaction
            }
    }

    func clearConfirmations(pendingTransaction: PendingTransaction) -> PendingTransaction {
        pendingTransaction.update(confirmations: [])
    }

    func createOrder(pendingTransaction: PendingTransaction) -> Single<SellOrder> {
        guard let quote = pendingTransaction.quote else {
            return .error("Cannot create an order with no quote")
        }
        return orderCreationRepository.createOrder(
            direction: orderDirection,
            quoteIdentifier: quote.id,
            volume: pendingTransaction.amount,
            ccy: target.currencyType.code,
            refundAddress: nil
        )
        .asSingle()
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultDoValidateAll(pendingTransaction: pendingTransaction)
    }

    func defaultDoValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        doBuildConfirmations(pendingTransaction: pendingTransaction)
    }

    // MARK: - Exchange Rates

    public func onChainFeeToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        // The price endpoint doesn't support crypto -> crypto rates, so we need to be careful here.
        currencyConversionService.conversionRate(
            from: pendingTransaction.feeAmount.currency,
            to: target.currencyType
        )
        .zip(
            sourceToFiatTradingCurrencyRate(
                pendingTransaction: pendingTransaction,
                tradingCurrency: target.fiatCurrency
            )
        )
        .map { [sourceAsset] feeToFiatRate, sourceToFiatRate in
            feeToFiatRate.convert(usingInverse: sourceToFiatRate, currency: sourceAsset.currencyType)
        }
        .eraseToAnyPublisher()
    }
}

extension TransactionLimits {

    func update(with quote: BrokerageQuote) throws -> TransactionLimits {
        let minimum = try calculateMinimumLimit(for: quote)
        return TransactionLimits(
            currencyType: minimum.currencyType,
            minimum: minimum,
            maximum: maximum,
            maximumDaily: maximumDaily,
            maximumAnnual: maximumAnnual,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: suggestedUpgrade,
            earn: nil
        )
    }

    private func calculateMinimumLimit(for quote: BrokerageQuote) throws -> MoneyValue {
        let destination = quote.request.quote
        let price = try MoneyValue.create(minor: quote.price, currency: destination).or(throw: "No price")
        let totalFees = (try? quote.fee.network + quote.fee.static) ?? MoneyValue.zero(currency: destination)
        let convertedFees: MoneyValue = totalFees.convert(usingInverse: price, currency: currencyType)
        let minimum = minimum ?? .zero(currency: destination)
        return (try? minimum + convertedFees) ?? MoneyValue.zero(currency: destination)
    }

    func update(with quote: BrokerageQuote.Price) throws -> TransactionLimits {
        let minimum = try calculateMinimumLimit(for: quote)
        return TransactionLimits(
            currencyType: minimum.currencyType,
            minimum: minimum,
            maximum: maximum,
            maximumDaily: maximumDaily,
            maximumAnnual: maximumAnnual,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: suggestedUpgrade,
            earn: nil
        )
    }

    private func calculateMinimumLimit(for quote: BrokerageQuote.Price) throws -> MoneyValue {
        let destination = quote.target
        let price = try MoneyValue.create(minor: quote.price, currency: destination).or(throw: "No price")
        let totalFees = (try? quote.fee.dynamic + quote.fee.network) ?? MoneyValue.zero(currency: destination)
        let convertedFees: MoneyValue = totalFees.convert(usingInverse: price, currency: currencyType)
        let minimum = minimum ?? .zero(currency: destination)
        return (try? minimum + convertedFees) ?? MoneyValue.zero(currency: destination)
    }
}
