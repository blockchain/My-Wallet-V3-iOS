// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class FiatWithdrawalTransactionEngine: TransactionEngine {

    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let canTransactFiat: Bool = true
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var sourceTradingAccount: FiatAccount! {
        sourceAccount as? FiatAccount
    }

    var target: LinkedBankAccount { transactionTarget as! LinkedBankAccount }
    var targetAsset: FiatCurrency { target.fiatCurrency }
    var sourceAsset: FiatCurrency { sourceTradingAccount.fiatCurrency }

    // MARK: - Private Properties

    private let fiatWithdrawRepository: FiatWithdrawRepositoryAPI
    private let withdrawalService: WithdrawalServiceAPI

    // MARK: - Init

    init(
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        withdrawalService: WithdrawalServiceAPI = resolve(),
        fiatWithdrawRepository: FiatWithdrawRepositoryAPI = resolve()
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.withdrawalService = withdrawalService
        self.currencyConversionService = currencyConversionService
        self.fiatWithdrawRepository = fiatWithdrawRepository
    }

    // MARK: - TransactionEngine

    func assertInputsValid() {
        precondition(sourceAccount is FiatAccount)
        precondition(transactionTarget is LinkedBankAccount)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            sourceAccount.actionableBalance.asSingle(),
            withdrawalService.withdrawFeeAndLimit(
                for: target.fiatCurrency,
                paymentMethodType: target.paymentType
            ),
            walletCurrencyService
                .tradingCurrency
                .asSingle()
        )
        .map { [sourceAsset] values -> PendingTransaction in
            let (actionableBalance, feeAndLimit, fiatCurrency) = values
            let zero: MoneyValue = .zero(currency: sourceAsset)
            return PendingTransaction(
                amount: zero,
                available: actionableBalance,
                feeAmount: feeAndLimit.fee.moneyValue,
                feeForFullAvailable: zero,
                feeSelection: .init(
                    selectedLevel: .none,
                    availableLevels: []
                ),
                selectedFiatCurrency: fiatCurrency,
                limits: .init(
                    currencyType: feeAndLimit.minLimit.currencyType,
                    minimum: feeAndLimit.minLimit.moneyValue,
                    maximum: feeAndLimit.maxLimit?.moneyValue ?? actionableBalance,
                    maximumDaily: nil,
                    maximumAnnual: nil,
                    effectiveLimit: nil,
                    suggestedUpgrade: nil,
                    earn: nil
                )
            )
        }
    }

    func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<PendingTransaction, Error> {
        .just(pendingTransaction
            .update(
                confirmations: [
                    TransactionConfirmations.Source(value: sourceAccount.label),
                    TransactionConfirmations.Destination(value: target.label),
                    TransactionConfirmations.FiatTransactionFee(fee: pendingTransaction.feeAmount),
                    TransactionConfirmations.FundsArrivalDate.default,
                    TransactionConfirmations.Total(total: pendingTransaction.amount)
                ]
            )
        )
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction.update(amount: amount))
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultValidateAmount(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        target
            .receiveAddress
            .asSingle()
            .map(\.address)
            .flatMap { [fiatWithdrawRepository] address -> Single<TransactionResult> in
                fiatWithdrawRepository
                    .createWithdrawOrder(id: address, amount: pendingTransaction.amount)
                    .map { _ in TransactionResult.unHashed(amount: pendingTransaction.amount, orderId: nil) }
                    .asSingle()
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func validateAmountCompletable(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable { [sourceAccount, transactionTarget] in
            let minLimit = pendingTransaction.minLimit
            let maxLimit = pendingTransaction.maxLimit
            guard try pendingTransaction.amount >= minLimit else {
                throw TransactionValidationFailure(state: .belowMinimumLimit(minLimit))
            }
            guard try pendingTransaction.amount <= maxLimit else {
                throw TransactionValidationFailure(
                    state: .overMaximumPersonalLimit(
                        EffectiveLimit(timeframe: .daily, value: pendingTransaction.maxSpendable),
                        maxLimit,
                        nil
                    )
                )
            }
            guard try pendingTransaction.available >= pendingTransaction.amount else {
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
    }
}
