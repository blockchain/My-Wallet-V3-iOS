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
            "buy"
        case .deposit:
            "deposit"
        case .interestTransfer:
            "interestTransfer"
        case .interestWithdraw:
            "interestWithdraw"
        case .stakingDeposit:
            "stakingDeposit"
        case .stakingWithdraw:
            "stakingWithdraw"
        case .activeRewardsDeposit:
            "activeRewardsDeposit"
        case .activeRewardsWithdraw:
            "activeRewardsWithdraw"
        case .receive:
            "receive"
        case .sell:
            "sell"
        case .send:
            "send"
        case .sign:
            "sign"
        case .swap:
            "swap"
        case .viewActivity:
            "viewActivity"
        case .withdraw:
            "withdraw"
        }
    }

    public var debugDescription: String {
        description
    }
}
