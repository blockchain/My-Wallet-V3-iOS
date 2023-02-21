// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

/// Convert amounts for comparison from fiat to crypto or vice versa, but never crypto -> crypto as this is not fully supported yet.
public struct TransactionExchangeRates: Equatable, CustomStringConvertible {

    /// The conversion rate from the user-entered `PendingTransaction`'s `amount` (in the Enter Amount Screen) to the transaction's `sourceAccount`.
    ///
    /// This is used to normalize the entered `amount` and compare it with the transaction's `limits` (including the available balance for the transaction).
    /// This is the case when the entered amount's input currency doesn't match the source's currency.
    /// e.g. for Buy the source is fiat but the user can enter an amount in crypto; for Send or Swap, the source is crypto but the user can enter the amount in fiat.
    public let amountToSourceRate: MoneyValue

    /// The conversion rate from the `PendingTransaction`'s `fee` to the transaction's `sourceAccount`.
    ///
    /// This rate is used to convert and subtract the `PendingTransaction`'s on-chain `fee` with the source's `balance` to calculate the available balance
    /// for on-chain transactions like Send or Non-Custodial Swap.
    ///
    /// The available balance is also used to validate the transaction by comparing it to the applicable `limit`s.
    public let onChainFeeToSourceRate: MoneyValue

    /// The conversion rate from the wallet's `tradingCurrency` to the `PendingTransaction`'s `sourceAccount`.
    ///
    /// Used to normalize the `PendingTransaction`'s `limits` to compare them with the `sourceAccount`'s available balance and with the
    /// user-entered `amount` (in the Enter Amount Screen). This is done to validate the transaction.
    ///
    /// - NOTE: Make sure `TradingLimits` are fetched using the wallet's trading currency!
    public let fiatTradingCurrencyToSourceRate: MoneyValue

    /// The conversion rate from the `PendingTransaction`'s `sourceAccount` to the wallet's `tradingCurrency`.
    ///
    /// Used to convert the source (if not in fiat already) to display prices **only**!
    public let sourceToFiatTradingCurrencyRate: MoneyValue

    /// The conversion rate from the `PendingTransaction`'s `targetAccount` to the wallet's `tradingCurrency`.
    ///
    /// Used to convert the source (if not in fiat already) to display prices **only**!
    public let destinationToFiatTradingCurrencyRate: MoneyValue

    /// The conversion rate from the `PendingTransaction`'s `sourceAccount` to the transaction's `targetAccount`.
    ///
    /// Used to convert the source (if not in fiat already) to display prices **only**!
    public let sourceToDestinationTradingCurrencyRate: MoneyValue
}

extension TransactionExchangeRates {

    public var description: String {
        """
        \n
        Amount to Source Rate: \(amountToSourceRate.displayString)
        On Chain Fee to Source Rate: \(onChainFeeToSourceRate.displayString)
        Fiat Trading Currency to Source Rate: \(fiatTradingCurrencyToSourceRate.displayString)
        Source to Fiat Trading Currency Rate: \(sourceToFiatTradingCurrencyRate.displayString)
        Destination to Fiat Rate: \(destinationToFiatTradingCurrencyRate.displayString)
        Source to Destination Trading Currency Rate: \(sourceToDestinationTradingCurrencyRate.displayString)
        \n
        """
    }
}

public protocol TransactionOrder {
    var identifier: String { get }
}

public protocol TransactionEngine: AnyObject {

    typealias AskForRefreshConfirmation = (_ revalidate: Bool) -> Observable<Void>

    /// Used for fetching the wallet's default currency
    var walletCurrencyService: FiatCurrencyServiceAPI { get }
    /// Used to convert amounts in different currencies
    var currencyConversionService: CurrencyConversionServiceAPI { get }

    /// askForRefreshConfirmation: Must be set by TransactionProcessor
    var askForRefreshConfirmation: AskForRefreshConfirmation! { get set }

    /// The account the user is transacting from
    var sourceAccount: BlockchainAccount! { get set }
    var transactionTarget: TransactionTarget! { get set }

    var canTransactFiat: Bool { get }

