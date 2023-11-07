// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import ToolKit

/// Transaction Engine Factory for Interest Deposit or Withdraw from/to a Non Custodial Account.
final class InterestOnChainTransactionEngineFactory: InterestOnChainTransactionEngineFactoryAPI {
    func build(
        action: AssetAction,
        onChainEngine: OnChainTransactionEngine
    ) -> InterestTransactionEngine {
        switch action {
        case .interestTransfer:
            InterestDepositOnChainTransactionEngine(
                onChainEngine: onChainEngine
            )
        case .interestWithdraw:
            InterestWithdrawOnChainTransactionEngine()
        case .stakingDeposit:
            EarnDepositOnChainTransactionEngine(product: .staking, onChainEngine: onChainEngine)
        case .activeRewardsDeposit:
            EarnDepositOnChainTransactionEngine(product: .active, onChainEngine: onChainEngine)
        default:
            unimplemented()
        }
    }
}
