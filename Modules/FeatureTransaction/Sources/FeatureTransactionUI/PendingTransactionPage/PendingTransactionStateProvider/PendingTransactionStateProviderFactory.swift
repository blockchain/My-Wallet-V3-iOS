// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

enum PendingTransctionStateProviderFactory {
    static func pendingTransactionStateProvider(action: AssetAction) -> PendingTransactionStateProviding {
        switch action {
        case .withdraw:
            WithdrawPendingTransactionStateProvider()
        case .deposit:
            DepositPendingTransactionStateProvider()
        case .send:
            SendPendingTransactionStateProvider()
        case .sign:
            SignPendingTransactionStateProvider()
        case .swap:
            SwapPendingTransactionStateProvider()
        case .buy:
            BuyPendingTransactionStateProvider()
        case .sell:
            SellPendingTransactionStateProvider()
        case .interestTransfer:
            InterestTransferTransactionStateProvider()
        case .stakingDeposit:
            StakingDepositTransactionStateProvider()
        case .stakingWithdraw:
            StakingWithdrawTransactionStateProvider()
        case .activeRewardsDeposit:
            ActiveRewardsDepositTransactionStateProvider()
        case .activeRewardsWithdraw:
            ActiveRewardsWithdrawTransactionStateProvider()
        case .interestWithdraw:
            InterestWithdrawTransactionStateProvider()
        case .viewActivity,
             .receive:
            unimplemented()
        }
    }
}
