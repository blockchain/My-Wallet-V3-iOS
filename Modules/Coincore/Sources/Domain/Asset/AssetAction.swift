// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum AssetAction: String, Equatable, CaseIterable, Codable {
    case buy
    case deposit
    case interestTransfer = "interest_transfer"
    case interestWithdraw = "interest_withdraw"
    case stakingDeposit = "staking_deposit"
    case stakingWithdraw = "staking_withdraw"
    case activeRewardsDeposit = "active_rewards_deposit"
    case activeRewardsWithdraw = "active_rewards_withdraw"
    case receive
    case sell
    case send
    case sign
    case swap
    case viewActivity = "view_activity"
    case withdraw
}

extension AssetAction: Identifiable {
    public var id: String { rawValue }
}

extension AssetAction: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        switch self {
        case .buy:
            return "buy"
        case .deposit:
            return "deposit"
        case .interestTransfer:
            return "interestTransfer"
        case .interestWithdraw:
            return "interestWithdraw"
        case .stakingDeposit:
            return "stakingDeposit"
        case .stakingWithdraw:
            return "stakingWithdraw"
        case .activeRewardsDeposit:
            return "activeRewardsDeposit"
        case .activeRewardsWithdraw:
            return "activeRewardsWithdraw"
        case .receive:
            return "receive"
        case .sell:
            return "sell"
        case .send:
            return "send"
        case .sign:
            return "sign"
        case .swap:
            return "swap"
        case .viewActivity:
            return "viewActivity"
        case .withdraw:
            return "withdraw"
        }
    }

    public var debugDescription: String {
        description
    }
}
