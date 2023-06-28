// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class EthereumOnChainTransactionEngine: OnChainTransactionEngine {

    // MARK: - OnChainTransactionEngine

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI

    var askForRefreshConfirmation: AskForRefreshConfirmation!

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }

    // MARK: - Private Properties

    private let ethereumAccountService: EthereumAccountServiceAPI
    private let ethereumOnChainEngineCompanion: EthereumOnChainEngineCompanionAPI
    private let ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI
    private let feeCache: CachedValue<EthereumTransactionFee>
    private let feeService: EthereumFeeServiceAPI
    private let network: EVMNetwork
    private let pendingTransactionRepository: PendingTransactionRepositoryAPI
    private let receiveAddressFactory: ExternalAssetAddressServiceAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI

    private var evmCryptoAccount: EVMCryptoAccount {
        sourceAccount as! EVMCryptoAccount
    }

    private var actionableBalance: Single<MoneyValue> {
        sourceAccount.actionableBalance.asSingle()
    }

    // MARK: - Init

    init(
        network: EVMNetwork,
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        ethereumAccountService: EthereumAccountServiceAPI = resolve(),
        ethereumOnChainEngineCompanion: EthereumOnChainEngineCompanionAPI = resolve(),
        ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve(),
        pendingTransactionRepository: PendingTransactionRepositoryAPI = resolve(),
        receiveAddressFactory: ExternalAssetAddressServiceAPI = resolve(),
        transactionBuildingService: EthereumTransactionBuildingServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.currencyConversionService = currencyConversionService
        self.ethereumAccountService = ethereumAccountService
        self.ethereumOnChainEngineCompanion = ethereumOnChainEngineCompanion
        self.ethereumTransactionDispatcher = ethereumTransactionDispatcher
        self.feeService = feeService
        self.network = network
        self.pendingTransactionRepository = pendingTransactionRepository
        self.receiveAddressFactory = receiveAddressFactory
        self.transactionBuildingService = transactionBuildingService
        self.walletCurrencyService = walletCurrencyService
        self.feeCache = CachedValue(
            configuration: .periodic(
                seconds: 90,
                schedulerIdentifier: "EthereumOnChainTransactionEngine"
            )
        )
        feeCache.setFetch { [feeService, network] () -> Single<EthereumTransactionFee> in
            feeService
                .fees(network: network)
                .asSingle()
        }
    }

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceAccount is EVMCryptoAccount)
        precondition(
            isCurrencyTypeValid(sourceCryptoCurrency.currencyType),
            "Invalid source asset '\(sourceCryptoCurrency.code)'."
        )
    }

    private func isCurrencyTypeValid(_ value: CurrencyType) -> Bool {
        value == .crypto(network.nativeAsset)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            walletCurrencyService
                .displayCurrency
                .asSingle(),
            actionableBalance,
            absoluteFee(with: .regular)
        )
        .map { [network, predefinedAmount] fiatCurrency, availableBalance, feeAmount -> PendingTransaction in
            let amount: MoneyValue
            if let predefinedAmount,
               predefinedAmount.currency == network.nativeAsset
            {
                amount = predefinedAmount
            } else {
                amount = .zero(currency: network.nativeAsset)
            }
            return PendingTransaction(
                amount: amount,
                available: availableBalance,
                feeAmount: feeAmount.moneyValue,
                feeForFullAvailable: feeAmount.moneyValue,
                feeSelection: .init(
                    selectedLevel: .regular,
                    availableLevels: [.regular, .priority],
                    asset: .crypto(network.nativeAsset)
                ),
                selectedFiatCurrency: fiatCurrency
            )
        }
    }

    func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        Single
            .zip(
                fiatAmountAndFees(from: pendingTransaction),
                getFeeState(pendingTransaction: pendingTransaction).asSingle()
            )
            .map(weak: self) { (self, payload) -> PendingTransaction in
                let ((amount, fees), feeState) = payload
                return self.doBuildConfirmations(
                    pendingTransaction: pendingTransaction,
                    amountInFiat: amount.moneyValue,
                    feesInFiat: fees.moneyValue,
                    feeState: feeState
                )
            }
    }

    private func doBuildConfirmations(
        pendingTransaction: PendingTransaction,
        amountInFiat: MoneyValue,
        feesInFiat: MoneyValue,
        feeState: FeeState
    ) -> PendingTransaction {
        let sendDestinationValue = TransactionConfirmations.SendDestinationValue(
            value: pendingTransaction.amount
        )
        let source = TransactionConfirmations.Source(
            value: sourceAccount.label
        )
        let destination = TransactionConfirmations.Destination(
            value: transactionTarget.label
        )
        let feeSelection = TransactionConfirmations.FeeSelection(
            feeState: feeState,
            selectedLevel: pendingTransaction.feeLevel,
            fee: pendingTransaction.feeAmount
        )
        let feedTotal = TransactionConfirmations.FeedTotal(
            amount: pendingTransaction.amount,
            amountInFiat: amountInFiat,
            fee: pendingTransaction.feeAmount,
            feeInFiat: feesInFiat
        )
        return pendingTransaction.update(
            confirmations: [
                sendDestinationValue,
                source,
                destination,
                feeSelection,
                feedTotal
            ]
        )
    }

    func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        guard let crypto = amount.cryptoValue else {
            preconditionFailure("Not a `CryptoValue`.")
        }
        guard isCurrencyTypeValid(crypto.currencyType) else {
            preconditionFailure("Not an \(network.networkConfig.name) value.")
        }
        return Single.zip(
            actionableBalance,
            absoluteFee(with: pendingTransaction.feeLevel)
        )
        .map { actionableBalance, fee -> PendingTransaction in
            let available = try actionableBalance - fee.moneyValue
            let zero: MoneyValue = .zero(currency: actionableBalance.currency)
            let max: MoneyValue = try .max(available, zero)
            return pendingTransaction.update(
                amount: amount,
                available: max,
                fee: fee.moneyValue,
                feeForFullAvailable: fee.moneyValue
            )
        }
    }

    func doOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction> {
        if let feeSelection = newConfirmation as? TransactionConfirmations.FeeSelection {
            return updateFeeSelection(
                pendingTransaction: pendingTransaction,
                newFeeLevel: feeSelection.selectedLevel,
                customFeeAmount: nil
            )
        } else {
            return defaultDoOptionUpdateRequest(
                pendingTransaction: pendingTransaction,
                newConfirmation: newConfirmation
            )
        }
    }

    func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        actionableBalance
            .flatMap(weak: self) { (self, actionableBalance) -> Single<PendingTransaction> in
                self.validateSufficientFunds(
                    pendingTransaction: pendingTransaction,
                    actionableBalance: actionableBalance
                )
                .andThen(self.validateNoPendingTransaction())
                .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
            }
    }

    func execute(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        guard isCurrencyTypeValid(pendingTransaction.amount.currency) else {
            fatalError("Not an ethereum value.")
        }
        let evmCryptoAccount = evmCryptoAccount
        let transactionBuildingService = transactionBuildingService
        let destinationAddresses = ethereumOnChainEngineCompanion
            .destinationAddresses(
                transactionTarget: transactionTarget,
                cryptoCurrency: sourceCryptoCurrency,
                receiveAddressFactory: receiveAddressFactory
            )
        let extraGasLimit = ethereumOnChainEngineCompanion
            .extraGasLimit(
                transactionTarget: transactionTarget,
                cryptoCurrency: sourceCryptoCurrency,
                receiveAddressFactory: receiveAddressFactory
            )
        return Single
            .zip(
                feeCache.valueSingle,
                destinationAddresses,
                receiveAddressIsContract,
                extraGasLimit
            )
            .flatMap { fee, destinationAddresses, isContract, extraGasLimit
                -> Single<EthereumTransactionCandidate> in
                evmCryptoAccount.nonce
                    .flatMap { nonce in
                        transactionBuildingService.buildTransaction(
                            amount: pendingTransaction.amount,
                            to: destinationAddresses.destination,
                            addressReference: destinationAddresses.referenceAddress,
                            gasPrice: fee.gasPrice(
                                feeLevel: pendingTransaction.feeLevel.ethereumFeeLevel
                            ),
                            gasLimit: fee.gasLimit(
                                extraGasLimit: extraGasLimit,
                                isContract: isContract
                            ),
                            nonce: nonce,
                            chainID: evmCryptoAccount.network.networkConfig.chainID,
                            contractAddress: nil
                        )
                        .publisher
                    }
                    .asSingle()
            }
            .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                self.ethereumTransactionDispatcher
                    .send(
                        transaction: candidate,
                        network: self.network.networkConfig
                    )
                    .asSingle()
            }
            .map(\.transactionHash)
            .map { transactionHash -> TransactionResult in
                .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
            }
    }

    func doRefreshConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }
}

