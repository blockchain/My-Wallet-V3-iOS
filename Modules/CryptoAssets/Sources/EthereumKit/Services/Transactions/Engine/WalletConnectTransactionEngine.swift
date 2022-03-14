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

    let requireSecondPassword: Bool
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
    private let keyPairProvider: AnyKeyPairProvider<EthereumKeyPair>
    private let priceService: PriceServiceAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let transactionSigningService: EthereumTransactionSigningServiceAPI
    private let pendingTransactionRepository: PendingTransactionRepositoryAPI

    private var didExecute = false
    private var cancellables: Set<AnyCancellable> = []
    private var walletConnectTarget: EthereumSendTransactionTarget {
        transactionTarget as! EthereumSendTransactionTarget
    }

    private var ethereumCryptoAccount: EthereumCryptoAccount {
        sourceAccount as! EthereumCryptoAccount
    }

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve(),
        gasEstimateService: GasEstimateServiceAPI = resolve(),
        keyPairProvider: AnyKeyPairProvider<EthereumKeyPair> = resolve(),
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
        self.priceService = priceService
        self.requireSecondPassword = requireSecondPassword
        self.transactionBuildingService = transactionBuildingService
        self.transactionSigningService = transactionSigningService
        self.pendingTransactionRepository = pendingTransactionRepository
        self.walletCurrencyService = walletCurrencyService
        feeCache = CachedValue(
            configuration: .periodic(
                seconds: 90,
                schedulerIdentifier: "WalletConnectTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<EthereumTransactionFee> in
            self.feeService
                .fees(cryptoCurrency: self.sourceCryptoCurrency)
                .asSingle()
        }
    }

    func assertInputsValid() {
        precondition(sourceAccount is EthereumCryptoAccount)
        precondition(sourceCryptoCurrency == .ethereum)
        precondition(transactionTarget is EthereumSendTransactionTarget)
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
                    self.sourceAccount.actionableBalance,
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
                getFeeState(pendingTransaction: pendingTransaction)
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
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        guard pendingTransaction.amount.currency == .crypto(.ethereum) else {
            fatalError("Not an ethereum value.")
        }
        let address = walletConnectTarget.transaction.to
            .flatMap { EthereumAddress(address: $0) }

        let chainID = ethereumCryptoAccount.network.chainID
        let transactionPublisher = ethereumCryptoAccount.nonce
            .eraseError()
            .flatMap { [transactionBuildingService, walletConnectTarget] nonce in
                transactionBuildingService
                    .buildTransaction(
                        amount: pendingTransaction.amount,
                        to: address!,
                        gasPrice: BigUInt(pendingTransaction.gasPrice.amount),
                        gasLimit: BigUInt(pendingTransaction.gasLimit),
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
            return Single
                .zip(
                    transactionPublisher.asSingle(),
                    keyPairProvider.keyPair(with: secondPassword)
                )
                .flatMap { [transactionSigningService] transaction, keyPair -> Single<EthereumTransactionEncoded> in
                    transactionSigningService.sign(
                        transaction: transaction,
                        keyPair: keyPair
                    )
                    .asSingle()
                }
                .map(\.rawTransaction)
                .map { rawTransaction -> TransactionResult in
                    .signed(rawTx: rawTransaction)
                }
        case .send:
            return transactionPublisher.asSingle()
                .flatMap { [ethereumTransactionDispatcher] candidate in
                    ethereumTransactionDispatcher.send(
                        transaction: candidate,
                        secondPassword: secondPassword
                    )
                }
                .map(\.transactionHash)
                .map { transactionHash -> TransactionResult in
                    .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
                }
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
        let feeSelection = TransactionConfirmation.Model.FeeSelection(
            feeState: feeState,
            selectedLevel: pendingTransaction.feeLevel,
            fee: pendingTransaction.feeAmount
        )
        let notice = TransactionConfirmation.Model.Notice(
            value: String(
                format: LocalizationConstants.Transaction.Sign.dappRequestWarning,
                walletConnectTarget.dAppName
            )
        )
        let imageNotice = TransactionConfirmation.Model.ImageNotice(
            imageURL: walletConnectTarget.dAppLogoURL,
            title: walletConnectTarget.dAppName,
            subtitle: walletConnectTarget.dAppAddress
        )
        let sendDestinationValue = TransactionConfirmation.Model.SendDestinationValue(
            value: pendingTransaction.amount
        )
        let source = TransactionConfirmation.Model.Source(
            value: sourceAccount.label
        )
        let destination = TransactionConfirmation.Model.Destination(
            value: transactionTarget.label
        )
        let feedTotal = TransactionConfirmation.Model.FeedTotal(
            amount: pendingTransaction.amount,
            amountInFiat: amountInFiat,
            fee: pendingTransaction.feeAmount,
            feeInFiat: feesInFiat
        )
        return pendingTransaction.update(
            confirmations: [
                .imageNotice(imageNotice),
                .notice(notice),
                .sendDestinationValue(sendDestinationValue),
                .source(source),
                .destination(destination),
                .feeSelection(feeSelection),
                .feedTotal(feedTotal)
            ]
        )
    }

    private func gasLimit() -> Single<BigInt> {
        func transactionGas() -> Single<BigInt>? {
            walletConnectTarget.transaction.gas
                .flatMap { BigInt($0.withoutHex, radix: 16) }
                .flatMap { Single.just($0) }
        }
        func estimateGas() -> Single<BigInt> {
            gasEstimateService
                .estimateGas(
                    network: ethereumCryptoAccount.network,
                    transaction: walletConnectTarget.transaction
                )
                .asSingle()
        }
        return transactionGas() ?? estimateGas()
    }

    private func gasPrice() -> Single<CryptoValue> {
        func transactionGasPrice() -> Single<CryptoValue>? {
            walletConnectTarget.transaction.gasPrice
                .flatMap { BigInt($0.withoutHex, radix: 16) }
                .flatMap { CryptoValue(amount: $0, currency: .ethereum) }
                .flatMap { Single.just($0) }
        }
        func regularGasPrice() -> Single<CryptoValue> {
            feeCache.valueSingle.map(\.regular)
        }
        return transactionGasPrice() ?? regularGasPrice()
    }

    private func calculateFee(
        with feeLevel: FeeLevel
    ) -> Single<(gasLimit: BigInt, gasPrice: CryptoValue, fee: CryptoValue)> {
        Single
            .zip(gasLimit(), gasPrice())
            .map { gasLimit, gasPrice in
                (
                    gasLimit,
                    gasPrice,
                    CryptoValue(amount: gasLimit * gasPrice.amount, currency: .ethereum)
                )
            }
    }

    private func validateSourceAddress() -> Completable {
        sourceAccount
            .receiveAddress
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
                network: ethereumCryptoAccount.network,
                address: ethereumCryptoAccount.publicKey
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
        sourceAccount.actionableBalance
            .map { [sourceAccount, transactionTarget] actionableBalance in
                guard pendingTransaction.gasLimit != nil,
                      pendingTransaction.gasPrice != nil
                else {
                    return
                }
                if try (try pendingTransaction.feeAmount + pendingTransaction.amount) > actionableBalance {
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
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: .ethereum)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: .ethereum))
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
        let ethereum: CryptoCurrency = .ethereum
        let zeroEthereum: MoneyValue = .zero(currency: ethereum)
        let amount: MoneyValue = transaction.value
            .flatMap { BigInt($0.withoutHex, radix: 16) }
            .flatMap { MoneyValue(amount: $0, currency: .crypto(ethereum)) }
            ?? zeroEthereum
        return PendingTransaction(
            amount: amount,
            available: zeroEthereum,
            feeAmount: zeroEthereum,
            feeForFullAvailable: zeroEthereum,
            feeSelection: .init(
                selectedLevel: .regular,
                availableLevels: [.regular],
                asset: .crypto(ethereum)
            ),
            selectedFiatCurrency: fiatCurrency
        )
    }
}

extension PendingTransaction {

    fileprivate var gasPrice: CryptoValue! {
        get { engineState[.gasPrice] as? CryptoValue }
        set { engineState[.gasPrice] = newValue }
    }

    fileprivate var gasLimit: BigInt! {
        get { engineState[.gasLimit] as? BigInt }
        set { engineState[.gasLimit] = newValue }
    }
}
