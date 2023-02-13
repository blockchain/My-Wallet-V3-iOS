// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import FeatureProductsDomain
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingToTradingSwapTransactionEngine: SwapTransactionEngine {

    let canTransactFiat: Bool = true

    let app: AppProtocol
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .internal
    let transactionLimitsService: TransactionLimitsServiceAPI
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    // Used to check product eligibility
    private let productsService: FeatureProductsDomain.ProductsServiceAPI

    private var actionableBalance: Single<MoneyValue> {
        sourceAccount.actionableBalance.asSingle()
    }

    init(
        app: AppProtocol = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        productsService: FeatureProductsDomain.ProductsServiceAPI = resolve()
    ) {
        self.app = app
        self.orderCreationRepository = orderCreationRepository
        self.transactionLimitsService = transactionLimitsService
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.productsService = productsService
    }

    func assertInputsValid() {
        precondition(target is CryptoTradingAccount)
        precondition(sourceAccount is CryptoTradingAccount)
        precondition((target as! CryptoTradingAccount).asset != sourceAsset)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            walletCurrencyService.displayCurrency.asSingle(),
            actionableBalance
        )
        .map(weak: self) { (self, payload) -> PendingTransaction in
            let (fiatCurrency, actionableBalance) = payload
            return PendingTransaction(
                amount: .zero(currency: self.sourceAsset),
                available: actionableBalance,
                feeAmount: .zero(currency: self.sourceAsset),
                feeForFullAvailable: .zero(currency: self.sourceAsset),
                feeSelection: .empty(asset: self.sourceAsset),
                selectedFiatCurrency: fiatCurrency
            )
        }
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .map { (order: SwapOrder) in
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
}
