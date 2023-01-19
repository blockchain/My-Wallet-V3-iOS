// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

enum PendingTransctionStateProviderFactory {
    static func pendingTransactionStateProvider(action: AssetAction) -> PendingTransactionStateProviding {
        switch action {
        case .withdraw:
            return WithdrawPendingTransactionStateProvider()
        case .deposit:
            return DepositPendingTransactionStateProvider()
        case .send:
            return SendPendingTransactionStateProvider()
        case .sign:
            return SignPendingTransactionStateProvider()
        case .swap:
            return SwapPendingTransactionStateProvider()
        case .buy:
            return BuyPendingTransactionStateProvider()
        case .sell:
            return SellPendingTransactionStateProvider()
        case .interestTransfer:
            return InterestTransferTransactionStateProvider()
        case .stakingDeposit:
            return StakingDepositTransactionStateProvider()
        case .activeRewardsDeposit:
            return ActiveRewardsDepositTransactionStateProvider()
        case .activeRewardsWithdraw:
            return ActiveRewardsWithdrawTransactionStateProvider()
        case .interestWithdraw:
            return InterestWithdrawTransactionStateProvider()
        case .viewActivity,
             .receive:
            unimplemented()
        }
    }
}
