// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import ToolKit

struct TransactionState: StateType {

    struct KYCStatus: Equatable {
        let tiers: KYC.UserTiers

        var canPurchaseCrypto: Bool {
            tiers.canPurchaseCrypto()
        }

        var canUpgradeTier: Bool {
            tiers.canCompleteVerified
        }
    }

    // MARK: Actual Transaction Data

    let action: AssetAction

    var availableSources: [BlockchainAccount]?
    var availableTargets: [TransactionTarget]?

    var source: BlockchainAccount?
    var destination: TransactionTarget?

    var exchangeRates: TransactionExchangeRates?

    // MARK: Execution Supporting Data

    private var _pendingTransaction: Reference<PendingTransaction>? // struct too big for Swift
    var pendingTransaction: PendingTransaction? {
        get {
            _pendingTransaction?.value
        }
        set {
            if let pendingTransaction = newValue {
                _pendingTransaction = .init(pendingTransaction)
            } else {
                _pendingTransaction = nil
            }
        }
    }

    var executionStatus: TransactionExecutionStatus = .notStarted
    var errorState: TransactionErrorState = .none
    var order: TransactionOrder?

    var quote: BrokerageQuote?
    var price: BrokerageQuote.Price?, priceInput: MoneyValue?

    var isStreamingQuotes: Bool {
        switch action {
        case .buy:
            return step == .confirmDetail
        case .sell, .swap:
            return step == .confirmDetail || (step == .enterAmount && amount.isPositive)
        case _:
            return false
        }
    }

    var isStreamingPrices: Bool {
        step == .enterAmount
    }

    var dialog: UX.Dialog?

    /// `userKYCStatus` is `nil` until a transaction initializes.
    var userKYCStatus: KYCStatus?

    // MARK: UI Supporting Data

    var allowFiatInput: Bool = false

    // MARK: Navigation Supporting Data

    var nextEnabled: Bool = false
    var isGoingBack: Bool = false

    var step: TransactionFlowStep = .initial {
        didSet {
            isGoingBack = false
        }
    }

    var termsAndAgreementsAreValid: Bool {
        guard action == .interestTransfer || action == .stakingDeposit || action == .activeRewardsDeposit else { return true }
        guard let pendingTx = pendingTransaction else { return false }
        return pendingTx.agreementOptionValue
            && pendingTx.termsOptionValue
    }

    var stepsBackStack: [TransactionFlowStep] = []

    /// The predefined MoneyValue that should be used.
    var initialAmountToSet: MoneyValue? {
        switch destination {
        case let target as ReceiveAddress:
            // The predefined amount is only used if the PendingTransaction has
            // it already set. This means the engine chose to use it.
            let predefinedAmount = target.predefinedAmount
            return predefinedAmount == pendingTransaction?.amount
                ? predefinedAmount : nil
        default:
            return nil
        }
    }

    init(
        action: AssetAction,
        source: BlockchainAccount? = nil,
        destination: TransactionTarget? = nil,
        step: TransactionFlowStep = .initial,
        order: TransactionOrder? = nil
    ) {
        self.action = action
        self.source = source
        self.destination = destination
        self.step = step
        self.order = order
    }
}

extension TransactionState {

    var sourceToFiatPair: MoneyValuePair? {
        guard let sourceCurrency = source?.currencyType else {
            return nil
        }
        if let exchangeRate, exchangeRate.quote.isNotZero {
            if exchangeRate.quote.isFiat, exchangeRate.base.currency == sourceCurrency {
                return exchangeRate
            } else if exchangeRate.base.isFiat, exchangeRate.base.currency == sourceCurrency {
                return MoneyValuePair(base: .one(currency: sourceCurrency), quote: .one(currency: sourceCurrency))
            }
        }
        guard let exchangeRate = exchangeRates?.sourceToFiatTradingCurrencyRate else {
            return nil
        }
        return MoneyValuePair(
            base: .one(currency: sourceCurrency),
            exchangeRate: exchangeRate
        )
    }

    var sourceToDestinationPair: MoneyValuePair? {
        if let exchangeRate, exchangeRate.quote.isNotZero {
            return exchangeRate
        }
        guard let sourceCurrencyType = source?.currencyType else {
            return nil
        }
        guard let exchangeRate = exchangeRates?.sourceToDestinationTradingCurrencyRate else {
            return nil
        }
        return MoneyValuePair(
            base: .one(currency: sourceCurrencyType),
            exchangeRate: exchangeRate
        )
    }

