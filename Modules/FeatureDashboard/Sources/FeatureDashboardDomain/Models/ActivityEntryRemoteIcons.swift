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
            "buy"
        case .deposit:
            "deposit"
        case .earn:
            "earn"
        case .pending:
            "pending"
        case .receive:
            "receive"
        case .recurringBuy:
            "recurring_buy"
        case .sell:
            "sell"
        case .send:
            "send"
        case .signature:
            "signature"
        case .swap:
            "swap"
        case .withdraw:
            "withdraw"
        }
    }

    func url(mode: Mode) -> String {
        base + title + "_\(mode.rawValue).svg"
    }
}
