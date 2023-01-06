// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension AssetAction {

    /// A `String` used as a prefix for accessibility identifiers.
    /// - Note: This is includes a `.` (dot) at the end of the prefix
    var accessibilityPrefix: String {
        switch self {
        case .stakingDeposit:
            return "Staking.Deposit."
        case .interestTransfer:
            return "Interest.Deposit."
        case .interestWithdraw:
            return "Interest.Withdraw."
        case .deposit:
            return "Deposit."
        case .receive:
            return "Receive."
        case .buy:
            return "Buy."
        case .sell:
            return "Sell."
        case .sign:
            return "Sign."
        case .send:
            return "Send."
        case .swap:
            return "Swap."
        case .viewActivity:
            return "ViewActivity."
        case .withdraw:
            return "Withdraw."
        }
    }
}