    var destinationToFiatPair: MoneyValuePair? {
        guard let destinationCurrency = destination?.currencyType else {
            return nil
        }
        if let exchangeRate, exchangeRate.quote.isNotZero {
            if exchangeRate.quote.isFiat, exchangeRate.base.currency == destinationCurrency {
                return exchangeRate
            } else if exchangeRate.base.isFiat, exchangeRate.base.currency == destinationCurrency {
                return MoneyValuePair(base: .one(currency: destinationCurrency), quote: .one(currency: destinationCurrency))
            }
        }
        guard let exchangeRate = exchangeRates?.destinationToFiatTradingCurrencyRate else {
            return nil
        }
        return MoneyValuePair(
            base: .one(currency: destinationCurrency),
            exchangeRate: exchangeRate
        )
    }
}

extension TransactionState: Equatable {

    static func == (lhs: TransactionState, rhs: TransactionState) -> Bool {
        guard lhs.action == rhs.action else { return false }
        guard lhs.allowFiatInput == rhs.allowFiatInput else { return false }
        guard lhs.destination?.label == rhs.destination?.label else { return false }
        guard lhs.exchangeRates == rhs.exchangeRates else { return false }
        guard lhs.errorState == rhs.errorState else { return false }
        guard lhs.executionStatus == rhs.executionStatus else { return false }
        guard lhs.isGoingBack == rhs.isGoingBack else { return false }
        guard lhs.nextEnabled == rhs.nextEnabled else { return false }
        guard lhs.pendingTransaction == rhs.pendingTransaction else { return false }
        guard lhs.source?.identifier == rhs.source?.identifier else { return false }
        guard lhs.step == rhs.step else { return false }
        guard lhs.stepsBackStack == rhs.stepsBackStack else { return false }
        guard lhs.availableSources?.map(\.identifier) == rhs.availableSources?.map(\.identifier) else { return false }
        guard lhs.availableTargets?.map(\.label) == rhs.availableTargets?.map(\.label) else { return false }
        guard lhs.userKYCStatus == rhs.userKYCStatus else { return false }
        guard lhs.quote == rhs.quote else { return false }
        guard lhs.price == rhs.price else { return false }
        guard lhs.priceInput == rhs.priceInput else { return false }
        return true
    }
}

// MARK: - Limits

extension TransactionState {

    /// The amount the user is swapping from.
    var amount: MoneyValue {
        normalizedValue(for: pendingTransaction?.amount)
    }

    /// The maximum amount the user can use daily for the given transaction.
    /// This is a different value than the spendable amount (and usually higher)
    var maxDaily: MoneyValue {
        normalizedValue(for: pendingTransaction?.maxSpendableDaily)
    }

    /// The minimum spending limit
    var minSpendable: MoneyValue {
        normalizedValue(for: pendingTransaction?.minSpendable)
    }

    /// The maximum amount the user can spend. We compare the amount entered to the
    /// `maxLimit` as `CryptoValues` and return whichever is smaller.
    var maxSpendable: MoneyValue {
        normalizedValue(for: pendingTransaction?.maxSpendable)
    }

    /// The balance in `MoneyValue` based on the `PendingTransaction`
    var availableBalance: MoneyValue {
        normalizedValue(for: pendingTransaction?.available)
    }

    func maxSpendableWithCryptoInputType() -> MoneyValue {
        maxSpendableWithActiveAmountInputType(.crypto)
    }

    func maxSpendableWithActiveAmountInputType(
        _ input: ActiveAmountInput
    ) -> MoneyValue {
        let amount = normalizedValue(for: pendingTransaction?.maxSpendable)
        return convertMoneyValueToInputCurrency(
            amount.displayableRounding(roundingMode: .down),
            activeInput: input
        )
    }

    func minSpendableWithActiveAmountInputType(
        _ input: ActiveAmountInput
    ) -> MoneyValue {
        let amount = normalizedValue(for: pendingTransaction?.minSpendable)
        return convertMoneyValueToInputCurrency(
            amount.displayableRounding(roundingMode: .up),
            activeInput: input
        )
    }