    /// The implementation is defaulted to use the `currencyConversionService` instance required by the protocol to fetch the conversion rate.
    /// The default implementation takes care of any edge cases around doing so, such as crypto -> crypto rates fetching which may not be supported directly.
    func amountToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError>

    /// The implementation is defaulted to use the `currencyConversionService` instance required by the protocol to fetch the conversion rate.
    /// The default implementation takes care of any edge cases around doing so, such as crypto -> crypto rates fetching which may not be supported directly.
    func onChainFeeToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError>

    /// The implementation is defaulted to use the `currencyConversionService` instance required by the protocol to fetch the conversion rate.
    /// The default implementation takes care of any edge cases around doing so, such as crypto -> crypto rates fetching which may not be supported directly.
    func fiatTradingCurrencyToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError>

    /// The implementation is defaulted to use the `currencyConversionService` instance required by the protocol to fetch the conversion rate.
    /// The default implementation takes care of any edge cases around doing so, such as crypto -> crypto rates fetching which may not be supported directly.
    func sourceToFiatTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError>

    /// The implementation is defaulted to use the `currencyConversionService` instance required by the protocol to fetch the conversion rate.
    /// The default implementation takes care of any edge cases around doing so, such as crypto -> crypto rates fetching which may not be supported directly.
    func destinationToFiatTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError>

    /// The implementation is defaulted to use the `currencyConversionService` instance required by the protocol to fetch the conversion rate.
    /// The default implementation takes care of any edge cases around doing so, such as crypto -> crypto rates fetching which may not be supported directly.
    func sourceToDestinationTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError>

    func assertInputsValid()
    func start(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmation
    )
    func stop(pendingTransaction: PendingTransaction)
    func restart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction>

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Implementation interface:
    /// Call this first to initialise the processor. Construct and initialise a pendingTx object.
    func initializeTransaction() -> Single<PendingTransaction>

    /// Update the transaction with a new amount. This method should check balances, calculate fees and
    /// Return a new PendingTx with the state updated for the UI to update. The pending Tx will
    /// be passed to validate after this call.
    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Process any `TransactionConfirmation` updates, if required. The default just replaces the option and returns
    /// the updated pendingTx. Subclasses may want to, eg, update amounts on fee changes etc
    func doOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction>

    /// Check the tx is complete, well formed and possible. If it is, set pendingTx to CAN_EXECUTE
    /// Else set it to the appropriate error, and then return the updated PendingTx
    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Check the tx is complete, well formed and possible. If it is, set pendingTx to CAN_EXECUTE
    /// Else set it to the appropriate error, and then return the updated PendingTx
    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Create a `TransactionOrder` for the pending transaction. Not all transaction types require an order. Return a `nil` order if that's the case.
    /// - Parameter pendingTransaction: The pending transaction so far.
    func createOrder(pendingTransaction: PendingTransaction) -> Single<TransactionOrder?>

    /// If a `TransactionOrder` was created, the user can cancel it. When an order needs to be cancelled, this method gets called.
    /// - Parameter identifier: The identifier of the order to be cancelled.
    func cancelOrder(with identifier: String) -> Single<Void>

    /// Execute the transaction, it will have been validated before this is called, so the expectation is that it will succeed.
    /// - Note:This method should be implemented by `TransactionEngine`s that don't require the creation of an order.
    /// - Parameters:
    ///   - pendingTransaction: The pending transaction so far.
    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult>

    /// Execute the transaction, it will have been validated before this is called, so the expectation is that it will succeed.
    /// - Note: This method is defaulted to call `execute(pendingTransaction:)`.
    /// - Parameters:
    ///   - pendingTransaction: The pending transaction so far
    ///   - pendingOrder: The pending order if one was created by `createOrder`.
    func execute(
        pendingTransaction: PendingTransaction,
        pendingOrder: TransactionOrder?
    ) -> Single<TransactionResult>

    /// Action to be executed once the transaction has been executed, it will have been validated before this is called, so the expectation
    /// is that it will succeed.
    func doPostExecute(transactionResult: TransactionResult) -> Completable

    /// Action to be executed when confirmations have been built and we want to start checking for updates on them
    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>

