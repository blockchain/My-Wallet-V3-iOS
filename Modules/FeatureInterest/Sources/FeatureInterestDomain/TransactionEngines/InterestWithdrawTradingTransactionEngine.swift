// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Errors
import FeatureStakingDomain
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

/// Transaction Engine for Interest Withdraw to a Trading Account.
public final class InterestWithdrawTradingTransactionEngine: InterestTransactionEngine {

    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        unimplemented()
    }

    // MARK: - TransactionEngine

    public let walletCurrencyService: FiatCurrencyServiceAPI
    public let currencyConversionService: CurrencyConversionServiceAPI
    public var askForRefreshConfirmation: AskForRefreshConfirmation!
    public var sourceAccount: BlockchainAccount!
    public var transactionTarget: TransactionTarget!

    // MARK: - Private Properties

    private var availableBalance: Single<MoneyValue> {
        sourceAccount
            .balance
            .asSingle()
    }

    private var minimumLimit: Single<MoneyValue> {
        feeCache
            .fetchValue
            .map(\.[minimumAmount: sourceAsset])
    }

    private var fee: Single<MoneyValue> {
        feeCache
            .fetchValue
            .map(\.[fee: sourceAsset])
    }

    private var interestAccountLimits: Single<InterestAccountLimits> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [accountLimitsRepository, sourceAsset] fiatCurrency in
                accountLimitsRepository
                    .fetchInterestAccountLimitsForCryptoCurrency(
                        sourceAsset.cryptoCurrency!,
                        fiatCurrency: fiatCurrency
                    )
            }
            .asSingle()
    }

    private let feeCache: CachedValue<CustodialTransferFee>
    private let accountTransferRepository: InterestAccountTransferRepositoryAPI
    /// Used for fetching fees and limits for interest.
    private let transferRepository: CustodialTransferRepositoryAPI
    private let accountLimitsRepository: InterestAccountLimitsRepositoryAPI

    // MARK: - Init

    init(
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        accountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve(),
        transferRepository: CustodialTransferRepositoryAPI = resolve(),
        accountTransferRepository: InterestAccountTransferRepositoryAPI = resolve()
    ) {
        self.accountTransferRepository = accountTransferRepository
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.accountLimitsRepository = accountLimitsRepository
        self.transferRepository = transferRepository
        self.feeCache = CachedValue(
            configuration: .periodic(
                seconds: 20,
                schedulerIdentifier: "InterestWithdrawTradingTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<CustodialTransferFee> in
            self.transferRepository
                .feesAndLimitsForInterest()
                .asSingle()
        }
    }

    public func assertInputsValid() {
        precondition(sourceAccount is InterestAccount)
        precondition(transactionTarget is CryptoAccount)
        precondition(transactionTarget is TradingAccount)
        precondition(sourceAsset == (transactionTarget as! CryptoAccount).asset)
    }

    public func initializeTransaction()
        -> Single<PendingTransaction>
    {
        Single.zip(
            walletCurrencyService
                .displayCurrency
                .asSingle(),
            fee,
            availableBalance,
            minimumLimit,
            interestAccountLimits
                .map(\.maxWithdrawalAmount)
                .map(\.moneyValue)
        )
        .map { [sourceAsset] fiatCurrency, fee, balance, minimum, maximum -> PendingTransaction in
            PendingTransaction(
                amount: .zero(currency: sourceAsset),
                available: balance,
                feeAmount: fee,
                feeForFullAvailable: .zero(currency: sourceAsset),
                feeSelection: .empty(asset: sourceAsset),
                selectedFiatCurrency: fiatCurrency,
                limits: .init(
                    currencyType: minimum.currencyType,
                    minimum: minimum,
                    maximum: maximum,
                    maximumDaily: nil,
                    maximumAnnual: nil,
                    effectiveLimit: nil,
                    suggestedUpgrade: nil,
                    earn: nil
                )
            )
        }
    }

    public func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        let source = sourceAccount.label
        let destination = transactionTarget.label
        return fiatAmountAndFees(from: pendingTransaction)
            .map { fiatAmount, fiatFees -> PendingTransaction in
                pendingTransaction
                    .update(
                        confirmations: [
                            TransactionConfirmations.Source(value: source),
                            TransactionConfirmations.Destination(value: destination),
                            TransactionConfirmations.FeedTotal(
                                amount: pendingTransaction.amount,
                                amountInFiat: fiatAmount.moneyValue,
                                fee: pendingTransaction.feeAmount,
                                feeInFiat: fiatFees.moneyValue
                            )
                        ]
                    )
            }
    }

    public func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .map { balance in
                pendingTransaction
                    .update(
                        amount: amount,
                        available: balance
                    )
            }
    }

    public func validateAmount(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .flatMapCompletable(weak: self) { (self, balance) in
                self.checkIfAvailableBalanceIsSufficient(
                    pendingTransaction,
                    balance: balance
                )
                .andThen(
                    self.checkIfAmountIsBelowMinimumLimit(
                        pendingTransaction
                    )
                )
            }
            .updateTxValidityCompletable(
                pendingTransaction: pendingTransaction
            )
    }

    public func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    public func execute(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        accountTransferRepository
            .createInterestAccountCustodialWithdraw(pendingTransaction.amount)
            .mapError { error -> TransactionValidationFailure in
                if let nabu = extract(NabuError.self, from: error) {
                    if nabu.code == .insufficientBalance, nabu.type == .conflict {
                        return TransactionValidationFailure(state: .insufficientInterestWithdrawalBalance)
                    }
                    return TransactionValidationFailure(state: .nabuError(nabu))
                } else {
                    return TransactionValidationFailure(state: .unknownError)
                }
            }
            .map { _ in
                TransactionResult.unHashed(amount: pendingTransaction.amount, orderId: nil)
            }
            .asSingle()
    }

    public func doPostExecute(
        transactionResult: TransactionResult
    ) -> Completable {
        transactionTarget
            .onTxCompleted(transactionResult)
    }

    public func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }
}

