// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class WalletConnectTransactionEngine: OnChainTransactionEngine {

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

    private let ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI
    private let feeCache: CachedValue<EthereumTransactionFee>
    private let feeService: EthereumFeeServiceAPI
    private let gasEstimateService: GasEstimateServiceAPI
    private let keyPairProvider: EthereumKeyPairProvider
    private let network: EVMNetwork
    private let priceService: PriceServiceAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let transactionSigningService: EthereumTransactionSigningServiceAPI
    private let pendingTransactionRepository: PendingTransactionRepositoryAPI

    private var didExecute = false
    private var cancellables: Set<AnyCancellable> = []
    private var walletConnectTarget: EthereumSendTransactionTarget {
        transactionTarget as! EthereumSendTransactionTarget
    }

    private var evmCryptoAccount: EVMCryptoAccount {
        sourceAccount as! EVMCryptoAccount
    }

    // MARK: - Init

    init(
        network: EVMNetwork,
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve(),
        gasEstimateService: GasEstimateServiceAPI = resolve(),
        keyPairProvider: EthereumKeyPairProvider = resolve(),
        priceService: PriceServiceAPI = resolve(),
        transactionBuildingService: EthereumTransactionBuildingServiceAPI = resolve(),
        transactionSigningService: EthereumTransactionSigningServiceAPI = resolve(),
        pendingTransactionRepository: PendingTransactionRepositoryAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.currencyConversionService = currencyConversionService
        self.ethereumTransactionDispatcher = ethereumTransactionDispatcher
        self.feeService = feeService
        self.gasEstimateService = gasEstimateService
        self.keyPairProvider = keyPairProvider
        self.network = network
        self.priceService = priceService
        self.transactionBuildingService = transactionBuildingService
        self.transactionSigningService = transactionSigningService
        self.pendingTransactionRepository = pendingTransactionRepository
        self.walletCurrencyService = walletCurrencyService
        self.feeCache = CachedValue(
            configuration: .periodic(
                seconds: 90,
                schedulerIdentifier: "WalletConnectTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<EthereumTransactionFee> in
            self.feeService
                .fees(network: self.network, cryptoCurrency: self.sourceCryptoCurrency)
                .asSingle()
        }
    }

    func assertInputsValid() {
        precondition(sourceAccount is EVMCryptoAccount)
        precondition(transactionTarget is EthereumSendTransactionTarget)
        precondition(
            isCurrencyTypeValid(sourceCryptoCurrency.currencyType),
            "Invalid source asset '\(sourceCryptoCurrency.code)'."
        )
    }

    private func isCurrencyTypeValid(_ value: CurrencyType) -> Bool {
        value == .crypto(network.nativeAsset)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        walletCurrencyService
            .displayCurrency
            .asSingle()
            .map { [walletConnectTarget] fiatCurrency -> PendingTransaction in
                walletConnectTarget.pendingTransacation(fiatCurrency: fiatCurrency)
            }
            .flatMap(weak: self) { (self, pendingTransaction) in
                Single.zip(
                    self.sourceAccount.actionableBalance.asSingle(),
                    self.calculateFee(with: pendingTransaction.feeLevel)
                )
                .map { actionableBalance, fees -> PendingTransaction in
                    let available = try actionableBalance - fees.fee.moneyValue
                    let zero: MoneyValue = .zero(currency: actionableBalance.currency)
                    let max: MoneyValue = try .max(available, zero)
                    var pendingTransaction = pendingTransaction.update(
                        amount: pendingTransaction.amount,
                        available: max,
                        fee: fees.fee.moneyValue,
                        feeForFullAvailable: fees.fee.moneyValue
                    )
                    pendingTransaction.gasPrice = fees.gasPrice
                    pendingTransaction.gasLimit = fees.gasLimit
                    return pendingTransaction
                }
            }
            .flatMap(weak: self) { (self, pendingTransaction) in
                self.doBuildConfirmations(pendingTransaction: pendingTransaction)
            }
            .flatMap(weak: self) { (self, pendingTransaction) in
                // NOTE: Some WalletConnect transactions, specificallly listing
                // an NFT for sale on OpenSea has a tx amount of `0.00` and a fee.
                // `updateAmount`, which would trigger tx validation
                // only gets called in the event of a positive balance.
                // To circumvent this we validate the tx once on initialization.
                // ⚠️ This means any wallet connect tx with an amount of `0.00` may appear
                // as valid if all other requirements are met (which in this case is needed).
                self.doValidateAll(pendingTransaction: pendingTransaction)
            }
    }

    func start(
        sourceAccount: CryptoAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmation
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
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

    func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        validateSourceAddress()
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateNoPendingTransaction())
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        guard isCurrencyTypeValid(pendingTransaction.amount.currencyType) else {
            preconditionFailure("Not an \(network.networkConfig.name) value.")
        }
        let address = walletConnectTarget.transaction.to
            .flatMap { EthereumAddress(address: $0, network: network) }

        let chainID = evmCryptoAccount.network.networkConfig.chainID
        let transactionPublisher = evmCryptoAccount.nonce
            .eraseError()
            .flatMap { [transactionBuildingService, walletConnectTarget] nonce in
                transactionBuildingService
                    .buildTransaction(
                        amount: pendingTransaction.amount,
                        to: address!,
                        gasPrice: pendingTransaction.gasPrice,
                        gasLimit: pendingTransaction.gasLimit,
                        nonce: nonce,
                        chainID: chainID,
                        transferType: .transfer(data: Data(hex: walletConnectTarget.transaction.data))
                    )
                    .eraseError()
                    .publisher
            }
            .eraseToAnyPublisher()

        switch walletConnectTarget.method {
        case .sign:
            return transactionPublisher.zip(keyPairProvider.keyPair)
                .flatMap { [transactionSigningService] transaction, keyPair in
                    transactionSigningService.sign(
                        transaction: transaction,
                        keyPair: keyPair
                    )
                    .eraseError()
                }
                .map(\.rawTransaction)
                .map { rawTransaction -> TransactionResult in
                    .signed(rawTx: rawTransaction)
                }
                .asSingle()
        case .send:
            return transactionPublisher
                .flatMap { [network, ethereumTransactionDispatcher] candidate in
                    ethereumTransactionDispatcher.send(
                        transaction: candidate,
                        network: network.networkConfig
                    )
                }
                .map(\.transactionHash)
                .map { transactionHash -> TransactionResult in
                    .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
                }
                .asSingle()
        }
    }

    func doRefreshConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.feeSelection.availableLevels.contains(level))
        return .just(pendingTransaction)
    }

    private lazy var rejectOnce: Void = walletConnectTarget.onTransactionRejected()
        .subscribe()
        .store(in: &self.cancellables)

    func stop(pendingTransaction: PendingTransaction) {
        if !didExecute {
            _ = rejectOnce
        }
    }

    // MARK: - Private Functions

    private func doBuildConfirmations(
        pendingTransaction: PendingTransaction,
        amountInFiat: MoneyValue,
        feesInFiat: MoneyValue,
        feeState: FeeState
    ) -> PendingTransaction {
        let feeSelection = TransactionConfirmations.FeeSelection(
            feeState: feeState,
            selectedLevel: pendingTransaction.feeLevel,
            fee: pendingTransaction.feeAmount
        )
        let notice = TransactionConfirmations.Notice(
            value: String(
                format: LocalizationConstants.Transaction.Sign.dappRequestWarning,
                walletConnectTarget.dAppName
            )
        )
        let imageNotice = TransactionConfirmations.ImageNotice(
            imageURL: walletConnectTarget.dAppLogoURL,
            title: walletConnectTarget.dAppName,
            subtitle: walletConnectTarget.dAppAddress
        )
        let sendDestinationValue = TransactionConfirmations.SendDestinationValue(
            value: pendingTransaction.amount
        )
        let source = TransactionConfirmations.Source(
            value: sourceAccount.label
        )
        let destination = TransactionConfirmations.Destination(
            value: transactionTarget.label
        )
        let feedTotal = TransactionConfirmations.FeedTotal(
            amount: pendingTransaction.amount,
            amountInFiat: amountInFiat,
            fee: pendingTransaction.feeAmount,
            feeInFiat: feesInFiat
        )
        return pendingTransaction.update(
            confirmations: [
                imageNotice,
                notice,
                sendDestinationValue,
                source,
                destination,
                feeSelection,
                feedTotal
            ]
        )
    }

    private func gasLimit() -> Single<BigUInt> {
        func transactionGas() -> Single<BigUInt>? {
            walletConnectTarget.transaction.gas
                .flatMap { BigUInt($0.withoutHex, radix: 16) }
                .flatMap { Single.just($0) }
        }
        func estimateGas() -> Single<BigUInt> {
            gasEstimateService
                .estimateGas(
                    network: evmCryptoAccount.network,
                    transaction: walletConnectTarget.transaction
                )
                .asSingle()
        }
        return transactionGas() ?? estimateGas()
    }

    private func gasPrice() -> Single<BigUInt> {
        func transactionGasPrice() -> Single<BigUInt>? {
            walletConnectTarget.transaction.gasPrice
                .flatMap { BigUInt($0.withoutHex, radix: 16) }
                .flatMap { Single.just($0) }
        }
        func regularGasPrice() -> Single<BigUInt> {
            feeCache.valueSingle.map { fee in
                fee.gasPrice(feeLevel: .regular)
            }
        }
        return transactionGasPrice() ?? regularGasPrice()
    }

    private func calculateFee(
        with feeLevel: FeeLevel
    ) -> Single<(gasLimit: BigUInt, gasPrice: BigUInt, fee: CryptoValue)> {
        Single
            .zip(gasLimit(), gasPrice())
            .map { [network] gasLimit, gasPrice in
                (
                    gasLimit,
                    gasPrice,
                    CryptoValue.create(
                        minor: BigInt(gasLimit * gasPrice),
                        currency: network.nativeAsset
                    )
                )
            }
    }

    private func validateSourceAddress() -> Completable {
        sourceAccount
            .receiveAddress
            .asSingle()
            .map { [walletConnectTarget] receiveAddress in
                guard receiveAddress.address.caseInsensitiveCompare(walletConnectTarget.transaction.from) == .orderedSame else {
                    throw TransactionValidationFailure(state: .invalidAddress)
                }
            }
            .asCompletable()
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
        pendingTransaction: PendingTransaction
    ) -> Completable {
        sourceAccount.actionableBalance.asSingle()
            .map { [sourceAccount, transactionTarget] actionableBalance in
                guard pendingTransaction.gasLimit != nil,
                      pendingTransaction.gasPrice != nil
                else {
                    return
                }
                if try (pendingTransaction.feeAmount + pendingTransaction.amount) > actionableBalance {
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

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: network.nativeAsset)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: network.nativeAsset))
        )
        .map { sourceExchangeRatePair, amount, feeAmount in
            (
                quote: sourceExchangeRatePair.quote.fiatValue ?? .zero(currency: .USD),
                amount: amount,
                fees: feeAmount
            )
        }
        .map { (quote: FiatValue, amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convert(using: quote)
            let fiatFees = fees.convert(using: quote)
            return (
                amount: fiatAmount,
                fees: fiatFees
            )
        }
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [priceService, sourceAsset] fiatCurrency in
                priceService
                    .price(of: sourceAsset, in: fiatCurrency)
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
            .asSingle()
    }
}

