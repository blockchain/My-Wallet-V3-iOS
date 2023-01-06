// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension AssetAction {

    var allowsBackButton: Bool {
        switch self {
        case .send,
             .deposit,
             .receive,
             .buy,
             .sell,
             .swap,
             .withdraw,
             .viewActivity,
             .interestWithdraw,
             .interestTransfer,
             .stakingDeposit:
            return true
        case .sign:
            return false
        }
    }
}
