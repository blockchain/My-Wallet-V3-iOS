// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class NonCustodialSellTransactionEngine: SellTransactionEngine {

    let canTransactFiat: Bool = false

    let app: AppProtocol
    let receiveAddressFactory: ExternalAssetAddressServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let onChainEngine: OnChainTransactionEngine
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .fromUserKey
    let orderUpdateRepository: OrderUpdateRepositoryAPI
    let hotWalletAddressService: HotWalletAddressServiceAPI
    let transactionLimitsService: TransactionLimitsServiceAPI
    let accountRepository: NabuAccountsRepositoryProtocol

    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    init(
        app: AppProtocol = resolve(),
        onChainEngine: OnChainTransactionEngine,
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        orderUpdateRepository: OrderUpdateRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        receiveAddressFactory: ExternalAssetAddressServiceAPI = resolve(),
        hotWalletAddressService: HotWalletAddressServiceAPI = resolve(),
        accountRepository: NabuAccountsRepositoryProtocol = resolve()
    ) {
        self.app = app
        self.orderCreationRepository = orderCreationRepository
        self.orderUpdateRepository = orderUpdateRepository
        self.transactionLimitsService = transactionLimitsService
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.onChainEngine = onChainEngine
        self.receiveAddressFactory = receiveAddressFactory
        self.hotWalletAddressService = hotWalletAddressService
        self.accountRepository = accountRepository
    }

    func assertInputsValid() {
        precondition(sourceAccount is NonCustodialAccount)
        precondition(transactionTarget is FiatAccount)
    }

    private func startOnChainEngine(sampleDepositAddress: String) -> Single<Void> {
        createTransactionTarget(sellOrderDepositAddress: sampleDepositAddress)
            .flatMap { [onChainEngine, sourceAccount] transactionTarget in
                onChainEngine.start(
                    sourceAccount: sourceAccount!,
                    transactionTarget: transactionTarget,
                    askForRefreshConfirmation: { _ in .empty() }
                )
                return .just(())
            }
    }

    private func defaultFeeLevel(pendingTransaction: PendingTransaction) -> FeeLevel {
        if pendingTransaction.feeSelection.availableLevels.contains(.priority) {
            return .priority
        }
        return pendingTransaction.feeSelection.selectedLevel
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        accountRepository.account(product: .swap, currency: sourceCryptoCurrency)
            .asSingle()
            .flatMap(weak: self) { (self, account) -> Single<PendingTransaction> in
                self.startOnChainEngine(sampleDepositAddress: account.address)
                    .flatMap { [weak self] _ -> Single<PendingTransaction> in
                        guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                        return onChainEngine.initializeTransaction()
                    }
                    .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
                        pendingTransaction.update(
                            selectedFeeLevel: self.defaultFeeLevel(pendingTransaction: pendingTransaction)
                        )
                    }
            }
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .flatMap { [weak self] sellOrder -> Single<TransactionResult> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                guard let depositAddress = sellOrder.depositAddress else {
                    throw PlatformKitError.illegalStateException(message: "Missing deposit address")
                }
                return receiveAddressFactory
                    .makeExternalAssetAddress(
                        asset: sourceAsset,
                        address: depositAddress,
                        label: depositAddress,
                        onTxCompleted: { _ in AnyPublisher.just(()) }
                    )
                    .single
                    .flatMap { [weak self] transactionTarget -> Single<PendingTransaction> in
                        guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                        return onChainEngine
                            .restart(transactionTarget: transactionTarget, pendingTransaction: pendingTransaction)
                    }
                    .flatMap { [weak self] pendingTransaction -> Single<TransactionResult> in
                        guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                        return onChainEngine
                            .execute(pendingTransaction: pendingTransaction)
                            .catch { [weak self] error -> Single<TransactionResult> in
                                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                                return orderUpdateRepository
                                    .updateOrder(identifier: sellOrder.identifier, success: false)
                                    .asCompletable()
                                    .catch { _ in .empty() }
                                    .andThen(.error(error))
                            }
                            .flatMap { [weak self] result -> Single<TransactionResult> in
                                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                                return orderUpdateRepository
                                    .updateOrder(identifier: sellOrder.identifier, success: true)
                                    .asCompletable()
                                    .catch { _ in .empty() }
                                    .andThen(.just(result))
                            }
                    }
            }
    }

    /**
     Creates TransactionTarget for executing the on chain transaction.

     - Returns: Single that emits a TransactionTarget. If there is no hot wallet address for 'swap' associated with the current currency,
     then the emitted value will be the order deposit address. Else, if there is a hot wallet address, it will emit a HotWalletTransactionTarget.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */
    private func createTransactionTarget(
        sellOrderDepositAddress: String
    ) -> Single<TransactionTarget> {
        let depositAddress = receiveAddressFactory.makeExternalAssetAddress(
            asset: sourceAsset,
            address: sellOrderDepositAddress,
            label: sellOrderDepositAddress,
            onTxCompleted: { _ in AnyPublisher.just(()) }
        )
        switch depositAddress {
        case .failure(let error):
            return .error(error)
        case .success(let receiveAddress):
            return hotWalletReceiveAddress
                .map { hotWalletAddress -> TransactionTarget in
                    guard let hotWalletAddress else {
                        return receiveAddress
                    }
                    return HotWalletTransactionTarget(
                        realAddress: receiveAddress,
                        hotWalletAddress: hotWalletAddress
                    )
                }
        }
    }

    /// Returns the Hot Wallet receive address for the current cryptocurrency.
    private var hotWalletReceiveAddress: Single<CryptoReceiveAddress?> {
        hotWalletAddressService
            .hotWalletAddress(for: sourceAsset, product: .trading)
            .asSingle()
            .flatMap { [sourceAsset, receiveAddressFactory] hotWalletAddress -> Single<CryptoReceiveAddress?> in
                guard let hotWalletAddress else {
                    return .just(nil)
                }
                return receiveAddressFactory.makeExternalAssetAddress(
                    asset: sourceAsset,
                    address: hotWalletAddress,
                    label: hotWalletAddress,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .single
                .optional()
            }
            .catchAndReturn(nil)
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
            .flatMap { [weak self] amount -> Single<PendingTransaction> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                return onChainEngine
                    .update(amount: amount, pendingTransaction: pendingTransaction)
                    .map { [weak self] pendingTransaction -> PendingTransaction in
                        guard let self else { throw ToolKitError.nullReference(Self.self) }
                        return clearConfirmations(pendingTransaction: pendingTransaction)
                    }
            }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine
            .validateAmount(pendingTransaction: pendingTransaction)
            .flatMap { [weak self] pendingTransaction -> Single<PendingTransaction> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                switch pendingTransaction.validationState {
                case .canExecute:
                    return defaultValidateAmount(pendingTransaction: pendingTransaction)
                default:
                    return .just(pendingTransaction)
                }
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine
            .doValidateAll(pendingTransaction: pendingTransaction)
            .flatMap { [weak self] pendingTransaction -> Single<PendingTransaction> in
                guard let self else { return .error(ToolKitError.nullReference(Self.self)) }
                switch pendingTransaction.validationState {
                case .canExecute:
                    return defaultDoValidateAll(pendingTransaction: pendingTransaction)
                default:
                    return .just(pendingTransaction)
                }
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func createOrder(pendingTransaction: PendingTransaction) -> Single<SellOrder> {
        guard let quote = pendingTransaction.quote else {
            return .error("Cannot create an order with no quote")
        }
        return sourceAccount.receiveAddress.asSingle()
            .flatMap { [weak self] refundAddress throws -> Single<SellOrder> in
                guard let self else { return .never() }
                return orderCreationRepository
                    .createOrder(
                        direction: orderDirection,
                        quoteIdentifier: quote.id,
                        volume: pendingTransaction.amount,
                        ccy: target.currencyType.code,
                        refundAddress: refundAddress.address
                    )
                    .asSingle()
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard let pricedQuote = pendingTransaction.quote else {
            return .just(pendingTransaction.update(confirmations: []))
        }
        let resultValue = FiatValue.create(
            minor: pricedQuote.price,
            currency: targetAsset
        )?.moneyValue ?? .zero(currency: targetAsset)
        let baseValue = MoneyValue.one(currency: pendingTransaction.amount.currency)
        let sellDestinationValue: MoneyValue = pendingTransaction.amount.convert(using: resultValue)
        let sellFiatFeeValue: MoneyValue = pendingTransaction.feeAmount.convert(using: resultValue)
        var confirmations = [TransactionConfirmation]()
        if let pendingTransactionAmount = pendingTransaction.amount.cryptoValue {
            confirmations.append(
                TransactionConfirmations.SellSourceValue(
                    cryptoValue: pendingTransactionAmount
                )
            )
        }
        if let sellDestinationFiatValue = sellDestinationValue.fiatValue {
            confirmations.append(
                TransactionConfirmations.SellDestinationValue(
                    fiatValue: sellDestinationFiatValue
                )
            )
        }
        confirmations.append(
            TransactionConfirmations.SellExchangeRateValue(
                baseValue: baseValue,
                resultValue: resultValue
            )
        )
        if let sourceAccountLabel = sourceAccount?.label {
            confirmations.append(TransactionConfirmations.Source(value: sourceAccountLabel))
        }
        if pricedQuote.fee.static.isNotZero {
            confirmations.append(TransactionConfirmations.FiatTransactionFee(fee: pricedQuote.fee.static))
        }
        confirmations += [
            TransactionConfirmations.Destination(value: target.label),
            TransactionConfirmations.NetworkFee(
                primaryCurrencyFee: pendingTransaction.feeAmount,
                secondaryCurrencyFee: sellFiatFeeValue,
                feeType: .withdrawalFee
            )
        ]
        if let sellTotalFiatValue = (try? sellDestinationValue + sellFiatFeeValue),
           let sellTotalCryptoValue = (try? pendingTransaction.amount + pendingTransaction.feeAmount)
        {
            confirmations.append(
                TransactionConfirmations.TotalCost(
                    primaryCurrencyFee: sellTotalCryptoValue,
                    secondaryCurrencyFee: sellTotalFiatValue
                )
            )
        }
        let updatedTransaction = pendingTransaction.update(confirmations: confirmations)
        return updateLimits(pendingTransaction: updatedTransaction, quote: pricedQuote)
    }
}
