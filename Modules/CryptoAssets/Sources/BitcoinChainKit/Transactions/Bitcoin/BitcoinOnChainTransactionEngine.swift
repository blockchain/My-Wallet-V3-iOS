// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

// MARK: - Type

private enum BitcoinEngineError: Error {
    case alreadySent
}

final class BitcoinOnChainTransactionEngine<Token: BitcoinChainToken> {

    // MARK: Internal Properties

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI

    var sourceAccount: BlockchainAccount!
    var askForRefreshConfirmation: AskForRefreshConfirmation!
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

    private let app: AppProtocol
    private let feeRepository: AnyCryptoFeeRepository<BitcoinChainTransactionFee<Token>>
    private let recorder: Recording

    /// didExecuteFlag will be used to log/check if there is an issue
    /// with duplicated txs in the engine.
    private var didExecuteFlag: Bool = false

    private var bitcoinChainCryptoAccount: BitcoinChainCryptoAccount {
        sourceAccount as! BitcoinChainCryptoAccount
    }

    private var actionableBalance: AnyPublisher<MoneyValue, Error> {
        sourceAccount.actionableBalance
    }

    private var targetAddress: AnyPublisher<BitcoinChainReceiveAddress<Token>, Error> {
        switch transactionTarget {
        case let target as BitPayInvoiceTarget:
            let address = BitcoinChainReceiveAddress<Token>(
                address: target.address,
                label: target.label,
                onTxCompleted: target.onTxCompleted
            )
            return .just(address)
        case let target as BitcoinChainReceiveAddress<Token>:
            return .just(target)
        case let target as CryptoAccount:
            return target.receiveAddress
                .map { receiveAddress in
                    guard let receiveAddress = receiveAddress as? BitcoinChainReceiveAddress<Token> else {
                        fatalError("Engine requires transactionTarget to be a BitcoinChainReceiveAddress.")
                    }
                    return receiveAddress
                }
                .eraseToAnyPublisher()
        default:
            fatalError("Engine requires transactionTarget to be a BitcoinChainReceiveAddress.")
        }
    }

    private lazy var nativeBitcoinEnvironment: NativeBitcoinEnvironment = .init(
        unspentOutputRepository: DIKit.resolve(
            tag: Token.coin
        ),
        buildingService: resolve(tag: Token.coin),
        signingService: resolve(tag: Token.coin),
        sendingService: resolve(tag: Token.coin),
        fetchMultiAddressFor: resolve(tag: Token.coin),
        mnemonicProvider: resolve()
    )

    // MARK: - Init

    init(
        app: AppProtocol = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        feeRepository: AnyCryptoFeeRepository<BitcoinChainTransactionFee<Token>> = resolve(tag: Token.coin),
        recorder: Recording = resolve(tag: "CrashlyticsRecorder")
    ) {
        self.app = app
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.feeRepository = feeRepository
        self.recorder = recorder
    }
}

// MARK: - OnChainTransactionEngine

extension BitcoinOnChainTransactionEngine: OnChainTransactionEngine {

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceCryptoAccount is BitcoinChainCryptoAccount)
        precondition(sourceCryptoAccount.asset == Token.coin.cryptoCurrency)
    }

    func start(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmation
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }

    func restart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        self.transactionTarget = transactionTarget
        return nativeUpdate(
            amount: pendingTransaction.amount,
            pendingTransaction: pendingTransaction
        )
        .asSingle()
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        walletCurrencyService.displayCurrency.eraseError()
            .zip(actionableBalance)
            .map { [predefinedAmount] fiatCurrency, availableBalance -> PendingTransaction in
                PendingTransaction(
                    amount: predefinedAmount ?? .zero(currency: Token.coin.cryptoCurrency),
                    available: availableBalance,
                    feeAmount: .zero(currency: Token.coin.cryptoCurrency),
                    feeForFullAvailable: .zero(currency: Token.coin.cryptoCurrency),
                    feeSelection: FeeSelection(
                        selectedLevel: .regular,
                        availableLevels: [.regular, .priority],
                        asset: Token.coin.cryptoCurrency.currencyType
                    ),
                    selectedFiatCurrency: fiatCurrency
                )
            }
            .asSingle()
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        fiatAmountAndFees(from: pendingTransaction)
            .zip(makeFeeSelectionOption(pendingTransaction: pendingTransaction))
            .map { [weak self] fiatAmountAndFees, feeSelectionOption -> [TransactionConfirmation] in
                guard let self else {
                    return []
                }
                return [
                    TransactionConfirmations.SendDestinationValue(value: pendingTransaction.amount),
                    TransactionConfirmations.Source(value: sourceAccount.label),
                    TransactionConfirmations.Destination(value: transactionTarget.label),
                    feeSelectionOption,
                    TransactionConfirmations.FeedTotal(
                        amount: pendingTransaction.amount,
                        amountInFiat: fiatAmountAndFees.amount,
                        fee: pendingTransaction.feeAmount,
                        feeInFiat: fiatAmountAndFees.fees
                    )
                ]
            }
            .map { pendingTransaction.update(confirmations: $0) }
            .asSingle()
    }

    func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        nativeUpdate(
            amount: amount,
            pendingTransaction: pendingTransaction
        )
        .asSingle()
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateOptions(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        nativeExecute(
            pendingTransaction: pendingTransaction
        )
    }
}

