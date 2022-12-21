// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarOnChainTransactionEngine: OnChainTransactionEngine {

    // MARK: - Properties

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

    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    var transactionDispatcher: StellarTransactionDispatcherAPI
    var feeRepository: AnyCryptoFeeRepository<StellarTransactionFee>

    // MARK: - Private properties

    private var receiveAddress: Single<ReceiveAddress> {
        switch transactionTarget {
        case let target as ReceiveAddress:
            return .just(target)
        case let target as CryptoAccount:
            return target.receiveAddress.asSingle()
        default:
            fatalError("Engine requires transactionTarget to be a ReceiveAddress or CryptoAccount.")
        }
    }

    private var userFiatCurrency: Single<FiatCurrency> {
        walletCurrencyService.displayCurrency
            .asSingle()
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        userFiatCurrency
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency -> Single<MoneyValuePair> in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .asSingle()
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
    }

    private var isMemoRequired: Single<Bool> {
        receiveAddress
            .flatMap { [transactionDispatcher] receiveAddress in
                transactionDispatcher.isExchangeAddresses(
                    address: receiveAddress.address
                )
            }
    }

    private var absoluteFee: Single<CryptoValue> {
        feeRepository.fees
            .map(\.regular)
            .asSingle()
    }

    private var actionableBalance: Single<MoneyValue> {
        sourceAccount
            .actionableBalance
            .asSingle()
    }

    // MARK: - Init

    init(
        walletCurrencyService: FiatCurrencyServiceAPI,
        currencyConversionService: CurrencyConversionServiceAPI,
        feeRepository: AnyCryptoFeeRepository<StellarTransactionFee>,
        transactionDispatcher: StellarTransactionDispatcherAPI
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.transactionDispatcher = transactionDispatcher
        self.feeRepository = feeRepository
    }

    // MARK: - Internal Methods

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceCryptoCurrency == .stellar)
    }

    func restart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        defaultRestart(
            transactionTarget: transactionTarget,
            pendingTransaction: pendingTransaction
        )
        .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
            Single.zip(self.receiveAddress, self.isMemoRequired)
                .map { receiveAddress, isMemoRequired -> PendingTransaction in
                    guard let stellarReceive = receiveAddress as? StellarReceiveAddress else {
                        return pendingTransaction
                    }
                    var pendingTransaction = pendingTransaction
                    let memoModel = TransactionConfirmations.Memo(
                        textMemo: stellarReceive.memo,
                        required: isMemoRequired
                    )
                    pendingTransaction.setMemo(memo: memoModel)
                    return pendingTransaction
                }
        }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        sourceExchangeRatePair
            .map(weak: self) { (self, exchangeRate) -> [TransactionConfirmation] in
                let from = TransactionConfirmations.Source(value: self.sourceAccount.label)
                let to = TransactionConfirmations.Destination(value: self.transactionTarget.label)
                let feesFiat = pendingTransaction.feeAmount.convert(using: exchangeRate.quote)
                let fee = self.makeFeeSelectionOption(
                    pendingTransaction: pendingTransaction,
                    feesFiat: feesFiat
                )
                let feedTotal = TransactionConfirmations.FeedTotal(
                    amount: pendingTransaction.amount,
                    amountInFiat: pendingTransaction.amount.convert(using: exchangeRate.quote),
                    fee: pendingTransaction.feeAmount,
                    feeInFiat: feesFiat
                )
                let sendDestination = TransactionConfirmations.SendDestinationValue(
                    value: pendingTransaction.amount
                )
                return [
                    sendDestination,
                    from,
                    to,
                    fee,
                    feedTotal,
                    pendingTransaction.memo
                ]
            }
            .map { confirmations in
                pendingTransaction.update(confirmations: confirmations)
            }
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            receiveAddress,
            userFiatCurrency,
            isMemoRequired,
            actionableBalance
        )
        .map { receiveAddress, fiatCurrency, isMemoRequired, availableBalance -> PendingTransaction in
            var memo: String?
            if let stellarReceive = receiveAddress as? StellarReceiveAddress {
                memo = stellarReceive.memo
            }
            let memoModel = TransactionConfirmations.Memo(
                textMemo: memo,
                required: isMemoRequired
            )
            let zeroStellar: MoneyValue = .zero(currency: .stellar)
            var transaction = PendingTransaction(
                amount: zeroStellar,
                available: availableBalance,
                feeAmount: zeroStellar,
                feeForFullAvailable: zeroStellar,
                feeSelection: .init(
                    selectedLevel: .regular,
                    availableLevels: [.regular],
                    asset: .crypto(.stellar)
                ),
                selectedFiatCurrency: fiatCurrency,
                limits: nil
            )
            transaction.setMemo(memo: memoModel)
            return transaction
        }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        precondition(amount.currency == .crypto(.stellar))
        let actionableBalance = actionableBalance.map(\.cryptoValue)
        return Single
            .zip(actionableBalance, absoluteFee)
            .map { actionableBalance, fees -> PendingTransaction in
                guard let actionableBalance else {
                    throw PlatformKitError.illegalStateException(message: "actionableBalance not CryptoValue")
                }
                let zeroStellar: CryptoValue = .zero(currency: .stellar)
                let total = try actionableBalance - fees
                let available = (try total < zeroStellar) ? zeroStellar : total
                var pendingTransaction = pendingTransaction
                pendingTransaction.amount = amount
                pendingTransaction.feeForFullAvailable = fees.moneyValue
                pendingTransaction.feeAmount = fees.moneyValue
                pendingTransaction.available = available.moneyValue
                return pendingTransaction
            }
    }

    func doOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction> {
        defaultDoOptionUpdateRequest(pendingTransaction: pendingTransaction, newConfirmation: newConfirmation)
            .map { pendingTransaction -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                if let memo = newConfirmation as? TransactionConfirmations.Memo {
                    pendingTransaction.setMemo(memo: memo)
                }
                return pendingTransaction
            }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateTargetAddress()
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateOptions(pendingTransaction: pendingTransaction))
            .andThen(validateDryRun(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        createTransaction(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, sendDetails) -> Single<SendConfirmationDetails> in
                self.transactionDispatcher.sendFunds(sendDetails: sendDetails, secondPassword: nil)
            }
            .map { result in
                TransactionResult.hashed(txHash: result.transactionHash, amount: pendingTransaction.amount)
            }
    }
}