    /// Update the selected fee level of this Tx.
    /// This should check & update balances etc.
    /// This is only called when the user is applying a custom fee.
    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction>

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction>
}

// MARK: - Conversion rates

extension TransactionEngine {

    public var predefinedAmount: MoneyValue? {
        switch transactionTarget {
        case let target as ReceiveAddress:
            return target.predefinedAmount
        default:
            return nil
        }
    }

    public var transactionExchangeRatePair: Observable<MoneyValuePair> {
        .empty()
    }

    public func amountToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        currencyConversionService.conversionRate(
            from: pendingTransaction.amount.currency,
            to: sourceAsset
        )
    }

    public func onChainFeeToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        // The price endpoint doesn't support crypto -> crypto rates, so we need to be careful here.
        currencyConversionService.conversionRate(
            from: pendingTransaction.feeAmount.currency,
            to: tradingCurrency.currencyType
        )
        .zip(
            sourceToFiatTradingCurrencyRate(
                pendingTransaction: pendingTransaction,
                tradingCurrency: tradingCurrency
            )
        )
        .map { [sourceAsset] feeToFiatRate, sourceToFiatRate in
            feeToFiatRate.convert(usingInverse: sourceToFiatRate, currency: sourceAsset)
        }
        .eraseToAnyPublisher()
    }

    public func fiatTradingCurrencyToSourceRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        currencyConversionService.conversionRate(
            from: tradingCurrency.currencyType,
            to: sourceAsset
        )
    }

    public func sourceToFiatTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        currencyConversionService.conversionRate(
            from: sourceAsset,
            to: tradingCurrency.currencyType
        )
    }

    public func destinationToFiatTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        currencyConversionService.conversionRate(
            from: targetAsset,
            to: tradingCurrency.currencyType
        )
    }

    public func sourceToDestinationTradingCurrencyRate(
        pendingTransaction: PendingTransaction,
        tradingCurrency: FiatCurrency
    ) -> AnyPublisher<MoneyValue, PriceServiceError> {
        // The price endpoint doesn't support crypto -> crypto rates, so we need to be careful here.
        sourceToFiatTradingCurrencyRate(
            pendingTransaction: pendingTransaction,
            tradingCurrency: tradingCurrency
        )
        .zip(
            destinationToFiatTradingCurrencyRate(
                pendingTransaction: pendingTransaction,
                tradingCurrency: tradingCurrency
            )
        )
        .map { [targetAsset] sourceToFiatRate, destinationToFiatRate in
            sourceToFiatRate.convert(usingInverse: destinationToFiatRate, currency: targetAsset)
        }
        .eraseToAnyPublisher()
    }

    func fetchExchangeRates(
        for pendingTransaction: PendingTransaction
    ) -> AnyPublisher<TransactionExchangeRates, PriceServiceError> {
        walletCurrencyService
            .tradingCurrencyPublisher
            .setFailureType(to: PriceServiceError.self)
            .flatMap { [weak self] tradingCurrency -> AnyPublisher<[MoneyValue], PriceServiceError> in
                guard let self else {
                    fatalError("Publiser not retained '\(#function)'")
                }
                let exchangeRatesPublishers: [AnyPublisher<MoneyValue, PriceServiceError>] = [
                    self.amountToSourceRate(
                        pendingTransaction: pendingTransaction,
                        tradingCurrency: tradingCurrency
                    ),
                    self.onChainFeeToSourceRate(
                        pendingTransaction: pendingTransaction,
                        tradingCurrency: tradingCurrency
                    ),
                    self.fiatTradingCurrencyToSourceRate(
                        pendingTransaction: pendingTransaction,
                        tradingCurrency: tradingCurrency
                    ),
                    self.sourceToFiatTradingCurrencyRate(
                        pendingTransaction: pendingTransaction,
                        tradingCurrency: tradingCurrency
                    ),
                    self.destinationToFiatTradingCurrencyRate(
                        pendingTransaction: pendingTransaction,
                        tradingCurrency: tradingCurrency
                    ),
                    self.sourceToDestinationTradingCurrencyRate(
                        pendingTransaction: pendingTransaction,
                        tradingCurrency: tradingCurrency
                    )
                ]
                return exchangeRatesPublishers.zip()
            }
            .map { exchangeRates -> TransactionExchangeRates in
                TransactionExchangeRates(
                    amountToSourceRate: exchangeRates[0],
                    onChainFeeToSourceRate: exchangeRates[1],
                    fiatTradingCurrencyToSourceRate: exchangeRates[2],
                    sourceToFiatTradingCurrencyRate: exchangeRates[3],
                    destinationToFiatTradingCurrencyRate: exchangeRates[4],
                    sourceToDestinationTradingCurrencyRate: exchangeRates[5]
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Other

extension TransactionEngine {

    public var sourceAsset: CurrencyType {
        guard let account = sourceAccount as? SingleAccount else {
            fatalError("Expected a SingleAccount: \(String(describing: sourceAccount))")
        }
        return account.currencyType
    }

    public var targetAsset: CurrencyType {
        transactionTarget.currencyType
    }

    public var sourceCryptoCurrency: CryptoCurrency {
        guard let crypto = sourceAsset.cryptoCurrency else {
            fatalError("Expected a CryptoCurrency type: \(sourceAsset)")
        }
        return crypto
    }

    public var canTransactFiat: Bool { false }

    public func stop(pendingTransaction: PendingTransaction) {}

    public func start(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmation
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }

    public func restart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        defaultRestart(transactionTarget: transactionTarget, pendingTransaction: pendingTransaction)
    }

    public func defaultRestart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        self.transactionTarget = transactionTarget
        return .just(pendingTransaction)
    }

    public func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    public func doOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction> {
        defaultDoOptionUpdateRequest(pendingTransaction: pendingTransaction, newConfirmation: newConfirmation)
    }

    public func defaultDoOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction.insert(confirmation: newConfirmation))
    }

    public func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    public func createOrder(pendingTransaction: PendingTransaction) -> Single<TransactionOrder?> {
        .just(nil)
    }

    public func cancelOrder(with identifier: String) -> Single<Void> {
        .just(())
    }

    public func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        unimplemented("Override this method in your Engine implementation. If you need to execute an order, override 'execute(pendingTransaction:pendingOrder:)' instead")
    }

    public func execute(
        pendingTransaction: PendingTransaction,
        pendingOrder: TransactionOrder?
    ) -> Single<TransactionResult> {
        execute(pendingTransaction: pendingTransaction)
    }

    public func doPostExecute(
        transactionResult: TransactionResult
    ) -> Completable {
        sourceAccount.invalidateAccountBalance()
        if let target = transactionTarget as? BlockchainAccount {
            target.invalidateAccountBalance()
        }
        return transactionTarget
            .onTxCompleted(transactionResult)
    }
}

