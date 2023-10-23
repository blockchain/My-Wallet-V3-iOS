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

    private var actionableBalance: AnyPublisher<MoneyValue, Error> {
        sourceAccount.actionableBalance
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
        walletCurrencyService.displayCurrency.eraseError().prefix(1)
            .zip(actionableBalance)
            .tryMap { [weak self] fiatCurrency, actionableBalance -> PendingTransaction in
                guard let self else {
                    throw ToolKitError.nullReference(Self.self)
                }
                return PendingTransaction(
                    amount: .zero(currency: sourceAsset),
                    available: actionableBalance,
                    feeAmount: .zero(currency: sourceAsset),
                    feeForFullAvailable: .zero(currency: sourceAsset),
                    feeSelection: .empty(asset: sourceAsset),
                    selectedFiatCurrency: fiatCurrency
                )
            }
            .flatMap { [weak self] pendingTransaction -> AnyPublisher<PendingTransaction, Error> in
                guard let self else {
                    return .failure(ToolKitError.nullReference(Self.self))
                }
                return updateLimits(
                    pendingTransaction: pendingTransaction,
                    quote: .zero(sourceAccount.currencyType.code, target.currencyType.code)
                )
                .handlePendingOrdersError(initialValue: pendingTransaction)
            }
            .asSingle()
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
}
