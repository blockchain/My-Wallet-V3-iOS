// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Coincore
import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import RxSwift
import stellarsdk
import ToolKit

public enum StellarKitError: Error {
    case illegalArgument
    case illegalStateException(message: String)
}

final class StellarOnChainTransactionEngine: OnChainTransactionEngine {

    // MARK: - Properties

    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let transactionDispatcher: StellarTransactionDispatcherAPI
    let feeRepository: FeesRepositoryAPI
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    // MARK: - Private properties

    private var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        switch transactionTarget {
        case let target as ReceiveAddress:
            .just(target)
        case let target as CryptoAccount:
            target.receiveAddress
        default:
            fatalError("Engine requires transactionTarget to be a ReceiveAddress or CryptoAccount.")
        }
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

    private var absoluteFee: AnyPublisher<CryptoValue, Never>  {
        feeRepository.fees.map(\.regular).eraseToAnyPublisher()
    }

    private var actionableBalance: AnyPublisher<MoneyValue, Error> {
        sourceAccount.actionableBalance
    }

    // MARK: - Init

    init(
        walletCurrencyService: FiatCurrencyServiceAPI,
        currencyConversionService: CurrencyConversionServiceAPI,
        feeRepository: FeesRepositoryAPI,
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
        walletCurrencyService.displayCurrency.eraseError()
            .zip(actionableBalance)
            .map { fiatCurrency, availableBalance -> PendingTransaction in
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
            .asSingle()
    }
    
    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        precondition(amount.currency == .crypto(.stellar))
        return actionableBalance.map(\.cryptoValue)
            .zip(absoluteFee.eraseError())
            .tryMap { actionableBalance, fees -> PendingTransaction in
                guard let actionableBalance else {
                    throw StellarKitError.illegalStateException(message: "actionableBalance not CryptoValue")
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
            .asSingle()
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard let sourceAccount else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        return defaultValidateAmount(
            pendingTransaction: pendingTransaction,
            sourceAccountBalance: { sourceAccount.actionableBalance }
        ).asSingle()
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateTargetAddress()
            .flatMap { self.validateSufficientFunds(pendingTransaction: pendingTransaction) }
            .flatMap { self.validateSufficientFunds(pendingTransaction: pendingTransaction) }
            .flatMap { self.validateDryRun(pendingTransaction: pendingTransaction) }
            .updateTxValidity(pendingTransaction: pendingTransaction)
            .asSingle()
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        createTransaction(pendingTransaction: pendingTransaction)
            .flatMap { [transactionDispatcher] sendDetails -> AnyPublisher<SendConfirmationDetails, Error> in
                transactionDispatcher.sendFunds(sendDetails: sendDetails)
            }
            .map { result in
                TransactionResult.hashed(txHash: result.transactionHash, amount: pendingTransaction.amount)
            }
            .asSingle()
    }
}

extension StellarOnChainTransactionEngine {

    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> AnyPublisher<Void, Error> {
        actionableBalance.zip(absoluteFee.eraseError())
            .tryMap { [sourceAccount, transactionTarget] balance, fee in
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
            .eraseToAnyPublisher()
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

    private func validateDryRun(pendingTransaction: PendingTransaction) -> AnyPublisher<Void, Error> {
        createTransaction(pendingTransaction: pendingTransaction)
            .flatMap { [transactionDispatcher] sendDetails in
                transactionDispatcher.dryRunTransaction(sendDetails: sendDetails)
            }
            .mapErrorToTransactionValidationFailure()
    }

    private func validateTargetAddress() -> AnyPublisher<Void, Error> {
        receiveAddress
            .tryMap { [transactionDispatcher] receiveAddress in
                guard transactionDispatcher.isAddressValid(address: receiveAddress.address) else {
                    throw TransactionValidationFailure(state: .invalidAddress)
                }
            }
            .eraseToAnyPublisher()
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

extension Publisher where Failure == Error {

    fileprivate func mapErrorToTransactionValidationFailure() -> AnyPublisher<Output, Error> {
        mapError { error in
            let state: TransactionValidationState = switch error {
            case SendFailureReason.unknown: .unknownError
            case SendFailureReason.belowMinimumSend(let minimum): .belowMinimumLimit(minimum)
            case SendFailureReason.belowMinimumSendNewAccount(let minimum):  .belowMinimumLimit(minimum)
            case SendFailureReason.insufficientFunds(let balance, let desiredAmount):
                    .insufficientFunds(
                        balance,
                        desiredAmount,
                        balance.currencyType,
                        balance.currencyType
                    )
            case SendFailureReason.badDestinationAccountID:  .invalidAddress
            case let error as UX.Error: .ux(error)
            default: .unknownError
            }
            return TransactionValidationFailure(state: state)
        }
        .eraseToAnyPublisher()
    }
}
