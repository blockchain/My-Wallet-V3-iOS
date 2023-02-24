// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeaturePlaidDomain
import MoneyKit
import PlatformKit
import ToolKit

public struct PendingTransaction: Equatable {

    public enum EngineStateKey: String {
        case quoteSubscription
        case userTiers
        case memo
        case bitpayTimer
        case gasPrice
        case gasLimit
        case btc
        case delegatedeCustodyFee
        case delegatedeCustodySendMax
        case delegatedeCustodyData
    }

    public var amount: MoneyValue
    /// The source account actionable balance minus the fees for the current fee level.
    public var available: MoneyValue
    public var selectedFiatCurrency: FiatCurrency
    public var feeSelection: FeeSelection
    public var feeAmount: MoneyValue
    public var feeForFullAvailable: MoneyValue
    public var recurringBuyFrequency: RecurringBuy.Frequency = .unknown
    public var eligibilityAndNextPaymentMethodRecurringBuys: [EligibleAndNextPaymentRecurringBuy] = []
    public var paymentsDepositTerms: PaymentsDepositTerms?
    public var eligibleAndNextPaymentRecurringBuy: EligibleAndNextPaymentRecurringBuy {
        eligibilityAndNextPaymentMethodRecurringBuys
            .first(where: { $0.frequency == recurringBuyFrequency }) ?? .oneTime
    }

    /// The list of `TransactionConfirmation`.
    /// To update this value, use methods `update(confirmations:)` and `insert(confirmations:)`
    public private(set) var confirmations: [TransactionConfirmation] = []

    public var validationState: TransactionValidationState = .uninitialized
    public let engineState: Atomic<[EngineStateKey: Any]> = Atomic([:])

    public var limits: TransactionLimits? {
        get { _limits.value }
        set { _limits = Reference(newValue) }
    }

    public struct Quote: Equatable {
        let id: String
        let amount: MoneyValue
    }

    public var quote: Quote?

    // this struct has become too big for Swift to handle :(
    private var _limits: Reference<TransactionLimits?>

    public init(
        amount: MoneyValue,
        available: MoneyValue,
        feeAmount: MoneyValue,
        feeForFullAvailable: MoneyValue,
        feeSelection: FeeSelection,
        selectedFiatCurrency: FiatCurrency,
        paymentsDepositTerms: PaymentsDepositTerms? = nil,
        limits: TransactionLimits? = nil
    ) {
        self.amount = amount
        self.available = available
        self.feeAmount = feeAmount
        self.feeForFullAvailable = feeForFullAvailable
        self.feeSelection = feeSelection
        self.selectedFiatCurrency = selectedFiatCurrency
        self.paymentsDepositTerms = paymentsDepositTerms
        self._limits = Reference(limits)
    }

    public func update(validationState: TransactionValidationState) -> PendingTransaction {
        var copy = self
        copy.validationState = validationState
        return copy
    }

    public func update(quote: Quote) -> PendingTransaction {
        var copy = self
        copy.quote = quote
        return copy
    }

    public func updateRecurringBuyFrequency(_ frequency: RecurringBuy.Frequency) -> PendingTransaction {
        var copy = self
        copy.recurringBuyFrequency = frequency
        return copy
    }

    public func updatePaymentMethodEligibilityAndNextPaymentDates(
        _ eligibilityAndNextPaymentMethodRecurringBuys: [EligibleAndNextPaymentRecurringBuy]
    ) -> PendingTransaction {
        var copy = self
        copy.eligibilityAndNextPaymentMethodRecurringBuys = eligibilityAndNextPaymentMethodRecurringBuys
        return copy
    }

    public func update(amount: MoneyValue) -> PendingTransaction {
        var copy = self
        copy.amount = amount
        return copy
    }

    public func update(amount: MoneyValue, available: MoneyValue) -> PendingTransaction {
        var copy = self
        copy.amount = amount
        copy.available = available
        return copy
    }

    public func update(selectedFeeLevel: FeeLevel) -> PendingTransaction {
        var copy = self
        copy.feeSelection = copy.feeSelection.update(selectedLevel: selectedFeeLevel)
        return copy
    }

