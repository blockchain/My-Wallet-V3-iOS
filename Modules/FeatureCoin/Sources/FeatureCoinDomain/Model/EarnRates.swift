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
            nil
        case .interest:
            interestRate
        case .staking:
            stakingRate
        case .activeRewards:
            activeRewardsRate
        }
    }
}