extension EthereumOnChainTransactionEngine {

    /// Returns Ethereum CryptoValue of the maximum fee that the user may pay.
    private func absoluteFee(with feeLevel: FeeLevel) -> Single<CryptoValue> {
        Single
            .zip(feeCache.valueSingle, receiveAddressIsContract)
            .flatMap(weak: self) { (self, values) -> Single<CryptoValue> in
                let (fees, isContract) = values
                return self.ethereumOnChainEngineCompanion
                    .absoluteFee(
                        feeLevel: feeLevel,
                        fees: fees,
                        transactionTarget: self.transactionTarget,
                        cryptoCurrency: self.sourceCryptoCurrency,
                        receiveAddressFactory: self.receiveAddressFactory,
                        isContract: isContract
                    )
            }
    }

    private func validateNoPendingTransaction() -> Completable {
        pendingTransactionRepository
            .isWaitingOnTransaction(
                network: evmCryptoAccount.network.networkConfig
            )
            .replaceError(with: true)
            .flatMap { isWaitingOnTransaction in
                isWaitingOnTransaction
                    ? AnyPublisher.failure(TransactionValidationFailure(state: .transactionInFlight))
                    : AnyPublisher.just(())
            }
            .asCompletable()
    }

    private func validateSufficientFunds(
        pendingTransaction: PendingTransaction,
        actionableBalance: MoneyValue
    ) -> Completable {
        absoluteFee(with: pendingTransaction.feeLevel)
            .map { [sourceAccount, transactionTarget] fee -> Void in
                guard try pendingTransaction.amount >= pendingTransaction.minSpendable else {
                    throw TransactionValidationFailure(state: .belowMinimumLimit(pendingTransaction.minLimit))
                }
                guard try actionableBalance > fee.moneyValue else {
                    throw TransactionValidationFailure(state: .belowFees(fee.moneyValue, actionableBalance))
                }
                guard try (fee.moneyValue + pendingTransaction.amount) <= actionableBalance else {
                    throw TransactionValidationFailure(
                        state: .insufficientFunds(
                            pendingTransaction.available,
                            pendingTransaction.amount,
                            sourceAccount!.currencyType,
                            transactionTarget!.currencyType
                        )
                    )
                }
            }
            .asCompletable()
    }

    /// Returns true if the destination address is a contract.
    private var receiveAddressIsContract: Single<Bool> {
        let network = evmCryptoAccount.network
        return ethereumOnChainEngineCompanion
            .receiveAddress(transactionTarget: transactionTarget)
            .flatMap { [ethereumAccountService] receiveAddress in
                ethereumAccountService
                    .isContract(
                        network: network,
                        address: receiveAddress.address
                    )
                    .asSingle()
            }
    }

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: network.nativeAsset)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: network.nativeAsset))
        )
        .map { (quote: $0.0.quote.fiatValue ?? .zero(currency: .USD), amount: $0.1, fees: $0.2) }
        .map { (quote: FiatValue, amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convert(using: quote)
            let fiatFees = fees.convert(using: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [sourceAsset, currencyConversionService] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
            .asSingle()
    }
}