    private func convertMoneyValueToInputCurrency(
        _ moneyValue: MoneyValue,
        activeInput: ActiveAmountInput
    ) -> MoneyValue {
        switch (moneyValue.currency, activeInput) {
        case (.crypto, .crypto),
             (.fiat, .fiat):
            return moneyValue
        case (.crypto, .fiat):
            // Convert crypto max amount into fiat amount.
            guard let exchangeRate = sourceToFiatPair else {
                // No exchange rate yet, use original value for error message.
                return moneyValue
            }
            // Convert crypto max amount into fiat amount.
            return moneyValue.convert(using: exchangeRate.quote)
        case (.fiat, .crypto):
            guard let exchangeRate = sourceToFiatPair else {
                // No exchange rate yet, use original value for error message.
                return moneyValue
            }
            // Convert fiat max amount into crypto amount.
            return moneyValue.convert(usingInverse: exchangeRate.quote, currency: moneyValue.currency)
        }
    }

    /// For `Buy`, the `asset` is fiat. This is because the `source` account
    /// for `Buy` is a `PaymentMethodAccount`. This is why we want to use the
    /// same currency as `originalValue` to do the below comparison or it will always
    /// return `zero` of the source accounts currencyType.
    /// Many of the callers of this function inject values that are not always set until the TxEngine
    /// has calculated the limits/amount/min/max etc.
    /// Other transaction types do not run into this problem.
    private func normalizedValue(for originalValue: MoneyValue?) -> MoneyValue {
        let zero: MoneyValue = .zero(currency: originalValue?.currency ?? asset)
        let value = originalValue ?? zero
        return (try? value >= zero) == true ? value : zero
    }
}

// MARK: - Other

extension TransactionState {

    /// The source account `CryptoCurrency`.
    var asset: CurrencyType {
        guard let sourceAccount = source else {
            fatalError("Source should have been set at this point. Asset Action: \(action), Step: \(step)")
        }
        return sourceAccount.currencyType
    }

    var feeAmount: MoneyValue {
        guard let pendingTx = pendingTransaction else {
            return .zero(currency: asset)
        }
        return pendingTx.feeAmount
    }

    var isFeeLess: Bool {
        guard let pendingTx = pendingTransaction else {
            return false
        }
        return pendingTx.feeLevel.isFeeLess
    }

    /// The fees associated with the transaction
    var feeSelection: FeeSelection {
        guard let pendingTx = pendingTransaction else {
            /// If there is no `pendingTransaction` then the
            /// available fee levels is `[.none]`
            return .empty(asset: asset)
        }
        return pendingTx.feeSelection
    }

    func moneyValueFromSource() -> Result<MoneyValue, FeatureTransactionUIError> {
        guard let rate = sourceToFiatPair else {
            /// A `sourceToFiatPair` is not provided for transactions like a
            /// deposit or a withdraw.
            return .success(amount)
        }
        guard let currency = rate.base.cryptoValue?.currency else {
            return .failure(.unexpectedMoneyValueType(rate.base))
        }
        guard let quote = rate.quote.fiatValue else {
            return .failure(.unexpectedMoneyValueType(rate.quote))
        }
        let pendingTransactionAmount = pendingTransaction?.amount
        switch (pendingTransactionAmount?.cryptoValue, pendingTransactionAmount?.fiatValue) {
        case (.some(let amount), .none):
            /// Just show the `CryptoValue` that the user entered
            /// as this is the `source` currency.
            return .success(.init(cryptoValue: amount))
        case (.none, .some(let amount)):
            /// Convert the `FiatValue` to a `CryptoValue` given the
            /// `quote` from the `sourceToFiatPair` exchange rate.
            return .success(
                amount.convert(
                    usingInverse: quote,
                    currency: currency.currencyType
                )
            )
        default:
            break
        }
        return .success(.zero(currency: currency))
    }