// MARK: - BitPayClientEngine

extension BitcoinOnChainTransactionEngine: BitPayClientEngine {

    func doPrepareBitPayTransaction(
        pendingTransaction: PendingTransaction
    ) -> Single<BitPayClientEngineTransaction> {
        nativeDoPrepareTransactionPublisher(
            pendingTransaction: pendingTransaction
        )
        .map { signedTransaction in
            BitPayClientEngineTransaction(
                encodedMsg: signedTransaction.encodedMsg,
                msgSize: signedTransaction.msgSize,
                txHash: signedTransaction.txHash
            )
        }
        .asSingle()
    }

    private func nativeDoPrepareTransactionPublisher(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<NativeSignedBitcoinTransaction, Error> {
        let engineState = pendingTransaction.engineState.value
        let btcState = engineState[.btc] as? BTCOnChainTxEngineState<Token>

        guard let state = btcState else {
            fatalError("Missing BTC state")
        }

        guard let transactionCandidate = state.transactionCandidate else {
            fatalError("The transaction should have already been built")
        }

        return nativeSignTransaction(
            candidate: transactionCandidate,
            signingService: nativeBitcoinEnvironment.signingService
        )
        .eraseToAnyPublisher()
    }

    func doOnBitPayTransactionSuccess(pendingTransaction: PendingTransaction) {
        // This matches Androids API though may not be necessary for iOS
    }

    func doOnBitPayTransactionFailed(pendingTransaction: PendingTransaction, error: Error) {
        // This matches Androids API though may not be necessary for iOS
        Logger.shared.error("BitPay transaction failed: \(error)")
    }
}

// MARK: - Helper variables and functions

extension BitcoinOnChainTransactionEngine {

    private var priorityFees: AnyPublisher<MoneyValue, Never> {
        feeRepository
            .fees
            .map(\.priority)
            .map(\.moneyValue)
            .eraseToAnyPublisher()
    }

    private var regularFees: AnyPublisher<MoneyValue, Never> {
        feeRepository
            .fees
            .map(\.regular)
            .map(\.moneyValue)
            .eraseToAnyPublisher()
    }

    /// Stream emits one MoneyValuePair, being base 1 major Token.coin, and quote the fiat price of it.
    private var sourceExchangeRatePair: AnyPublisher<MoneyValuePair, Error> {
        walletCurrencyService
            .displayCurrency
            .eraseError()
            .flatMap { [currencyConversionService, sourceCryptoAccount] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceCryptoAccount.currencyType, to: fiatCurrency.currencyType)
                    .map { quote in
                        MoneyValuePair(
                            base: .one(currency: sourceCryptoAccount.currencyType),
                            quote: quote
                        )
                    }
                    .eraseError()
            }
            .eraseToAnyPublisher()
    }

