// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct EarnRates: Equatable {
    public let stakingRate: Double?
    public let interestRate: Double?
    public let activeRewardsRate: Double?

    public static let zero = EarnRates(stakingRate: 0, interestRate: 0, activeRewardsRate: 0)

    public init(
        stakingRate: Double?,
        interestRate: Double?,
        activeRewardsRate: Double?
    ) {
        self.stakingRate = stakingRate
        self.interestRate = interestRate
        self.activeRewardsRate = activeRewardsRate
    }

    public func rate(accountType: Account.AccountType) -> Double? {
        switch accountType {
        case .privateKey,
             .trading,
             .exchange:
            return nil
        case .interest:
            return interestRate
        case .staking:
            return stakingRate
        case .activeRewards:
            return activeRewardsRate
        }
    }
}
