// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

final class BitcoinOnChainTransactionEngine<Token: BitcoinChainToken>: OnChainTransactionEngine, BitPayClientEngine {

    var sourceAccount: BlockchainAccount!
    var askForRefreshConfirmation: ((Bool) -> Completable)!
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
    
    let requireSecondPassword: Bool
    
    // MARK: - Private Properties
    
    private var feeService: AnyCryptoFeeService<BitcoinChainTransactionFee<Token>> {
        resolve(tag: Token.coin)
    }
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI
    private let bridge: BitcoinChainSendBridgeAPI
    private var target: BitcoinChainReceiveAddress<Token> {
        switch transactionTarget {
        case let target as BitPayInvoiceTarget:
            return .init(
                address: target.address,
                label: target.label,
                onTxCompleted: target.onTxCompleted
            )
        default:
            guard let receiveAddress = transactionTarget as? BitcoinChainReceiveAddress<Token> else {
                fatalError("Engine requires transactionTarget to be a BitcoinChainReceiveAddress")
            }
            return receiveAddress
        }
    }
    
    // MARK: - Init
    
    init(requireSecondPassword: Bool,
         priceService: PriceServiceAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         bridge: BitcoinChainSendBridgeAPI = resolve()) {
        self.requireSecondPassword = requireSecondPassword
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.bridge = bridge
    }
    