// MARK: - Transaction validation

extension TransactionEngine {

    public func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultValidateAmount(pendingTransaction: pendingTransaction)
    }

    public func defaultValidateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard pendingTransaction.amount.isNotZero else {
            return .just(pendingTransaction)
        }
        guard let sourceAccount, transactionTarget != nil else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }

        return fetchExchangeRates(for: pendingTransaction)
            .eraseError()
            .zip(sourceAccount.balance)
            .asSingle()
            .map { [weak self] exchangeRates, sourceBalance -> Void in
                guard let self else {
                    return
                }
                // normalize all amounts to the transaction's source account currency so we can compare and operate on them
                let amountInSourceCurrency = pendingTransaction.amount.convert(
                    using: exchangeRates.amountToSourceRate
                )

                let transactionLimitsInSourceCurrency = try self.transactionLimitsInSourceCurrency(
                    from: pendingTransaction,
                    exchangeRates: exchangeRates
                )

                // rate using to display limits errors in the input currency
                let sourceToInputAmountRate = MoneyValuePair(
                    base: .one(currency: pendingTransaction.amount.currency),
                    exchangeRate: exchangeRates.amountToSourceRate
                ).inverseQuote.quote

                try self.validate(
                    amountInSourceCurrency,
                    isWithin: transactionLimitsInSourceCurrency,
                    sourceToAmountRate: sourceToInputAmountRate
                )

                // For ERC20 don't include the fee in validation (because ERC20 fee is in ETH)
                guard self.sourceAsset.cryptoCurrency?.isERC20 != true else {
                    try self.validate(
                        amountInSourceCurrency,
                        hasAmountUpToSourceLimit: sourceBalance,
                        sourceToAmountRate: sourceToInputAmountRate
                    )
                    return
                }

                let feeInSourceCurrency = pendingTransaction.feeAmount.convert(
                    using: exchangeRates.onChainFeeToSourceRate
                )

                guard try sourceBalance >= feeInSourceCurrency else {
                    throw TransactionValidationFailure(
                        state: .belowFees(feeInSourceCurrency, sourceBalance)
                    )
                }

                // calculate available balance
                let availableBalanceInSourceCurrency = try sourceBalance - feeInSourceCurrency

                try self.validate(
                    amountInSourceCurrency,
                    hasAmountUpToSourceLimit: availableBalanceInSourceCurrency,
                    sourceToAmountRate: sourceToInputAmountRate
                )
            }
            .asCompletable()
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    private func transactionLimitsInSourceCurrency(
        from pendingTransaction: PendingTransaction,
        exchangeRates: TransactionExchangeRates
    ) throws -> TransactionLimits {
        let limits = pendingTransaction.normalizedLimits
        let convertedLimits: TransactionLimits
        if limits.currencyType == pendingTransaction.amount.currencyType {
            convertedLimits = limits.convert(using: exchangeRates.amountToSourceRate)
        } else if limits.currencyType == sourceAccount.currencyType {
            convertedLimits = limits
        } else {
            print("🚨 Limits should be set in either the same currency as the input amount or in the source currency")
            throw TransactionValidationFailure(state: .optionInvalid)
        }
        return convertedLimits
    }

    private func validate(
        _ amount: MoneyValue,
        isWithin limits: TransactionLimits,
        sourceToAmountRate: MoneyValue
    ) throws {
        let minLimit = limits.minimum ?? .zero(currency: limits.currencyType)
        guard try amount >= minLimit else {
            throw TransactionValidationFailure(
                state: .belowMinimumLimit(minLimit.convert(using: sourceToAmountRate))
            )
        }

        guard let maxLimit = limits.maximum else {
            return
        }

        guard try amount <= maxLimit, !maxLimit.isZero else {
            if sourceAccount is LinkedBankAccount {
                throw TransactionValidationFailure(
                    state: .overMaximumSourceLimit(
                        maxLimit.convert(using: sourceToAmountRate),
                        sourceAccount.label,
                        amount
                    )
                )
            }
            let maxLimitForDisplay = maxLimit.convert(using: sourceToAmountRate)
            let effectiveLimit = limits.effectiveLimit?.convert(using: sourceToAmountRate)
            let upgrade = limits.suggestedUpgrade
                .flatMap { upgrade -> TransactionValidationState.LimitsUpgrade in
                    .init(requiresTier2: upgrade.requiredTier == .tier2)
                }
            throw TransactionValidationFailure(
                state: .overMaximumPersonalLimit(
                    effectiveLimit ?? EffectiveLimit(timeframe: .single, value: maxLimitForDisplay),
                    maxLimitForDisplay,
                    upgrade
                )
            )
        }
    }

    private func validate(
        _ amount: MoneyValue,
        hasAmountUpToSourceLimit limit: MoneyValue,
        sourceToAmountRate: MoneyValue
    ) throws {
        guard (sourceAccount is LinkedBankAccount) == false else {
            // bank accounts have no balance to us, so nothing to there's validate against
            return
        }
        guard try amount <= limit else {
            if let source = sourceAccount as? PaymentMethodAccount, !source.paymentMethod.type.isFunds {
                throw TransactionValidationFailure(
                    state: .overMaximumSourceLimit(
                        limit.convert(using: sourceToAmountRate),
                        sourceAccount.label,
                        amount.convert(using: sourceToAmountRate)
                    )
                )
            }
            throw TransactionValidationFailure(
                state: .insufficientFunds(
                    limit.convert(using: sourceToAmountRate),
                    amount, // leave amount is source currency
                    sourceAccount.currencyType,
                    transactionTarget.currencyType
                )
            )
        }
    }
}