    /// The `MoneyValue` representing the amount received
    /// or the amount that is sent to the given destination.
    func moneyValueFromDestination() -> Result<MoneyValue, FeatureTransactionUIError> {
        let currencyType: CurrencyType
        switch destination {
        case let account as SingleAccount:
            currencyType = account.currencyType
        case let receiveAddress as CryptoReceiveAddress:
            currencyType = receiveAddress.asset.currencyType
        default:
            return .failure(.unexpectedDestinationAccountType)
        }
        guard let exchange = sourceToDestinationPair else {
            return .success(.zero(currency: currencyType))
        }
        guard case .crypto(let currency) = exchange.quote.currency else {
            return .failure(.unexpectedCurrencyType(exchange.quote.currency))
        }
        guard let fiatToSource = sourceToFiatPair?.inverseQuote.quote else {
            return .failure(.emptySourceExchangeRate)
        }
        let pendingTransactionAmount = pendingTransaction?.amount
        switch (
            pendingTransactionAmount?.cryptoValue,
            pendingTransactionAmount?.fiatValue
        ) {
        case (.none, .some(let fiat)):
            // Convert the `FiatValue` amount entered into
            // a `CryptoValue` of source
            // then convert the `CryptoValue` of source to destination
            // using the `quote` of the `sourceToDestinationPair`.
            return .success(
                fiat.convert(using: fiatToSource)
                    .convert(using: exchange.quote)
            )
        case (.some(let crypto), .none):
            // Convert the `CryptoValue` amount entered to destination
            // using the `quote` of the `sourceToDestinationPair`.
            return .success(
                crypto.convert(using: exchange.quote)
            )
        default:
            return .success(.zero(currency: currency))
        }
    }

    /// Converts an FiatValue `available` into CryptoValue if necessary.
    private func availableToAmountCurrency(available: MoneyValue, amount: MoneyValue) -> MoneyValue {
        guard amount.isFiat else {
            return available
        }
        guard let rate = sourceToFiatPair else {
            return .zero(currency: amount.currency)
        }
        return available.convert(using: rate.quote)
    }
}

extension TransactionState {

    var transactionErrorTitle: String {
        errorState.recoveryWarningTitle(for: action).or(Localization.Error.unknownError)
    }

    var transactionErrorDescription: String {
        errorState.recoveryWarningMessage(for: action)
    }
}

enum TransactionFlowStep: Equatable {
    case initial
    // used to start the new flow where source and target are within the amount screen
    case selectSourceTargetAmount
    case selectSource
    case linkPaymentMethod
    case linkACard
    case linkABank
    case linkBankViaWire
    case authorizeOpenBanking
    case enterAddress
    case selectTarget
    case enterAmount
    case recurringBuyFrequencySelector
    case kycChecks
    case validateSource
    case confirmDetail
    case inProgress
    case error
    /// A `UX` view that is shown when a user has interacted
    /// with something that returns a `UX.Dialog`. An example of this
    /// is when the user taps on a badge that indicates a high
    /// failure rate card on the source selection screen
    case uxFromUserInteraction
    /// A `UX` view that is shown when the `TransactionErrorState`
    /// returns a `UX.Dialog`. This happens on the `Enter Amount` screen.
    case uxFromErrorState
    case securityConfirmation
    case errorRecoveryInfo
    case closed
}

extension TransactionFlowStep {

    var label: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }

    var addToBackStack: Bool {
        switch self {
        case .selectSource,
             .selectTarget,
             .enterAddress,
             .enterAmount,
             .selectSourceTargetAmount,
             .errorRecoveryInfo,
             .inProgress,
             .linkBankViaWire:
            return true
        case .closed,
             .initial,
             .kycChecks,
             .error,
             .validateSource,
             .linkPaymentMethod,
             .linkACard,
             .linkABank,
             .uxFromUserInteraction,
             .uxFromErrorState,
             .recurringBuyFrequencySelector,
             .securityConfirmation,
             .confirmDetail,
             .authorizeOpenBanking:
            return false
        }
    }

    /// Returning `true` indicates that the flow gets automatically dismissed. This is usually the case for independent modal flows.
    var goingBackSkipsNavigation: Bool {
        switch self {
        case .kycChecks,
             .linkPaymentMethod,
             .linkACard,
             .linkABank,
             .linkBankViaWire,
             .securityConfirmation,
             .authorizeOpenBanking:
            return true
        case .closed,
             .confirmDetail,
             .enterAddress,
             .enterAmount,
             .selectSourceTargetAmount,
             .errorRecoveryInfo,
             .inProgress,
             .error,
             .initial,
             .selectSource,
             .selectTarget,
             .recurringBuyFrequencySelector,
             .uxFromErrorState,
             .uxFromUserInteraction,
             .validateSource:
            return false
        }
    }
}

enum TransactionExecutionStatus {
    case notStarted
    case inProgress
    case error
    case completed
    case pending

    var isComplete: Bool {
        self == .completed
    }
}