    public func update(availableFeeLevels: Set<FeeLevel>) -> PendingTransaction {
        var copy = self
        copy.feeSelection = copy.feeSelection.update(availableFeeLevels: availableFeeLevels)
        return copy
    }

    public func update(paymentsDepositTerms: PaymentsDepositTerms?) -> PendingTransaction {
        var copy = self
        copy.paymentsDepositTerms = paymentsDepositTerms
        return copy
    }

    public func update(selectedFeeLevel: FeeLevel, customFeeAmount: MoneyValue?) -> PendingTransaction {
        var copy = self
        copy.feeSelection = copy.feeSelection.update(
            customAmount: customFeeAmount,
            selectedLevel: selectedFeeLevel
        )
        return copy
    }

    public func update(
        amount: MoneyValue,
        available: MoneyValue,
        fee: MoneyValue,
        feeForFullAvailable: MoneyValue
    ) -> PendingTransaction {
        var copy = self
        copy.amount = amount
        copy.available = available
        copy.feeAmount = fee
        copy.feeForFullAvailable = feeForFullAvailable
        return copy
    }

    public func update(fee: MoneyValue) -> PendingTransaction {
        var copy = self
        copy.feeAmount = fee
        return copy
    }

    /// Insert a `TransactionConfirmation`, replacing any previous value with the same confirmation type.
    public func insert(confirmation: TransactionConfirmation, prepend: Bool = false) -> PendingTransaction {
        var copy = self
        if let idx = copy.confirmations.firstIndex(where: {
            String(describing: Swift.type(of: $0)) == String(describing: Swift.type(of: confirmation))
                && $0.type == confirmation.type
        }) {
            copy.confirmations.replaceSubrange(idx...idx, with: [confirmation])
        } else {
            prepend ? copy.confirmations.insert(confirmation, at: 0) : copy.confirmations.append(confirmation)
        }
        return copy
    }

    /// Appends content of the given list into the current confirmations list.
    public func insert(confirmations: [TransactionConfirmation]) -> PendingTransaction {
        var copy = self
        copy.confirmations.append(contentsOf: confirmations)
        return copy
    }

    /// Update (replace) the confirmations list with the given value.
    public func update(confirmations: [TransactionConfirmation]) -> PendingTransaction {
        var copy = self
        copy.confirmations = confirmations
        return copy
    }

    /// Removes confirmations of the given type from the confirmations list.
    public func remove(optionType: TransactionConfirmationKind) -> PendingTransaction {
        var copy = self
        copy.confirmations = confirmations.filter { $0.type != optionType }
        return copy
    }

    public func hasFeeLevelChanged(newLevel: FeeLevel, newAmount: MoneyValue) -> Bool {
        feeLevel != newLevel || (feeLevel == .custom && newAmount != customFeeAmount)
    }

    // MARK: - Equatable

    public static func == (lhs: PendingTransaction, rhs: PendingTransaction) -> Bool {
        guard lhs.amount == rhs.amount else { return false }
        guard lhs.feeAmount == rhs.feeAmount else { return false }
        guard lhs.available == rhs.available else { return false }
        guard lhs.feeSelection == rhs.feeSelection else { return false }
        guard lhs.feeForFullAvailable == rhs.feeForFullAvailable else { return false }
        guard lhs.selectedFiatCurrency == rhs.selectedFiatCurrency else { return false }
        guard lhs.feeLevel == rhs.feeLevel else { return false }
        guard lhs.limits == rhs.limits else { return false }
        guard lhs.validationState == rhs.validationState else { return false }
        guard lhs.quote == rhs.quote else { return false }
        guard lhs.recurringBuyFrequency == rhs.recurringBuyFrequency else { return false }
        guard lhs.eligibilityAndNextPaymentMethodRecurringBuys == rhs.eligibilityAndNextPaymentMethodRecurringBuys else { return false }
        guard lhs.paymentsDepositTerms == rhs.paymentsDepositTerms else { return false }
        guard TransactionConfirmations.areEqual(lhs.confirmations, rhs.confirmations) else { return false }
        return true
    }
}

