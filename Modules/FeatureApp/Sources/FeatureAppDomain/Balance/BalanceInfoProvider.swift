// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public enum BalanceInfoError: LocalizedError {
    case unableToRetrieve
}

public struct BalanceInfo: Codable, Equatable {
    public let balance: MoneyValue

    /// A percentage change of currenct and previou balance, ranges from 0...1
    public let changePercentage: String?
    ///
    public let change: MoneyValue?

    public var changePercentageValue: Decimal? {
        guard let changePercentage else {
            return nil
        }
        return Decimal(string: changePercentage)
    }

    public init(
        balance: MoneyValue,
        changePercentage: String? = nil,
        change: MoneyValue? = nil
    ) {
        self.balance = balance
        self.changePercentage = changePercentage
        self.change = change
    }
}

/// Provides a info with change, and percentage change between two MoneyValues
/// - Parameters:
///   - currentBalance: The current `MoneyValue`
///   - previousBalance: The previous `MoneyValue`
/// - Returns: A `Result<BalanceInfo, BalanceInfoError>`
public func balanceInfoBetween(
    currentBalance: MoneyValue,
    previousBalance: MoneyValue
) -> Result<BalanceInfo, BalanceInfoError> {
    do {
        let percentage: Decimal
        let change = try currentBalance - previousBalance
        if currentBalance.isZero {
            percentage = 0
        } else {
            if previousBalance.isZero || previousBalance.isNegative {
                percentage = 0
            } else {
                percentage = try change.percentage(in: previousBalance)
            }
        }
        let info = BalanceInfo(
            balance: currentBalance,
            changePercentage: String(describing: percentage),
            change: change
        )
        return .success(info)
    } catch {
        return .failure(.unableToRetrieve)
    }
}