extension EthereumSendTransactionTarget {
    func pendingTransacation(fiatCurrency: FiatCurrency) -> PendingTransaction {
        let zeroMoneyValue: MoneyValue = .zero(currency: network.nativeAsset)
        let amount: MoneyValue = transaction.value
            .flatMap { BigInt($0.withoutHex, radix: 16) }
            .flatMap { MoneyValue.create(minor: $0, currency: .crypto(network.nativeAsset)) }
            ?? zeroMoneyValue
        return PendingTransaction(
            amount: amount,
            available: zeroMoneyValue,
            feeAmount: zeroMoneyValue,
            feeForFullAvailable: zeroMoneyValue,
            feeSelection: .init(
                selectedLevel: .priority,
                availableLevels: [.priority],
                asset: .crypto(network.nativeAsset)
            ),
            selectedFiatCurrency: fiatCurrency
        )
    }
}

extension PendingTransaction {

    fileprivate var gasPrice: BigUInt! {
        get { engineState.value[.gasPrice] as? BigUInt }
        set { engineState.mutate { $0[.gasPrice] = newValue } }
    }

    fileprivate var gasLimit: BigUInt! {
        get { engineState.value[.gasLimit] as? BigUInt }
        set { engineState.mutate { $0[.gasLimit] = newValue } }
    }
}