public final class EarnWithdrawTradingTransactionEngine: InterestTransactionEngine {

    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        unimplemented()
    }

    // MARK: - TransactionEngine

    public let walletCurrencyService: FiatCurrencyServiceAPI
    public let currencyConversionService: CurrencyConversionServiceAPI
    public var askForRefreshConfirmation: AskForRefreshConfirmation!
    public var sourceAccount: BlockchainAccount!
    public var transactionTarget: TransactionTarget!

    // MARK: - Private Properties

    private var availableBalance: Single<MoneyValue> {
        sourceAccount.balance.asSingle()
    }

    private var minimumLimit: Single<MoneyValue> {
        feeCache
            .fetchValue
            .map(\.[minimumAmount: sourceAsset])
    }

    private var fee: Single<MoneyValue> {
        feeCache
            .fetchValue
            .map(\.[fee: sourceAsset])
    }

    private var interestAccountLimits: Single<InterestAccountLimits> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [accountLimitsRepository, sourceAsset] fiatCurrency in
                accountLimitsRepository
                    .fetchInterestAccountLimitsForCryptoCurrency(
                        sourceAsset.cryptoCurrency!,
                        fiatCurrency: fiatCurrency
                    )
            }
            .asSingle()
    }

    private let feeCache: CachedValue<CustodialTransferFee>
    private let accountTransferRepository: InterestAccountTransferRepositoryAPI
    /// Used for fetching fees and limits for interest.
    private let transferRepository: CustodialTransferRepositoryAPI
    private let accountLimitsRepository: InterestAccountLimitsRepositoryAPI

    private let app: AppProtocol
    private let earnAccountService: EarnAccountService

    // MARK: - Init

    convenience init(product: EarnProduct) {
        self.init(earnAccountService: resolve(tag: product))
    }

    init(
        app: AppProtocol = resolve(),
        earnAccountService: EarnAccountService,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        accountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve(),
        transferRepository: CustodialTransferRepositoryAPI = resolve(),
        accountTransferRepository: InterestAccountTransferRepositoryAPI = resolve()
    ) {
        self.app = app
        self.earnAccountService = earnAccountService
        self.accountTransferRepository = accountTransferRepository
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.accountLimitsRepository = accountLimitsRepository
        self.transferRepository = transferRepository
        self.feeCache = CachedValue(
            configuration: .periodic(
                seconds: 20,
                schedulerIdentifier: "InterestWithdrawTradingTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<CustodialTransferFee> in
            self.transferRepository
                .feesAndLimitsForInterest()
                .asSingle()
        }
    }

    public func assertInputsValid() {
        precondition(sourceAccount is InterestAccount || sourceAccount is StakingAccount || sourceAccount is ActiveRewardsAccount)
        precondition(transactionTarget is CryptoAccount)
        precondition(transactionTarget is TradingAccount)
        precondition(sourceAsset == (transactionTarget as! CryptoAccount).asset)
    }

    public func initializeTransaction()
    -> Single<PendingTransaction>
    {
        Single.zip(
            walletCurrencyService
                .displayCurrency
                .asSingle(),
            fee,
            availableBalance,
            minimumLimit,
            interestAccountLimits
                .map(\.maxWithdrawalAmount)
                .map(\.moneyValue)
        )
        .map { [sourceAsset] fiatCurrency, fee, balance, minimum, maximum -> PendingTransaction in
            PendingTransaction(
                amount: .zero(currency: sourceAsset),
                available: balance,
                feeAmount: fee,
                feeForFullAvailable: .zero(currency: sourceAsset),
                feeSelection: .empty(asset: sourceAsset),
                selectedFiatCurrency: fiatCurrency,
                limits: .init(
                    currencyType: minimum.currencyType,
                    minimum: minimum,
                    maximum: maximum,
                    maximumDaily: nil,
                    maximumAnnual: nil,
                    effectiveLimit: nil,
                    suggestedUpgrade: nil,
                    earn: nil
                )
            )
        }
    }

    public func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        let source = sourceAccount.label
        let destination = transactionTarget.label
        return fiatAmountAndFees(from: pendingTransaction)
            .map { fiatAmount, fiatFees -> PendingTransaction in
                pendingTransaction
                    .update(
                        confirmations: [
                            TransactionConfirmations.Source(value: source),
                            TransactionConfirmations.Destination(value: destination),
                            TransactionConfirmations.FeedTotal(
                                amount: pendingTransaction.amount,
                                amountInFiat: fiatAmount.moneyValue,
                                fee: pendingTransaction.feeAmount,
                                feeInFiat: fiatFees.moneyValue
                            )
                        ]
                    )
            }
    }

    public func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .map { balance in
                pendingTransaction
                    .update(
                        amount: amount,
                        available: balance
                    )
            }
    }

    public func validateAmount(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .flatMapCompletable(weak: self) { (self, balance) in
                self.checkIfAvailableBalanceIsSufficient(
                    pendingTransaction,
                    balance: balance
                )
                .andThen(
                    self.checkIfAmountIsBelowMinimumLimit(
                        pendingTransaction
                    )
                )
            }
            .updateTxValidityCompletable(
                pendingTransaction: pendingTransaction
            )
    }

    public func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    public func execute(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        earnAccountService.withdraw(amount: pendingTransaction.amount)
            .map { TransactionResult.unHashed(amount: pendingTransaction.amount, orderId: nil) }
            .asSingle()
    }

    public func doPostExecute(
        transactionResult: TransactionResult
    ) -> Completable {
        transactionTarget
            .onTxCompleted(transactionResult)
    }

    public func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }
}