    /// Returns the sat/byte fee for the given PendingTransaction.feeLevel.
    private func fee(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<MoneyValue, Never> {
        switch pendingTransaction.feeLevel {
        case .priority:
            return priorityFees
        case .regular:
            return regularFees
        case .custom:
            return regularFees
        case .none:
            return regularFees
        }
    }

    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        guard transactionTarget != nil else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        guard sourceAccount != nil else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        return Completable.fromCallable { [pendingTransaction] in
            guard pendingTransaction.amount.isPositive else {
                throw TransactionValidationFailure(state: .belowMinimumLimit(pendingTransaction.minSpendable))
            }
            guard pendingTransaction.amount.minorAmount >= Token.coin.dust else {
                throw TransactionValidationFailure(state: .belowMinimumLimit(pendingTransaction.minSpendable))
            }
        }
    }

    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        actionableBalance.tryMap { [sourceAccount, transactionTarget] sourceBalance -> Void in
            guard (try? pendingTransaction.amount > pendingTransaction.feeAmount) == true else {
                throw TransactionValidationFailure(
                    state: .belowFees(pendingTransaction.feeAmount, sourceBalance)
                )
            }
            guard (try? pendingTransaction.amount <= pendingTransaction.maxSpendable) == true else {
                throw TransactionValidationFailure(
                    state: .insufficientFunds(
                        pendingTransaction.maxSpendable,
                        pendingTransaction.amount,
                        sourceAccount!.currencyType,
                        transactionTarget!.currencyType
                    )
                )
            }
        }
        .asCompletable()
    }

    private func validateOptions(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            // TODO: Handle custom fees
            guard !pendingTransaction.confirmations.contains(where: { $0.type == .largeTransactionWarning }) else {
                throw TransactionValidationFailure(state: .optionInvalid)
            }
        }
    }

    private func makeFeeSelectionOption(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<TransactionConfirmations.FeeSelection, Error> {
        getFeeState(pendingTransaction: pendingTransaction)
            .map { feeState -> TransactionConfirmations.FeeSelection in
                TransactionConfirmations.FeeSelection(
                    feeState: feeState,
                    selectedLevel: pendingTransaction.feeLevel,
                    fee: pendingTransaction.feeAmount
                )
            }
            .eraseToAnyPublisher()
    }

    /// Stream emits tuple with pendingt ransaction amount and fees in fiat.
    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> AnyPublisher<(amount: MoneyValue, fees: MoneyValue), Error> {
        let zero = CryptoValue.zero(currency: Token.coin.cryptoCurrency)
        let amount = pendingTransaction.amount.cryptoValue ?? zero
        let feeAmount = pendingTransaction.feeAmount.cryptoValue ?? zero

        return sourceExchangeRatePair
            .map(\.quote)
            .map { quote -> (MoneyValue, MoneyValue) in
                (amount.convert(using: quote), feeAmount.convert(using: quote))
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Native Methods

extension BitcoinOnChainTransactionEngine {

    private func nativeUpdate(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<PendingTransaction, Error> {

        guard sourceAccount != nil else {
            return .just(pendingTransaction)
        }
        guard let crypto = amount.cryptoValue else {
            preconditionFailure("We should always be passing in `CryptoCurrency` amounts")
        }
        guard crypto.currencyType == Token.coin.cryptoCurrency else {
            preconditionFailure("We should always be passing in BTC or BCH amounts here")
        }

        var pendingTransaction = pendingTransaction
        pendingTransaction.amount = amount

        let amountCryptoValue = amount.cryptoValue!
        let feeLevel = pendingTransaction.feeLevel.bitcoinChainFeeLevel
        let source = BitcoinChainAccount(
            index: Int32(bitcoinChainCryptoAccount.hdAccountIndex),
            coin: Token.coin
        )

        func fee(
            from pendingTx: PendingTransaction
        ) -> AnyPublisher<CryptoValue, Never> {
            fetchFee(
                for: pendingTransaction.feeLevel.bitcoinChainFeeLevel,
                feeRepository: feeRepository
            )
            .compactMap(\.cryptoValue)
            .eraseToAnyPublisher()
        }

        let environment = nativeBitcoinEnvironment

        let transactionContextProvider = getTransactionContextProvider(
            walletMnemonicProvider: environment.mnemonicProvider,
            fetchUnspentOutputsFor: environment.unspentOutputRepository.unspentOutputs(for:),
            fetchMultiAddressFor: environment.fetchMultiAddressFor
        )

        let createTransactionContextPublisher = getTransactionContext(
            for: source,
            transactionContextFor: transactionContextProvider
        )

        func state(for pendingTransaction: PendingTransaction) -> BTCOnChainTxEngineState<Token>? {
            pendingTransaction.engineState.value[.btc] as? BTCOnChainTxEngineState<Token>
        }

        func tansactionContextPublisher(
            for pendingTransaction: PendingTransaction
        ) -> AnyPublisher<NativeBitcoinTransactionContext, Error> {
            guard let state = state(for: pendingTransaction), let context = state.context else {
                return createTransactionContextPublisher
                    .flatMap { transactionContext
                        -> AnyPublisher<NativeBitcoinTransactionContext, Error> in
                        pendingTransaction.engineState.mutate {
                            $0[.btc] = BTCOnChainTxEngineState<Token>(
                                context: transactionContext
                            )
                        }
                        return .just(transactionContext)
                    }
                    .eraseToAnyPublisher()
            }
            return .just(context)
        }

        let feePerBytePublisher = fee(from: pendingTransaction)
            .setFailureType(to: Error.self)

        let transactionContextPublisher = tansactionContextPublisher(for: pendingTransaction)

        return Publishers.Zip3(targetAddress, transactionContextPublisher, feePerBytePublisher)
            .eraseError()
            .flatMap { [environment] targetAddress, transactionContext, feePerByte -> AnyPublisher
                <
                    (
                        NativeBitcoinTransactionCandidate,
                        PendingTransaction
                    ),
                    Error
                > in
                let destinationAddress: String = targetAddress.address
                let unspentOutputs = transactionContext.unspentOutputs
                let pendingTx = BitcoinChainPendingTransaction(
                    amount: amountCryptoValue,
                    destinationAddress: destinationAddress,
                    feeLevel: feeLevel,
                    unspentOutputs: unspentOutputs,
                    keyPairs: transactionContext.keyPairs
                )
                return nativeBuildTransaction(
                    sourceAccount: source,
                    pendingTransaction: pendingTx,
                    feePerByte: feePerByte,
                    transactionContext: transactionContext,
                    buildingService: environment.buildingService
                )
                .map { (transactionCandidate: NativeBitcoinTransactionCandidate) in
                    var state = pendingTransaction.engineState.value[.btc] as! BTCOnChainTxEngineState<Token>
                    state.add(transactionCandidate: transactionCandidate)
                    pendingTransaction.engineState.mutate {
                        $0[.btc] = state
                    }
                    return (transactionCandidate, pendingTransaction)
                }
                .eraseToAnyPublisher()
            }
            .map { candidate, pendingTransaction -> PendingTransaction in
                let amount = candidate.amount.moneyValue
                let fee = candidate.fees.moneyValue
                let max = candidate.maxValue
                let available = max.available
                let feeForFullAvailable = max.feeForMaxAvailable
                let pendingTx = pendingTransaction.update(
                    amount: amount,
                    available: available.moneyValue,
                    fee: fee,
                    feeForFullAvailable: feeForFullAvailable.moneyValue
                )
                return pendingTx
            }
            .eraseToAnyPublisher()
    }

    private func nativeExecute(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        nativeExecutePublisher(
            pendingTransaction: pendingTransaction
        )
        .map(\.transactionResult)
        .asSingle()
    }

    private func nativeExecutePublisher(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<TransactionOutcome, Error> {
        let engineState = pendingTransaction.engineState.value
        let btcState = engineState[.btc] as? BTCOnChainTxEngineState<Token>

        guard let state = btcState else {
            fatalError("Missing BTC state")
        }

        guard let transactionCandidate = state.transactionCandidate else {
            fatalError("The transaction should have already been built")
        }

        return nativeExecuteTransaction(
            candidate: transactionCandidate,
            environment: nativeBitcoinEnvironment
        )
    }
}

extension TransactionOutcome {

    var transactionResult: TransactionResult {
        switch self {
        case .signed(rawTx: let rawTx):
            return .signed(rawTx: rawTx)
        case .hashed(txHash: let txHash, amount: let amount):
            return .hashed(txHash: txHash, amount: amount?.moneyValue)
        }
    }
}

private func fetchFee(
    for feeLevel: BitcoinChainPendingTransaction.FeeLevel,
    feeRepository: AnyCryptoFeeRepository<BitcoinChainTransactionFee<some BitcoinChainToken>>
) -> AnyPublisher<MoneyValue, Never> {
    feeRepository
        .fees
        .map { fees -> CryptoValue in
            switch feeLevel {
            case .regular:
                return fees.regular
            case .priority:
                return fees.priority
            case .custom(let value):
                return value
            }
        }
        .map(\.moneyValue)
        .eraseToAnyPublisher()
}

extension FeatureTransactionDomain.FeeLevel {

    var bitcoinChainFeeLevel: BitcoinChainPendingTransaction.FeeLevel {
        switch self {
        case .regular:
            return .regular
        case .priority:
            return .priority
        case .none:
            return .regular
        case .custom:
            return .regular
        }
    }
}
