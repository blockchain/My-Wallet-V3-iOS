// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit

extension AssetAction {

    private typealias LocalizationIds = LocalizationConstants.Transaction

    public var name: String {
        switch self {
        case .buy:
            LocalizationIds.buy
        case .viewActivity:
            LocalizationIds.viewActivity
        case .interestTransfer:
            LocalizationIds.transfer
        case .deposit, .stakingDeposit, .activeRewardsDeposit:
            LocalizationIds.deposit
        case .sell:
            LocalizationIds.sell
        case .send:
            LocalizationIds.send
        case .sign:
            fatalError("Impossible.")
        case .receive:
            LocalizationIds.receive
        case .swap:
            LocalizationIds.swap
        case .withdraw,
             .interestWithdraw,
             .stakingWithdraw,
             .activeRewardsWithdraw:
            LocalizationIds.withdraw
        }
    }
}
