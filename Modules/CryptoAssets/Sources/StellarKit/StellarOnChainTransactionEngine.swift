// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarOnChainTransactionEngine: OnChainTransactionEngine {

    // MARK: - Properties

    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    var transactionDispatcher: StellarTransactionDispatcherAPI
    var feeRepository: AnyCryptoFeeRepository<StellarTransactionFee>

    // MARK: - Private properties

    private var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        switch transactionTarget {
        case let target as ReceiveAddress:
            return .just(target)
        case let target as CryptoAccount:
            return target.receiveAddress
        default:
            fatalError("Engine requires transactionTarget to be a ReceiveAddress or CryptoAccount.")
        }
    }

    private var userFiatCurrency: Single<FiatCurrency> {
        walletCurrencyService.displayCurrency
            .asSingle()
    }

    private var sourceExchangeRatePair: AnyPublisher<MoneyValuePair, Error> {
        walletCurrencyService.displayCurrency
            .eraseError()
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .eraseError()
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
                    .prefix(1)
            }
            .eraseToAnyPublisher()
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

    func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<PendingTransaction, Error> {
        sourceExchangeRatePair
            .zip(receiveAddress)
            .map { [sourceAccount] exchangeRate, receiveAddress -> [TransactionConfirmation] in
                let from = TransactionConfirmations.Source(value: sourceAccount?.label ?? "")
                let to = TransactionConfirmations.Destination(value: receiveAddress.label)
                let feesFiat = pendingTransaction.feeAmount.convert(using: exchangeRate.quote)
                let fee = Self.makeFeeSelectionOption(
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
                let memo = TransactionConfirmations.Memo(textMemo: receiveAddress.memo)
                let confirmations: [TransactionConfirmation] = [
                    sendDestination,
                    from,
                    to,
                    fee,
                    feedTotal,
                    memo
                ]
                return confirmations
            }
            .map { confirmations in
                pendingTransaction.update(confirmations: confirmations)
            }
            .eraseToAnyPublisher()
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            receiveAddress.asSingle(),
            userFiatCurrency,
            actionableBalance
        )
        .map { _, fiatCurrency, availableBalance -> PendingTransaction in
            let zeroStellar: MoneyValue = .zero(currency: .stellar)
            let transaction = PendingTransaction(
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
                let available = try (total < zeroStellar) ? zeroStellar : total
                var pendingTransaction = pendingTransaction
                pendingTransaction.amount = amount
                pendingTransaction.feeForFullAvailable = fees.moneyValue
                pendingTransaction.feeAmount = fees.moneyValue
                pendingTransaction.available = available.moneyValue
                return pendingTransaction
            }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultValidateAmount(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateTargetAddress()
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateDryRun(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        createTransaction(pendingTransaction: pendingTransaction)
            .asSingle()
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
                if try (fee.moneyValue + pendingTransaction.amount) > balance {
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

    private func createTransaction(pendingTransaction: PendingTransaction) -> AnyPublisher<SendDetails, Error> {
        let label = sourceAccount.label
        return sourceAccount.receiveAddress
            .zip(receiveAddress)
            .map { fromAddress, receiveAddress -> SendDetails in
                SendDetails(
                    fromAddress: fromAddress.address,
                    fromLabel: label,
                    toAddress: receiveAddress.address,
                    toLabel: "",
                    value: pendingTransaction.amount.cryptoValue!,
                    fee: pendingTransaction.feeAmount.cryptoValue!,
                    memo: receiveAddress.memo
                )
            }
            .eraseToAnyPublisher()
    }

    private func validateDryRun(pendingTransaction: PendingTransaction) -> Completable {
        createTransaction(pendingTransaction: pendingTransaction)
            .asSingle()
            .flatMapCompletable(weak: self) { (self, sendDetails) -> Completable in
                self.transactionDispatcher.dryRunTransaction(sendDetails: sendDetails)
            }
            .mapErrorToTransactionValidationFailure()
    }

    private func validateTargetAddress() -> Completable {
        receiveAddress
            .tryMap { [transactionDispatcher] receiveAddress in
                guard transactionDispatcher.isAddressValid(address: receiveAddress.address) else {
                    throw TransactionValidationFailure(state: .invalidAddress)
                }
            }
            .asCompletable()
    }

    private static func makeFeeSelectionOption(
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
            case let error as UX.Error:
                throw TransactionValidationFailure(state: .ux(error))
            default:
                throw TransactionValidationFailure(state: .unknownError)
            }
        }
    }
}
