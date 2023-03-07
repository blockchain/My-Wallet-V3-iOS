// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class TradingToOnChainTransactionEngine: TransactionEngine {

    /// This might need to be `1:1` as there isn't a transaction pair.
    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        .empty()
    }

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
    let isNoteSupported: Bool
    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var sourceTradingAccount: CryptoTradingAccount! {
        sourceAccount as? CryptoTradingAccount
    }

    var target: CryptoReceiveAddress {
        transactionTarget as! CryptoReceiveAddress
    }

    var targetAsset: CryptoCurrency { target.asset }

    // MARK: - Private Properties

    private let transferRepository: CustodialTransferRepositoryAPI
    private let transactionLimitsService: TransactionLimitsServiceAPI

    // MARK: - Init

    init(
        isNoteSupported: Bool = false,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        transferRepository: CustodialTransferRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve()
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.isNoteSupported = isNoteSupported
        self.transferRepository = transferRepository
        self.transactionLimitsService = transactionLimitsService
    }

    func assertInputsValid() {
        precondition(transactionTarget is CryptoReceiveAddress)
        precondition(sourceAsset == targetAsset)
    }

    func restart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        let memoModel = TransactionConfirmations.Memo(
            textMemo: target.memo,
            required: false
        )
        return defaultRestart(
            transactionTarget: transactionTarget,
            pendingTransaction: pendingTransaction
        )
        .map { [sourceTradingAccount] pendingTransaction -> PendingTransaction in
            guard sourceTradingAccount!.isMemoSupported else {
                return pendingTransaction
            }
            var pendingTransaction = pendingTransaction
            pendingTransaction.setMemo(memo: memoModel)
            return pendingTransaction
        }
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        let memoModel = TransactionConfirmations.Memo(
            textMemo: target.memo,
            required: false
        )
        let transactionLimits = transactionLimitsService
            .fetchLimits(
                source: LimitsAccount(
                    currency: sourceAccount.currencyType,
                    accountType: .custodial
                ),
                destination: LimitsAccount(
                    currency: targetAsset.currencyType,
                    accountType: .nonCustodial // even exchange accounts are considered non-custodial atm.
                )
            )

        let sourceAccountCurrencyType = sourceAccount.currencyType
        let withdrawalMaxFees = walletCurrencyService.tradingCurrencyPublisher
            .flatMap { [transferRepository] userFiat -> AnyPublisher<WithdrawalFees, Error> in
                transferRepository.withdrawalFees(
                    currency: sourceAccountCurrencyType,
                    fiatCurrency: userFiat.currencyType,
                    amount: "0",
                    max: true
                )
                .eraseError()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return transactionLimits.eraseError()
            .zip(
                walletCurrencyService.tradingCurrencyPublisher.eraseError(),
                withdrawalMaxFees,
                sourceTradingAccount.withdrawableBalance
            )
            .tryMap { [sourceTradingAccount, sourceAsset, predefinedAmount] transactionLimits, walletCurrency, maxFees, withdrawableBalance
                -> PendingTransaction in
                let amount: MoneyValue
                if let predefinedAmount,
                   predefinedAmount.currencyType == sourceAsset
                {
                    amount = predefinedAmount
                } else {
                    amount = .zero(currency: sourceAsset)
                }
                let maxFee = maxFees.totalFees.amount.value
                let available = try withdrawableBalance - maxFee
                var pendingTransaction = PendingTransaction(
                    amount: amount,
                    available: available.isNegative ? .zero(currency: sourceAsset) : available,
                    feeAmount: maxFee,
                    feeForFullAvailable: maxFee,
                    feeSelection: .empty(asset: sourceAsset),
                    selectedFiatCurrency: walletCurrency,
                    limits: transactionLimits.update(minimum: maxFees.minAmount.amount.value)
                )
                if sourceTradingAccount!.isMemoSupported {
                    pendingTransaction.setMemo(memo: memoModel)
                }
                return pendingTransaction
            }
            .asSingle()
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceTradingAccount != nil else {
            return .just(pendingTransaction)
        }

        let withdrawalFees = walletCurrencyService.tradingCurrencyPublisher
            .flatMap { [transferRepository] userFiat -> AnyPublisher<WithdrawalFees, Error> in
                transferRepository.withdrawalFees(
                    currency: amount.currencyType,
                    fiatCurrency: userFiat.currencyType,
                    amount: amount.minorString,
                    max: false
                )
                .eraseError()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return withdrawalFees
            .map { fees -> PendingTransaction in
                var pendingTransaction = pendingTransaction.update(
                    amount: amount,
                    available: pendingTransaction.available,
                    fee: fees.totalFees.amount.value,
                    feeForFullAvailable: fees.totalFees.amount.value
                )
                let transactionLimits = pendingTransaction.limits ?? .noLimits(for: amount.currency)
                pendingTransaction.limits = TransactionLimits(
                    currencyType: transactionLimits.currencyType,
                    minimum: fees.minAmount.amount.value,
                    maximum: transactionLimits.maximum,
                    maximumDaily: transactionLimits.maximumDaily,
                    maximumAnnual: transactionLimits.maximumAnnual,
                    effectiveLimit: transactionLimits.effectiveLimit,
                    suggestedUpgrade: transactionLimits.suggestedUpgrade,
                    earn: transactionLimits.earn
                )
                return pendingTransaction
            }
            .eraseError()
            .asSingle()
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(
            fiatAmountAndFees(from: pendingTransaction),
            convertAmountIntoTradingCurrency(pendingTransaction.amount)
        )
        .map { [sourceTradingAccount, target, isNoteSupported] fiatAmountAndFees, amountFiatValue -> [TransactionConfirmation] in
            let totalPlusFee = try pendingTransaction.amount + pendingTransaction.feeAmount
            let totalPlusFeeFiat = try amountFiatValue.moneyValue + fiatAmountAndFees.fees.moneyValue
            var confirmations: [TransactionConfirmation] = [
                TransactionConfirmations.Amount(amount: pendingTransaction.amount, exchange: amountFiatValue),
                TransactionConfirmations.Source(value: sourceTradingAccount!.label),
                TransactionConfirmations.Destination(value: target.label),
                TransactionConfirmations.ProccessingFee(
                    fee: pendingTransaction.feeAmount,
                    exchange: fiatAmountAndFees.fees.moneyValue
                ),
                TransactionConfirmations.SendTotal(
                    total: totalPlusFee,
                    exchange: totalPlusFeeFiat
                )
            ]
            if isNoteSupported {
                confirmations.append(TransactionConfirmations.Destination(value: ""))
            }
            if sourceTradingAccount!.isMemoSupported {
                confirmations.append(
                    TransactionConfirmations.Memo(textMemo: target.memo, required: false)
                )
            }
            return confirmations
        }
        .map { confirmations in
            pendingTransaction.update(confirmations: confirmations)
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
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        transferRepository
            .transfer(
                moneyValue: pendingTransaction.amount,
                destination: target.address,
                fee: pendingTransaction.feeAmount,
                memo: pendingTransaction.memo?.value?.string
            )
            .map { identifier -> TransactionResult in
                    .hashed(txHash: identifier, amount: pendingTransaction.amount)
            }
            .asSingle()
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            convertAmountIntoTradingCurrency(pendingTransaction.amount),
            convertAmountIntoTradingCurrency(pendingTransaction.feeAmount)
        )
        .map { (amount: $0.0, fees: $0.1) }
    }

    private var fiatExchangeRatePairsSingle: Single<TransactionMoneyValuePairs> {
        fiatExchangeRatePairs
            .take(1)
            .asSingle()
    }

    private func convertAmountIntoTradingCurrency(_ amount: MoneyValue) -> Single<FiatValue> {
        fiatExchangeRatePairsSingle
            .map { moneyPair in
                guard !amount.isFiat else {
                    return amount.fiatValue!
                }
                return try amount
                    .convert(using: moneyPair.source)
                    .displayableRounding(roundingMode: .bankers)
                    .fiatValue!
            }
    }

    private var sourceExchangeRatePair: Observable<MoneyValuePair> {
        let cryptoCurrency = transactionTarget.currencyType
        return walletCurrencyService
            .tradingCurrencyPublisher
            .map(\.currencyType)
            .flatMap { [currencyConversionService] tradingCurrency in
                currencyConversionService
                    .conversionRate(from: cryptoCurrency, to: tradingCurrency)
                    .map { quote in
                        MoneyValuePair(
                            base: .one(currency: cryptoCurrency),
                            quote: quote
                        )
                    }
            }
            .asObservable()
    }
}

extension CryptoTradingAccount {
    fileprivate var isMemoSupported: Bool {
        switch asset.code {
        case CryptoCurrency.stellar.code:
            return true
        case "STX":
            return true
        default:
            return false
        }
    }
}

extension PendingTransaction {

    fileprivate var memo: TransactionConfirmations.Memo? {
        engineState.value[.memo] as? TransactionConfirmations.Memo
    }

    fileprivate mutating func setMemo(memo: TransactionConfirmations.Memo) {
        engineState.mutate { $0[.memo] = memo }
    }
}

extension TransactionLimits {
    func update(minimum: MoneyValue) -> TransactionLimits {
        TransactionLimits(
            currencyType: minimum.currencyType,
            minimum: minimum,
            maximum: maximum,
            maximumDaily: maximumDaily,
            maximumAnnual: maximumAnnual,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: suggestedUpgrade,
            earn: nil
        )
    }
}
