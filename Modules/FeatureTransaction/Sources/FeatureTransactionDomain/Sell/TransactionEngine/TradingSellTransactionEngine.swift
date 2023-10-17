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

    private var actionableBalance: AnyPublisher<MoneyValue, Error> {
        sourceAccount.actionableBalance
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
        actionableBalance
            .zip(walletCurrencyService.displayCurrency.eraseError())
            .flatMap { [weak self] actionableBalance, fiatCurrency -> AnyPublisher<PendingTransaction, Error> in
                guard let self else {
                    return .failure(ToolKitError.nullReference(Self.self))
                }
                let pendingTransaction = PendingTransaction(
                    amount: .zero(currency: sourceAsset),
                    available: actionableBalance,
                    feeAmount: .zero(currency: sourceAsset),
                    feeForFullAvailable: .zero(currency: sourceAsset),
                    feeSelection: .empty(asset: sourceAsset),
                    selectedFiatCurrency: fiatCurrency
                )
                return updateLimits(
                    pendingTransaction: pendingTransaction,
                    quote: .zero(sourceAsset.code, targetAsset.code)
                )
                .handlePendingOrdersError(initialValue: pendingTransaction)
            }
            .asSingle()
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
        validateUpdateAmount(amount).eraseError()
            .zip(actionableBalance)
            .map { (normalized: MoneyValue, balance: MoneyValue) -> PendingTransaction in
                pendingTransaction.update(amount: normalized, available: balance)
            }
            .map { pendingTransaction -> PendingTransaction in
                pendingTransaction.update(confirmations: [])
            }
            .asSingle()
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultValidateAmount(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<PendingTransaction, Error> {
        guard let pricedQuote = pendingTransaction.quote else {
            return .just(pendingTransaction.update(confirmations: []))
        }
        do {
            let sellSourceValue = pendingTransaction.amount
            let resultValue = try FiatValue.create(
                minor: pricedQuote.price,
                currency: targetAsset
            ).or(throw: "No price".error()).moneyValue
            let baseValue = MoneyValue.one(currency: sellSourceValue.currency)
            let sellDestinationValue: MoneyValue = sellSourceValue.convert(using: resultValue)

            var confirmations: [TransactionConfirmation] = []

            if let expiresAt = pricedQuote.date.expiresAt {
                confirmations.append(TransactionConfirmations.QuoteExpirationTimer(expirationDate: expiresAt))
            }
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
            return .failure(error)
        }
    }
}
