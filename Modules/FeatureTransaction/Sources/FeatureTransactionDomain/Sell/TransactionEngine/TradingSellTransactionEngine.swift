// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Blockchain
import Combine
import DIKit
import FeatureProductsDomain
import MoneyKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingSellTransactionEngine: SellTransactionEngine {

    let canTransactFiat: Bool = true

    let app: AppProtocol
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let transactionLimitsService: TransactionLimitsServiceAPI
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .internal
    // Used to check product eligibility
    private let productsService: FeatureProductsDomain.ProductsServiceAPI

    private var actionableBalance: Single<MoneyValue> {
        sourceAccount.actionableBalance.asSingle()
    }

    init(
        app: AppProtocol = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        productsService: FeatureProductsDomain.ProductsServiceAPI = resolve()
    ) {
        self.app = app
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.transactionLimitsService = transactionLimitsService
        self.orderCreationRepository = orderCreationRepository
        self.productsService = productsService
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
                walletCurrencyService.displayCurrency.asSingle(),
                actionableBalance
            )
            .flatMap(weak: self) { (self, payload) -> Single<PendingTransaction> in
                let (fiatCurrency, actionableBalance) = payload
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
                    quote: .zero(self.sourceAsset.code, self.targetAsset.code)
                )
                .handlePendingOrdersError(initialValue: pendingTransaction)
            }
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .map { order in
                TransactionResult.unHashed(amount: pendingTransaction.amount, orderId: order.identifier)
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(
            validateUpdateAmount(amount),
            actionableBalance
        )
        .map { (normalized: MoneyValue, balance: MoneyValue) -> PendingTransaction in
            pendingTransaction.update(amount: normalized, available: balance)
        }
        .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
            self.clearConfirmations(pendingTransaction: pendingTransaction)
        }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard let pricedQuote = pendingTransaction.quote else {
            return .just(pendingTransaction.update(confirmations: []))
        }
        do {
            let sellSourceValue = pendingTransaction.amount
            let resultValue = try FiatValue.create(
                minor: pricedQuote.price,
                currency: targetAsset
            ).or(throw: "No price").moneyValue
            let baseValue = MoneyValue.one(currency: sellSourceValue.currency)
            let sellDestinationValue: MoneyValue = sellSourceValue.convert(using: resultValue)

            var confirmations: [TransactionConfirmation] = try [
                TransactionConfirmations.QuoteExpirationTimer(
                    expirationDate: pricedQuote.date.expiresAt.or(throw: "No expiry")
                )
            ]
            if let sellSourceCryptoValue = sellSourceValue.cryptoValue {
                confirmations.append(TransactionConfirmations.SellSourceValue(cryptoValue: sellSourceCryptoValue))
            }
            if let sellDestinationFiatValue = sellDestinationValue.fiatValue {
                confirmations.append(
                    TransactionConfirmations.SellDestinationValue(
                        fiatValue: sellDestinationFiatValue
                    )
                )
            }
            if pricedQuote.fee.static.isNotZero {
                confirmations.append(TransactionConfirmations.FiatTransactionFee(fee: pricedQuote.fee.static))
            }
            confirmations += [
                TransactionConfirmations.SellExchangeRateValue(baseValue: baseValue, resultValue: resultValue),
                TransactionConfirmations.Source(value: sourceAccount.label),
                TransactionConfirmations.Destination(value: target.label)
            ]
            let updatedTransaction = pendingTransaction.update(confirmations: confirmations)
            return updateLimits(pendingTransaction: updatedTransaction, quote: pricedQuote)
        } catch {
            return .error(error)
        }
    }
}