extension StellarOnChainTransactionEngine {

    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        Single.zip(actionableBalance, absoluteFee)
            .map { [sourceAccount, transactionTarget] balance, fee -> Void in
                if try (try fee.moneyValue + pendingTransaction.amount) > balance {
                    throw TransactionValidationFailure(
                        state: .insufficientFunds(
                            balance,
                            pendingTransaction.amount,
                            sourceAccount!.currencyType,
                            transactionTarget!.currencyType
                        )
                    )
                }
            }
            .asCompletable()
    }

    private func createTransaction(pendingTransaction: PendingTransaction) -> Single<SendDetails> {
        let label = sourceAccount.label
        return Single
            .zip(
                sourceAccount.receiveAddress.asSingle(),
                receiveAddress
            )
            .map { fromAddress, receiveAddress -> SendDetails in
                SendDetails(
                    fromAddress: fromAddress.address,
                    fromLabel: label,
                    toAddress: receiveAddress.address,
                    toLabel: "",
                    value: pendingTransaction.amount.cryptoValue!,
                    fee: pendingTransaction.feeAmount.cryptoValue!,
                    memo: pendingTransaction.memo.stellarMemo
                )
            }
    }

    private func isMemoValid(memo: TransactionConfirmations.Memo?) -> Single<Bool> {
        func validText(memo: TransactionConfirmations.Memo) -> Bool {
            guard case .text(let text) = memo.value else {
                return false
            }
            return 1...28 ~= text.count
        }
        func validIdentifier(memo: TransactionConfirmations.Memo) -> Bool {
            guard case .identifier = memo.value else {
                return false
            }
            return true
        }
        return isMemoRequired
            .map { isMemoRequired -> Bool in
                guard isMemoRequired else {
                    return true
                }
                guard let memo else {
                    return false
                }
                return validText(memo: memo) || validIdentifier(memo: memo)
            }
    }

    private func validateDryRun(pendingTransaction: PendingTransaction) -> Completable {
        createTransaction(pendingTransaction: pendingTransaction)
            .flatMapCompletable(weak: self) { (self, sendDetails) -> Completable in
                self.transactionDispatcher.dryRunTransaction(sendDetails: sendDetails)
            }
            .mapErrorToTransactionValidationFailure()
    }

    private func validateOptions(pendingTransaction: PendingTransaction) -> Completable {
        isMemoValid(memo: pendingTransaction.memo)
            .map { isMemoValid -> Void in
                guard isMemoValid else {
                    throw TransactionValidationFailure(state: .optionInvalid)
                }
            }
            .asCompletable()
    }

    private func validateTargetAddress() -> Completable {
        receiveAddress
            .map { [transactionDispatcher] receiveAddress in
                guard transactionDispatcher.isAddressValid(address: receiveAddress.address) else {
                    throw TransactionValidationFailure(state: .invalidAddress)
                }
            }
            .asCompletable()
    }

    private func makeFeeSelectionOption(
        pendingTransaction: PendingTransaction,
        feesFiat: MoneyValue
    ) -> TransactionConfirmations.FeeSelection {
        TransactionConfirmations.FeeSelection(
            feeState: .valid(absoluteFee: pendingTransaction.feeAmount),
            selectedLevel: pendingTransaction.feeLevel,
            fee: pendingTransaction.feeAmount
        )
    }
}

extension PendingTransaction {

    fileprivate var memo: TransactionConfirmations.Memo {
        engineState.value[.memo] as! TransactionConfirmations.Memo
    }

    fileprivate mutating func setMemo(memo: TransactionConfirmations.Memo) {
        engineState.mutate { $0[.memo] = memo }
    }
}

extension TransactionConfirmations.Memo {

    fileprivate var stellarMemo: StellarMemo? {
        switch value {
        case .none:
            return nil
        case .text(let text):
            return text.isEmpty ? nil : StellarMemo.text(text)
        case .identifier(let identifier):
            return StellarMemo.id(UInt64(identifier))
        }
    }
}

extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {

    fileprivate func mapErrorToTransactionValidationFailure() -> Completable {
        `catch` { error -> Completable in
            switch error {
            case SendFailureReason.unknown:
                throw TransactionValidationFailure(state: .unknownError)
            case SendFailureReason.belowMinimumSend(let minimum):
                throw TransactionValidationFailure(state: .belowMinimumLimit(minimum))
            case SendFailureReason.belowMinimumSendNewAccount(let minimum):
                throw TransactionValidationFailure(state: .belowMinimumLimit(minimum))
            case SendFailureReason.insufficientFunds(let balance, let desiredAmount):
                throw TransactionValidationFailure(
                    state: .insufficientFunds(
                        balance,
                        desiredAmount,
                        balance.currencyType,
                        balance.currencyType
                    )
                )
            case SendFailureReason.badDestinationAccountID:
                throw TransactionValidationFailure(state: .invalidAddress)
            default:
                throw TransactionValidationFailure(state: .unknownError)
            }
        }
    }
}
