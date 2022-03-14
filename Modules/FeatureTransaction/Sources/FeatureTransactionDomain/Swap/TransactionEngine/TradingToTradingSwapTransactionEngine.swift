// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingToTradingSwapTransactionEngine: SwapTransactionEngine {

    let canTransactFiat: Bool = true
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .internal
    let orderQuoteRepository: OrderQuoteRepositoryAPI
    let quotesEngine: QuotesEngine
    let requireSecondPassword: Bool = false
    let transactionLimitsService: TransactionLimitsServiceAPI
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    init(
        quotesEngine: QuotesEngine,
        orderQuoteRepository: OrderQuoteRepositoryAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve()
    ) {
        self.quotesEngine = quotesEngine
        self.orderQuoteRepository = orderQuoteRepository
        self.orderCreationRepository = orderCreationRepository
        self.transactionLimitsService = transactionLimitsService
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
    }

    func assertInputsValid() {
        precondition(target is CryptoTradingAccount)
        precondition(sourceAccount is CryptoTradingAccount)
        precondition((target as! CryptoTradingAccount).asset != sourceAsset)
    }

    lazy var quote: Observable<PricedQuote> = quotesEngine
        .startPollingRate(
            direction: orderDirection,
            pair: .init(
                sourceCurrencyType: sourceAsset,
                destinationCurrencyType: target.currencyType
            )
        )
        .asObservable()

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
        createOrder(pendingTransaction: pendingTransaction)
            .map { _ in
                TransactionResult.unHashed(amount: pendingTransaction.amount)
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
}
