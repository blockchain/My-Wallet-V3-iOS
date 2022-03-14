// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class NonCustodialSellTransactionEngine: SellTransactionEngine {

    let canTransactFiat: Bool = false
    let receiveAddressFactory: ExternalAssetAddressServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let onChainEngine: OnChainTransactionEngine
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .fromUserKey
    let orderQuoteRepository: OrderQuoteRepositoryAPI
    let orderUpdateRepository: OrderUpdateRepositoryAPI
    let quotesEngine: QuotesEngine
    let requireSecondPassword: Bool
    let transactionLimitsService: TransactionLimitsServiceAPI

    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

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
        requireSecondPassword: Bool,
        onChainEngine: OnChainTransactionEngine,
        orderQuoteRepository: OrderQuoteRepositoryAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        orderUpdateRepository: OrderUpdateRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        receiveAddressFactory: ExternalAssetAddressServiceAPI = resolve()
    ) {
        self.quotesEngine = quotesEngine
        self.requireSecondPassword = requireSecondPassword
        self.orderQuoteRepository = orderQuoteRepository
        self.orderCreationRepository = orderCreationRepository
        self.orderUpdateRepository = orderUpdateRepository
        self.transactionLimitsService = transactionLimitsService
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.onChainEngine = onChainEngine
        self.receiveAddressFactory = receiveAddressFactory
    }

    func assertInputsValid() {
        precondition(sourceAccount is NonCustodialAccount)
        precondition(transactionTarget is FiatAccount)
    }

    private func startOnChainEngine(pricedQuote: PricedQuote) -> Completable {
        let value = receiveAddressFactory.makeExternalAssetAddress(
            asset: sourceAsset,
            address: pricedQuote.sampleDepositAddress,
            label: pricedQuote.sampleDepositAddress,
            onTxCompleted: { _ in .empty() }
        )
        switch value {
        case .failure(let error):
            return .just(event: .error(error))
        case .success(let receiveAddress):
            onChainEngine.start(
                sourceAccount: sourceAccount,
                transactionTarget: receiveAddress,
                askForRefreshConfirmation: { _ in .empty() }
            )
            return .just(event: .completed)
        }
    }

    private func defaultFeeLevel(pendingTransaction: PendingTransaction) -> FeeLevel {
        if pendingTransaction.feeSelection.availableLevels.contains(.priority) {
            return .priority
        }
        return pendingTransaction.feeSelection.selectedLevel
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        quote
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, pricedQuote) -> Single<PendingTransaction> in
                self.startOnChainEngine(pricedQuote: pricedQuote)
                    .andThen(
                        Single.zip(
                            self.walletCurrencyService.displayCurrency.asSingle(),
                            self.onChainEngine.initializeTransaction()
                        )
                    )
                    .flatMap(weak: self) { (self, payload) -> Single<PendingTransaction> in
                        let (fiatCurrency, pendingTransaction) = payload

                        let fallback = PendingTransaction(
                            amount: CryptoValue.zero(currency: self.sourceAsset).moneyValue,
                            available: FiatValue.zero(currency: self.targetAsset).moneyValue,
                            feeAmount: FiatValue.zero(currency: self.targetAsset).moneyValue,
                            feeForFullAvailable: CryptoValue.zero(currency: self.sourceAsset).moneyValue,
                            feeSelection: .empty(asset: self.sourceAsset),
                            selectedFiatCurrency: fiatCurrency
                        )
                        return self.updateLimits(
                            pendingTransaction: pendingTransaction,
                            pricedQuote: pricedQuote
                        )
                        .map(weak: self) { (self, pendingTx) -> PendingTransaction in
                            pendingTx
                                .update(selectedFeeLevel: self.defaultFeeLevel(pendingTransaction: pendingTx))
                        }
                        .handlePendingOrdersError(initialValue: fallback)
                    }
            }
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, sellOrder) -> Single<TransactionResult> in
                guard let depositAddress = sellOrder.depositAddress else {
                    throw PlatformKitError.illegalStateException(message: "Missing deposit address")
                }
                return self.receiveAddressFactory
                    .makeExternalAssetAddress(
                        asset: self.sourceAsset,
                        address: depositAddress,
                        label: depositAddress,
                        onTxCompleted: { _ in .empty() }
                    )
                    .single
                    .flatMap(weak: self) { (self, transactionTarget) -> Single<PendingTransaction> in
                        self.onChainEngine
                            .restart(transactionTarget: transactionTarget, pendingTransaction: pendingTransaction)
                    }
                    .flatMap(weak: self) { (self, pendingTransaction) -> Single<TransactionResult> in
                        self.onChainEngine
                            .execute(pendingTransaction: pendingTransaction, secondPassword: secondPassword)
                            .catchError(weak: self) { (self, error) -> Single<TransactionResult> in
                                self.orderUpdateRepository
                                    .updateOrder(identifier: sellOrder.identifier, success: false)
                                    .asCompletable()
                                    .catch { _ in .empty() }
                                    .andThen(.error(error))
                            }
                            .flatMap(weak: self) { (self, result) -> Single<TransactionResult> in
                                self.orderUpdateRepository
                                    .updateOrder(identifier: sellOrder.identifier, success: true)
                                    .asCompletable()
                                    .catch { _ in .empty() }
                                    .andThen(.just(result))
                            }
                    }
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        onChainEngine.doUpdateFeeLevel(
            pendingTransaction: pendingTransaction,
            level: level,
            customFeeAmount: customFeeAmount
        )
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateUpdateAmount(amount)
            .flatMap(weak: self) { (self, amount) -> Single<PendingTransaction> in
                self.onChainEngine
                    .update(amount: amount, pendingTransaction: pendingTransaction)
                    .do(onSuccess: { pendingTransaction in
                        self.quotesEngine.update(amount: pendingTransaction.amount.amount)
                    })
                    .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
                        self.clearConfirmations(pendingTransaction: pendingTransaction)
                    }
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        quote
            .take(1)
            .asSingle()
            .map { [targetAsset, sourceAccount, target] pricedQuote -> (PendingTransaction, PricedQuote) in
                let resultValue = FiatValue(amount: pricedQuote.price, currency: targetAsset).moneyValue
                let baseValue = MoneyValue.one(currency: pendingTransaction.amount.currency)
                let sellDestinationValue: MoneyValue = pendingTransaction.amount.convert(using: resultValue)
                let sellFiatFeeValue: MoneyValue = pendingTransaction.feeAmount.convert(using: resultValue)

                var confirmations = [TransactionConfirmation]()

                if let pendingTransactionAmount = pendingTransaction.amount.cryptoValue {
                    confirmations.append(.sellSourceValue(.init(cryptoValue: pendingTransactionAmount)))
                }
                if let sellDestinationFiatValue = sellDestinationValue.fiatValue {
                    confirmations.append(.sellDestinationValue(.init(fiatValue: sellDestinationFiatValue)))
                }
                confirmations.append(.sellExchangeRateValue(.init(baseValue: baseValue, resultValue: resultValue)))
                if let sourceAccountLabel = sourceAccount?.label {
                    confirmations.append(.source(.init(value: sourceAccountLabel)))
                }
                if !pricedQuote.staticFee.isZero {
                    confirmations.append(.transactionFee(.init(fee: pricedQuote.staticFee)))
                }
                confirmations += [
                    .destination(.init(value: target.label)),
                    .networkFee(.init(
                        primaryCurrencyFee: pendingTransaction.feeAmount,
                        secondaryCurrencyFee: sellFiatFeeValue,
                        feeType: .withdrawalFee
                    ))
                ]
                if let sellTotalFiatValue = (try? sellDestinationValue + sellFiatFeeValue),
                   let sellTotalCryptoValue = (try? pendingTransaction.amount + pendingTransaction.feeAmount)
                {
                    confirmations.append(
                        .totalCost(
                            .init(
                                primaryCurrencyFee: sellTotalCryptoValue,
                                secondaryCurrencyFee: sellTotalFiatValue
                            )
                        )
                    )
                }
                let updatedTransaction = pendingTransaction.update(confirmations: confirmations)
                return (updatedTransaction, pricedQuote)
            }
            .flatMap(weak: self) { (self, tuple) in
                let (pendingTransaction, pricedQuote) = tuple
                return self.updateLimits(pendingTransaction: pendingTransaction, pricedQuote: pricedQuote)
            }
    }
}
