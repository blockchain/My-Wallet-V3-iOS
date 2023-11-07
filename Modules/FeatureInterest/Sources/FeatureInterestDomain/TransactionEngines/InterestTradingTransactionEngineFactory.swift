// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import ToolKit

/// Transaction Engine Factory for Interest Deposit or Withdraw from/to a Blockchain.com Account.
final class InterestTradingTransactionEngineFactory: InterestTradingTransactionEngineFactoryAPI {
    func build(
        action: AssetAction
    ) -> InterestTransactionEngine {
        switch action {
        case .interestTransfer:
            InterestDepositTradingTransactionEngine()
        case .interestWithdraw:
            InterestWithdrawTradingTransactionEngine()
        case .stakingDeposit:
            EarnDepositTradingTransactionEngine(product: .staking)
        case .activeRewardsDeposit:
            EarnDepositTradingTransactionEngine(product: .active)
        case .activeRewardsWithdraw:
            EarnWithdrawTradingTransactionEngine(product: .active)
        case .stakingWithdraw:
            EarnWithdrawTradingTransactionEngine(product: .staking)
        default:
            unimplemented()
        }
    }
}
