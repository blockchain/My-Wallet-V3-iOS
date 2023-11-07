// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import FeatureStakingDomain
import MoneyKit
import PlatformKit

/// Use this struct to fill transaction data in `TransactionEngine`s.
public struct TransactionLimits: Equatable {

    public let currencyType: CurrencyType
    public let minimum: MoneyValue?
    public let maximum: MoneyValue?
    public let maximumDaily: MoneyValue?
    public let maximumAnnual: MoneyValue?
    public let effectiveLimit: EffectiveLimit?
    public let suggestedUpgrade: SuggestedLimitsUpgrade?
    public let earn: EarnCurrencyLimit?

    public init(
        currencyType: CurrencyType,
        minimum: MoneyValue?,
        maximum: MoneyValue?,
        maximumDaily: MoneyValue?,
        maximumAnnual: MoneyValue?,
        effectiveLimit: EffectiveLimit?,
        suggestedUpgrade: SuggestedLimitsUpgrade?,
        earn: EarnCurrencyLimit?
    ) {
        self.currencyType = currencyType
        self.minimum = minimum
        self.maximum = maximum
        self.maximumDaily = maximumDaily
        self.maximumAnnual = maximumAnnual
        self.effectiveLimit = effectiveLimit
        self.suggestedUpgrade = suggestedUpgrade
        self.earn = earn
    }
}

extension TransactionLimits {

    public static func zero(for currency: CurrencyType) -> TransactionLimits {
        fixedValue(.zero(currency: currency))
    }

    public static func noLimits(for currency: CurrencyType) -> TransactionLimits {
        fixedValue(currencyType: currency)
    }

    public static func fixedValue(_ value: MoneyValue) -> TransactionLimits {
        fixedValue(value, currencyType: value.currencyType)
    }

    public static func fixedValue(currencyType: CurrencyType) -> TransactionLimits {
        fixedValue(nil, currencyType: currencyType)
    }

    private static func fixedValue(_ value: MoneyValue?, currencyType: CurrencyType) -> TransactionLimits {
        if let value, value.currencyType != currencyType {
            fatalError("The currency type must match the money value's currency type, when present")
        }
        let effectiveLimit: EffectiveLimit? = if let value {
            .init(timeframe: .single, value: value)
        } else {
            nil
        }
        return TransactionLimits(
            currencyType: currencyType,
            minimum: value,
            maximum: value,
            maximumDaily: value,
            maximumAnnual: value,
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: nil,
            earn: nil
        )
    }
}

// MARK: - Currency Conversion

extension TransactionLimits {

    public func convert(using exchangeRate: MoneyValue) -> TransactionLimits {
        TransactionLimits(
            currencyType: exchangeRate.currencyType,
            minimum: minimum?.convert(using: exchangeRate),
            maximum: maximum?.convert(using: exchangeRate),
            maximumDaily: maximumDaily?.convert(using: exchangeRate),
            maximumAnnual: maximumAnnual?.convert(using: exchangeRate),
            effectiveLimit: effectiveLimit?.convert(using: exchangeRate),
            suggestedUpgrade: suggestedUpgrade?.convert(using: exchangeRate),
            earn: earn
        )
    }
}