// MARK: - Limtis

extension PendingTransaction {

    public var normalizedLimits: TransactionLimits {
        TransactionLimits(
            currencyType: minLimit.currencyType,
            minimum: minLimit,
            maximum: maxLimit,
            maximumDaily: maxDailyLimit,
            maximumAnnual: maxAnnualLimit,
            effectiveLimit: limits?.effectiveLimit ?? EffectiveLimit(timeframe: .single, value: maxLimit),
            suggestedUpgrade: limits?.suggestedUpgrade,
            earn: limits?.earn
        )
    }

    public var minLimit: MoneyValue {
        limits?.minimum ?? .zero(currency: amount.currency)
    }

    public var maxLimit: MoneyValue {
        limits?.maximum ?? available
    }

    public var maxDailyLimit: MoneyValue {
        limits?.maximumDaily ?? maxLimit
    }

    public var maxAnnualLimit: MoneyValue {
        limits?.maximumAnnual ?? maxDailyLimit
    }

    /// The minimum spending limit
    public var minSpendable: MoneyValue {
        limits?.minimum ?? .zero(currency: amount.currency)
    }

    /// The maximum amount the user can spend. We compare the amount entered to the
    /// `limits.minimum` or `maximumLimit` as `CryptoValues` and return whichever is smaller.
    public var maxSpendable: MoneyValue {
        guard let maxLimit = limits?.maximum else {
            return available
        }
        guard let availableMaximumLimit = try? maxLimit - feeAmount else {
            return available
        }
        let minAvailable: MoneyValue = (try? .min(available, availableMaximumLimit)) ?? available
        return (try? .max(.zero(currency: amount.currency), minAvailable)) ?? available // ensure the value is >= 0
    }

    public var maxSpendableDaily: MoneyValue {
        (try? .min(maxDailyLimit, maxSpendable)) ?? .zero(currency: amount.currency)
    }

    public var maxSpendableAnnually: MoneyValue {
        (try? .min(maxAnnualLimit, maxSpendable)) ?? .zero(currency: amount.currency)
    }
}

// MARK: - Fees

extension PendingTransaction {

    public var feeLevel: FeeLevel {
        feeSelection.selectedLevel
    }

    public var availableFeeLevels: Set<FeeLevel> {
        feeSelection.availableLevels
    }

    public var customFeeAmount: MoneyValue? {
        feeSelection.customAmount
    }
}

// MARK: - Term Options

extension PendingTransaction {

    public var termsOptionValue: Bool {
        guard let confirmation = confirmations
            .first(where: { $0.type == .agreementInterestTandC })
        else {
            return false
        }
        guard let option = confirmation as? TransactionConfirmations.AnyBoolOption<Bool> else { return false }
        return option.value
    }

    public var agreementOptionValue: Bool {
        guard let confirmation = confirmations
            .first(where: { $0.type == .agreementInterestTransfer })
        else {
            return false
        }
        guard let option = confirmation as? TransactionConfirmations.AnyBoolOption<Bool> else { return false }
        return option.value
    }

    public var agreementAROptionValue: Bool {
        guard let confirmation = confirmations
            .first(where: { $0.type == .agreementARDeposit })
        else {
            return false
        }
        guard let option = confirmation as? TransactionConfirmations.AnyBoolOption<Bool> else { return false }
        return option.value
    }
}

// MARK: - Init Conveniences

extension PendingTransaction {

    public static func zero(currencyType: CurrencyType) -> PendingTransaction {
        .init(
            amount: .zero(currency: currencyType),
            available: .zero(currency: currencyType),
            feeAmount: .zero(currency: currencyType),
            feeForFullAvailable: .zero(currency: currencyType),
            // TODO: Handle alternate currency types
            feeSelection: .empty(asset: currencyType),
            selectedFiatCurrency: .USD
        )
    }
}

extension PendingTransaction {

    public var missingPriceDescription: String {
        "PendingTransaction(amount: \(amount), selectedFiatCurrency: \(selectedFiatCurrency))"
    }
}
