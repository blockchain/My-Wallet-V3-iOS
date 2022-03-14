// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import MoneyKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingSellTransactionEngine: SellTransactionEngine {

    let canTransactFiat: Bool = true
    var requireSecondPassword: Bool = false
    let quotesEngine: QuotesEngine
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let transactionLimitsService: TransactionLimitsServiceAPI
    let orderQuoteRepository: OrderQuoteRepositoryAPI
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .internal

    lazy var quote: Observable<PricedQuote> = quotesEngine
        .startPollingRate(
            direction: orderDirection,
            pair: .init(
                sourceCurrencyType: sourceAsset,
                destinationCurrencyType: target.currencyType
            )
        )
        .asObservable()

    init(
        quotesEngine: QuotesEngine,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        orderQuoteRepository: OrderQuoteRepositoryAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve()
    ) {
        self.quotesEngine = quotesEngine
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.transactionLimitsService = transactionLimitsService
        self.orderQuoteRepository = orderQuoteRepository
        self.orderCreationRepository = orderCreationRepository
    }

    // MARK: - Transaction Engine

    var askForRefreshConfirmation: AskForRefreshConfirmation!

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    func assertInputsValid() {
        precondition(sourceAccount is TradingAccount)
        precondition(transactionTarget is FiatAccount)
    }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currencyType,
            destinationCurrencyType: target.currencyType
        )
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single
            .zip(
                quote.take(1).asSingle(),
                walletCurrencyService.displayCurrency.asSingle(),
                sourceAccount.actionableBalance
            )
            .flatMap(weak: self) { (self, payload) -> Single<PendingTransaction> in
                let (pricedQuote, fiatCurrency, actionableBalance) = payload
                let pendingTransaction = PendingTransaction(
                    amount: .zero(currency: self.sourceAsset),
                    available: actionableBalance,
                    feeAmount: .zero(currency: self.sourceAsset),
                    feeForFullAvailable: .zero(currency: self.sourceAsset),
                    feeSelection: .empty(asset: self.sourceAsset),
                    selectedFiatCurrency: fiatCurrency
                )
                return self.updateLimits(
                    pendingTransaction: pendingTransaction,
                    pricedQuote: pricedQuote
                )
                .handlePendingOrdersError(initialValue: pendingTransaction)
            }
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        let order = createOrder(pendingTransaction: pendingTransaction)
        return Single
            .zip(order, amountInSourceCurrency(for: pendingTransaction))
            .map { _, amount in
                TransactionResult.unHashed(amount: amount)
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.availableFeeLevels.contains(level))
        return Single.just(pendingTransaction)
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(
            validateUpdateAmount(amount),
            sourceAccount.actionableBalance
        )
        .map { (normalized: MoneyValue, balance: MoneyValue) -> PendingTransaction in
            pendingTransaction.update(amount: normalized, available: balance)
        }
        .do(onSuccess: { [weak self] transaction in
            self?.quotesEngine.update(amount: transaction.amount.amount)
        })
        .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
            self.clearConfirmations(pendingTransaction: pendingTransaction)
        }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        let quote = quote.take(1).asSingle()
        return Single
            .zip(quote, amountInSourceCurrency(for: pendingTransaction))
            .map { [targetAsset] pricedQuote, sellSourceValue -> (PendingTransaction, PricedQuote) in
                let resultValue = FiatValue(amount: pricedQuote.price, currency: targetAsset).moneyValue
                let baseValue = MoneyValue.one(currency: sellSourceValue.currency)
                let sellDestinationValue: MoneyValue = sellSourceValue.convert(using: resultValue)

                var confirmations = [TransactionConfirmation]()
                if let sellSourceCryptoValue = sellSourceValue.cryptoValue {
                    confirmations.append(.sellSourceValue(.init(cryptoValue: sellSourceCryptoValue)))
                }
                if let sellDestinationFiatValue = sellDestinationValue.fiatValue {
                    confirmations.append(.sellDestinationValue(.init(fiatValue: sellDestinationFiatValue)))
                }
                if !pricedQuote.staticFee.isZero {
                    confirmations.append(.transactionFee(.init(fee: pricedQuote.staticFee)))
                }
                confirmations += [
                    .sellExchangeRateValue(.init(baseValue: baseValue, resultValue: resultValue)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label))
                ]
                let updatedTransaction = pendingTransaction.update(confirmations: confirmations)
                return (updatedTransaction, pricedQuote)
            }
            .flatMap(weak: self) { (self, tuple) in
                let (pendingTransaction, pricedQuote) = tuple
                return self.updateLimits(pendingTransaction: pendingTransaction, pricedQuote: pricedQuote)
            }
    }
}
