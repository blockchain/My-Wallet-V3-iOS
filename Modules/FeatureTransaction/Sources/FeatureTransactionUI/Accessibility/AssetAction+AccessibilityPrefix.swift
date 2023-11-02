// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension AssetAction {

    /// A `String` used as a prefix for accessibility identifiers.
    /// - Note: This is includes a `.` (dot) at the end of the prefix
    var accessibilityPrefix: String {
        switch self {
        case .activeRewardsDeposit:
            "ActiveRewards.Deposit."
        case .activeRewardsWithdraw:
            "ActiveRewards.Withdraw."
        case .stakingDeposit:
            "Staking.Deposit."
        case .stakingWithdraw:
            "Staking.Deposit."
        case .interestTransfer:
            "Interest.Deposit."
        case .interestWithdraw:
            "Interest.Withdraw."
        case .deposit:
            "Deposit."
        case .receive:
            "Receive."
        case .buy:
            "Buy."
        case .sell:
            "Sell."
        case .sign:
            "Sign."
        case .send:
            "Send."
        case .swap:
            "Swap."
        case .viewActivity:
            "ViewActivity."
        case .withdraw:
            "Withdraw."
        }
    }
}
