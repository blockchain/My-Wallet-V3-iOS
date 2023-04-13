@testable import FeatureTransactionDomain
import MoneyKit
import XCTest

class TransactionLimitsTests: XCTestCase {

    func test_convertLimits_same_currency() throws {
        let startingLimit = TransactionLimits(
            currencyType: .fiat(.USD),
            minimum: MoneyValue.create(minor: 5_00, currency: .fiat(.USD)),
            maximum: MoneyValue.create(minor: 1_000_00, currency: .fiat(.USD)),
            maximumDaily: MoneyValue.create(minor: 10_000_00, currency: .fiat(.USD)),
            maximumAnnual: MoneyValue.create(minor: 100_000_00, currency: .fiat(.USD)),
            effectiveLimit: EffectiveLimit(
                timeframe: .daily,
                value: MoneyValue.create(minor: 1_000_00, currency: .fiat(.USD))
            ),
            suggestedUpgrade: SuggestedLimitsUpgrade(
                requiredTier: .verified,
                available: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                daily: PeriodicLimit(
                    limit: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                monthly: PeriodicLimit(
                    limit: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                yearly: PeriodicLimit(
                    limit: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                )
            ),
            earn: nil
        )
        let convertedLimit = startingLimit.convert(using: .one(currency: .fiat(.USD)))
        XCTAssertEqual(startingLimit, convertedLimit)
    }

    func test_convertLimits_different_currencies() throws {
        let startingLimit = TransactionLimits(
            currencyType: .fiat(.USD),
            minimum: MoneyValue.create(minor: 5_00, currency: .fiat(.USD)),
            maximum: MoneyValue.create(minor: 1_000_00, currency: .fiat(.USD)),
            maximumDaily: MoneyValue.create(minor: 10_000_00, currency: .fiat(.USD)),
            maximumAnnual: MoneyValue.create(minor: 100_000_00, currency: .fiat(.USD)),
            effectiveLimit: EffectiveLimit(
                timeframe: .daily,
                value: MoneyValue.create(minor: 1_000_00, currency: .fiat(.USD))
            ),
            suggestedUpgrade: SuggestedLimitsUpgrade(
                requiredTier: .verified,
                available: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                daily: PeriodicLimit(
                    limit: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                monthly: PeriodicLimit(
                    limit: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                yearly: PeriodicLimit(
                    limit: MoneyValue.create(minor: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                )
            ),
            earn: nil
        )
        let expectedLimit = TransactionLimits(
            currencyType: .fiat(.GBP),
            minimum: MoneyValue.create(minor: 10_00, currency: .fiat(.GBP)),
            maximum: MoneyValue.create(minor: 2_000_00, currency: .fiat(.GBP)),
            maximumDaily: MoneyValue.create(minor: 20_000_00, currency: .fiat(.GBP)),
            maximumAnnual: MoneyValue.create(minor: 200_000_00, currency: .fiat(.GBP)),
            effectiveLimit: EffectiveLimit(
                timeframe: .daily,
                value: MoneyValue.create(minor: 2_000_00, currency: .fiat(.GBP))
            ),
            suggestedUpgrade: SuggestedLimitsUpgrade(
                requiredTier: .verified,
                available: MoneyValue.create(minor: 2_000_000_00, currency: .fiat(.GBP)),
                daily: PeriodicLimit(
                    limit: MoneyValue.create(minor: 2_000_000_00, currency: .fiat(.GBP)),
                    effective: false
                ),
                monthly: PeriodicLimit(
                    limit: MoneyValue.create(minor: 2_000_000_00, currency: .fiat(.GBP)),
                    effective: false
                ),
                yearly: PeriodicLimit(
                    limit: MoneyValue.create(minor: 2_000_000_00, currency: .fiat(.GBP)),
                    effective: false
                )
            ),
            earn: nil
        )
        let convertedLimit = startingLimit.convert(using: MoneyValue.create(minor: 2_00, currency: .fiat(.GBP)))
        XCTAssertEqual(expectedLimit, convertedLimit)
    }
}
