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
            return InterestDepositTradingTransactionEngine()
        case .interestWithdraw:
            return InterestWithdrawTradingTransactionEngine()
        case .stakingDeposit:
            return EarnDepositTradingTransactionEngine(product: .staking)
        case .activeRewardsDeposit:
            return EarnDepositTradingTransactionEngine(product: .active)
        case .activeRewardsWithdraw:
            return EarnWithdrawTradingTransactionEngine(product: .active)
        case .stakingWithdraw:
            return EarnWithdrawTradingTransactionEngine(product: .staking)
        default:
            unimplemented()
        }
    }
}
