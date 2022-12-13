// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import RxDataSources

/// Actions that are associated with a `default`
/// `WalletActionCellType`
public enum WalletAction: Comparable, IdentifiableType {

    // MARK: Types

    typealias AccessibilityId = Accessibility.Identifier.WalletActionSheet.Action
    typealias LocalizationId = LocalizationConstants.WalletAction.Default

    public typealias Identity = String

    case buy
    case sell
    case receive
    case send
    case swap
    case deposit
    case withdraw
    case interest
    case activity

    public var identity: String {
        name
    }

    var imageName: String {
        switch self {
        case .deposit:
            return "deposit-icon"
        case .withdraw:
            return "withdraw-icon"
        case .interest:
            // TODO: Add interest image
            return ""
        case .activity:
            return "clock-icon"
        case .send:
            return "send-icon"
        case .receive:
            return "receive-icon"
        case .swap:
            return "transfer-icon"
        case .buy:
            return "plus-icon"
        case .sell:
            return "minus-icon"
        }
    }

    var name: String {
        switch self {
        case .deposit:
            return LocalizationId.Deposit.title
        case .withdraw:
            return LocalizationId.Withdraw.title
        case .interest:
            return LocalizationId.Interest.title
        case .activity:
            return LocalizationId.Activity.title
        case .send:
            return LocalizationId.Send.title
        case .receive:
            return LocalizationId.Receive.title
        case .swap:
            return LocalizationId.Swap.title
        case .buy:
            return LocalizationId.Buy.title
        case .sell:
            return LocalizationId.Sell.title
        }
    }

    var accessibilityId: Accessibility {
        switch self {
        case .deposit:
            return .id(AccessibilityId.deposit)
        case .withdraw:
            return .id(AccessibilityId.withdraw)
        case .interest:
            return .id(AccessibilityId.interest)
        case .activity:
            return .id(AccessibilityId.activity)
        case .send:
            return .id(AccessibilityId.send)
        case .receive:
            return .id(AccessibilityId.receive)
        case .swap:
            return .id(AccessibilityId.swap)
        case .buy:
            return .id(AccessibilityId.buy)
        case .sell:
            return .id(AccessibilityId.sell)
        }
    }
}