    // MARK: - OnChainTransactionEngine

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceCryptoAccount.asset == Token.coin.cryptoCurrency)
    }
    
    func start(sourceAccount: BlockchainAccount, transactionTarget: TransactionTarget, askForRefreshConfirmation: @escaping (Bool) -> Completable) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }
    
    func restart(transactionTarget: TransactionTarget, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultRestart(
            transactionTarget: transactionTarget,
            pendingTransaction: pendingTransaction
        )
    }
    
    func initializeTransaction() -> Single<PendingTransaction> {
        fiatCurrencyService
            .fiatCurrency
            .map { fiatCurrency -> PendingTransaction in
                .init(
                    amount: .zero(currency: Token.coin.cryptoCurrency),
                    available: .zero(currency: Token.coin.cryptoCurrency),
                    feeAmount: MoneyValue.zero(currency: Token.coin.cryptoCurrency),
                    feeForFullAvailable: MoneyValue.zero(currency: Token.coin.cryptoCurrency),
                    feeSelection: .init(
                        selectedLevel: .regular,
                        availableLevels: [.regular, .priority],
                        asset: Token.coin.cryptoCurrency.currency
                    ),
                    selectedFiatCurrency: fiatCurrency
                )
            }
    }
    
    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single
            .zip(
                fiatAmountAndFees(from: pendingTransaction),
                makeFeeSelectionOption(pendingTransaction: pendingTransaction)
            )
            .map { (fiatAmountAndFees, feeSelectionOption) -> (amountInFiat: MoneyValue, feesInFiat: MoneyValue, feeSelectionOption: TransactionConfirmation.Model.FeeSelection) in
                let (amountInFiat, feesInFiat) = fiatAmountAndFees
                return (amountInFiat.moneyValue, feesInFiat.moneyValue, feeSelectionOption)
            }
            .map(weak: self) { (self, payload) -> [TransactionConfirmation] in
                [
                    .sendDestinationValue(.init(value: pendingTransaction.amount)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .feeSelection(payload.feeSelectionOption),
                    .feedTotal(
                        .init(
                            amount: pendingTransaction.amount,
                            amountInFiat: payload.amountInFiat,
                            fee: pendingTransaction.feeAmount,
                            feeInFiat: payload.feesInFiat
                        )
                    )
                ]
            }
            // TODO: Apply large transaction warning if necessary
            .map { pendingTransaction.update(confirmations: $0) }
    }
    
    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceAccount != nil else {
            return .just(pendingTransaction)
        }
        guard let crypto = amount.cryptoValue else {
            preconditionFailure("We should always be passing in `CryptoCurrency` amounts")
        }
        guard crypto.currencyType == Token.coin.cryptoCurrency else {
            preconditionFailure("We should always be passing in BTC amounts's here")
        }
        // For BTC, JS does some internal validation of the proposal. We need to do this in order
        // to run coin selection and get the fee. However, if we pass in a zero value, this is technically
        // incorrect in JS land.
        return fee(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, fees) -> Single<BitcoinChainTransactionProposal<Token>> in
                self.bridge
                    .buildProposal(
                        with: self.target,
                        amount: amount,
                        fees: fees,
                        source: self.sourceCryptoAccount
                    )
            }
            .flatMap(weak: self) { (self, proposal) -> Single<BitcoinChainTransactionCandidate<Token>> in
                self.bridge
                    .buildCandidate(with: proposal)
                    .catchError { error -> Single<BitcoinChainTransactionCandidate<Token>> in
                        let candidate: BitcoinChainTransactionCandidate<Token>
                        switch error {
                        case let BitcoinChainTransactionError.noUnspentOutputs(finalFee, sweepAmount, sweepFee),
                             let BitcoinChainTransactionError.belowDustThreshold(finalFee, sweepAmount, sweepFee),
                             let BitcoinChainTransactionError.feeTooLow(finalFee, sweepAmount, sweepFee),
                             let BitcoinChainTransactionError.unknown(finalFee, sweepAmount, sweepFee):
                            candidate = .init(proposal: proposal, fees: finalFee, sweepAmount: sweepAmount, sweepFee: sweepFee)
                        default:
                            candidate = .init(proposal: proposal,
                                              fees: MoneyValue.zero(currency: Token.coin.cryptoCurrency),
                                              sweepAmount: MoneyValue.zero(currency: Token.coin.cryptoCurrency),
                                              sweepFee: MoneyValue.zero(currency: Token.coin.cryptoCurrency))
                        }
                        return .just(candidate)
                    }
            }
            .map { (candidate) -> PendingTransaction in
                pendingTransaction.update(
                    amount: amount,
                    available: candidate.sweepAmount,
                    fee: candidate.fees,
                    feeForFullAvailable: candidate.sweepFee
                )
            }
    }

    /// Returns the sat/byte fee for the given PendingTransaction.feeLevel.
    private func fee(pendingTransaction: PendingTransaction) -> Single<MoneyValue> {
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

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }
    
    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        // TODO: Is validating the address necessary?
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateOptions(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }
    
    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        fee(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, fees) -> Single<BitcoinChainTransactionProposal<Token>> in
                self.bridge.buildProposal(
                    with: self.target,
                    amount: pendingTransaction.amount,
                    fees: fees,
                    source: self.sourceCryptoAccount
                )
            }
            .flatMap(weak: self) { (self, proposal) -> Single<BitcoinChainTransactionCandidate<Token>> in
                self.bridge.buildCandidate(with: proposal)
            }
            .flatMap(weak: self) { (self, _) -> Single<String> in
                self.bridge.send(coin: Token.coin, with: secondPassword)
            }
            .map { TransactionResult.hashed(txHash: $0, amount: pendingTransaction.amount) }
    }
    
    // MARK: - BitPayClientEngine
    
    func doPrepareTransaction(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<EngineTransaction> {
        bridge.sign(with: secondPassword)
    }
    
    func doOnTransactionSuccess(pendingTransaction: PendingTransaction) {
        // TODO: This matches Androids API
        // though may not be necessary for iOS
    }
    
    func doOnTransactionFailed(pendingTransaction: PendingTransaction, error: Error) {
        // TODO: This matches Androids API
        // though may not be necessary for iOS
        Logger.shared.error("BitPay transaction failed: \(error)")
    }
    
    // MARK: - Private Functions
    
    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        guard transactionTarget != nil else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        guard sourceAccount != nil else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        return Completable.fromCallable { [pendingTransaction] in
            guard pendingTransaction.amount.amount > 0 else {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
            guard pendingTransaction.amount.amount <= Token.coin.maximumSupply else {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
            guard pendingTransaction.amount.amount >= Token.coin.dust else {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
        }
    }
    
    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            guard (try? pendingTransaction.amount <= pendingTransaction.maxSpendable) == true else {
                throw TransactionValidationFailure(state: .insufficientFunds)
            }
            guard try pendingTransaction.available >= pendingTransaction.amount else {
                throw TransactionValidationFailure(state: .insufficientFunds)
            }
        }
    }
    
    private func validateOptions(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            // TODO: Handle custom fees
            guard !pendingTransaction.confirmations.contains(where: { $0.type == .largeTransactionWarning }) else {
                throw TransactionValidationFailure(state: .optionInvalid)
            }
        }
    }
    
    private func makeFeeSelectionOption(pendingTransaction: PendingTransaction) -> Single<TransactionConfirmation.Model.FeeSelection> {
        Single
            .just(pendingTransaction)
            .map(weak: self) { (self, pendingTransaction) -> FeeState in
                try self.getFeeState(pendingTransaction: pendingTransaction)
            }
            .map { (feeState) -> TransactionConfirmation.Model.FeeSelection in
                TransactionConfirmation.Model.FeeSelection(
                    feeState: feeState,
                    selectedLevel: pendingTransaction.feeLevel,
                    fee: pendingTransaction.feeAmount
                )
            }
    }
    
    private func fiatAmountAndFees(from pendingTransaction: PendingTransaction) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: Token.coin.cryptoCurrency)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: Token.coin.cryptoCurrency))
        )
        .map({ (quote: ($0.0.quote.fiatValue ?? .zero(currency: .USD)), amount: $0.1, fees: $0.2) })
        .map { (quote: (FiatValue), amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convertToFiatValue(exchangeRate: quote)
            let fiatFees = fees.convertToFiatValue(exchangeRate: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }
    
    private var priorityFees: Single<MoneyValue> {
        feeService
            .fees
            .map(\.priority)
            .map(\.moneyValue)
    }
    
    private var regularFees: Single<MoneyValue> {
        feeService
            .fees
            .map(\.regular)
            .map(\.moneyValue)
    }
    
    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(for: self.sourceCryptoAccount.currencyType, in: fiatCurrency)
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceCryptoAccount.currencyType), quote: $0) }
            }
    }
}
