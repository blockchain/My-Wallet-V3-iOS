// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Until we get the trading activity from APIs, this an the alternative...

private let base = "https://login.blockchain.com/static/asset/icon/activity_icons/"

enum Mode: String {
    case light
    case dark
}

enum ActivityRemoteIcons {
    case buy
    case deposit
    case earn
    case pending
    case receive
    case recurringBuy
    case sell
    case send
    case signature
    case swap
    case withdraw

    var title: String {
        switch self {
        case .buy:
            return "buy"
        case .deposit:
            return "deposit"
        case .earn:
            return "earn"
        case .pending:
            return "pending"
        case .receive:
            return "receive"
        case .recurringBuy:
            return "recurring_buy"
        case .sell:
            return "sell"
        case .send:
            return "send"
        case .signature:
            return "signature"
        case .swap:
            return "swap"
        case .withdraw:
            return "withdraw"
        }
    }

    func url(mode: Mode) -> String {
        base + title + "_\(mode.rawValue).svg"
    }
}
