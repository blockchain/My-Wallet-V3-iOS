// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public enum AssetAction: String, Equatable, CaseIterable, Codable {
    case buy
    case deposit
    case interestTransfer = "interest_transfer"
    case interestWithdraw = "interest_withdraw"
    case stakingDeposit = "staking_deposit"
    case receive
    case sell
    case send
    case sign
    case swap
    case viewActivity = "view_activity"
    case withdraw
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
