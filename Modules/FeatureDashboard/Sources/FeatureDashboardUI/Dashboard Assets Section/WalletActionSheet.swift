// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Accessibility
import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import Localization
import PlatformKit
import PlatformUIKit
import SwiftUI

typealias AccessibilityId = Accessibility.Identifier.WalletActionSheet.Action
typealias LocalizationId = LocalizationConstants.WalletAction.Default

public struct WalletActionSheet: ReducerProtocol {
    private let app: AppProtocol

    public enum Action: Equatable {
        case onActionTapped(AssetAction)
    }

    public struct State: Equatable {
        private var asset: AssetBalanceInfo

        public var actionsToDisplay: [AssetAction] {
            asset.sortedActions.filter(\.allowed)
        }

        public var balanceString: String {
            asset.balance.toDisplayString(includeSymbol: true)
        }

        public var titleString: String {
            asset.currency.name
        }

        public var currencyIcon: Image? {
            asset.currency.fiatCurrency?.image
        }

        public init(with asset: AssetBalanceInfo) {
            self.asset = asset
        }
    }

    public init(app: AppProtocol) {
        self.app = app
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .onActionTapped(let action):
                return .fireAndForget {
                    if let namespaceAction = action.namespaceAction {
                        self.app.post(event: namespaceAction)
                    }
                }
            }
        }
    }
}

extension AssetAction: Identifiable {
    public var id: String {
        name
    }

    var icon: Icon? {
        switch self {
        case .deposit:
            return Icon.bank
        case .withdraw:
            return Icon.cash
        case .viewActivity:
            return Icon.activity
        case .send:
            return Icon.send
        case .receive:
            return Icon.receive
        case .swap:
            return Icon.swap
        case .buy:
            return Icon.plusCircle
        case .sell:
            return Icon.minusCircle
        default:
            return nil
        }
    }

    var name: String {
        switch self {
        case .deposit:
            return LocalizationId.Deposit.title
        case .withdraw:
            return LocalizationId.Withdraw.title
        case .interestTransfer:
            return LocalizationId.Interest.title
        case .viewActivity:
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
        default:
            return ""
        }
    }

    var description: String {
        switch self {
        case .deposit:
            return LocalizationId.Deposit.Fiat.description
        case .withdraw:
            return LocalizationId.Withdraw.description
        case .interestTransfer:
            return LocalizationId.Interest.description
        case .viewActivity:
            return LocalizationId.Activity.description
        case .send:
            return LocalizationId.Send.description
        case .receive:
            return LocalizationId.Receive.description
        case .swap:
            return LocalizationId.Swap.description
        case .buy:
            return LocalizationId.Buy.description
        case .sell:
            return LocalizationId.Sell.description
        default:
            return ""
        }
    }

    var accessibilityId: Accessibility {
        switch self {
        case .deposit:
            return .id(AccessibilityId.deposit)
        case .withdraw:
            return .id(AccessibilityId.withdraw)
        case .viewActivity:
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
        default:
            return .id("")
        }
    }

    var namespaceAction: Tag.Event? {
        switch self {
        case .deposit:
            return blockchain.ux.frequent.action.deposit
        case .withdraw:
            return blockchain.ux.frequent.action.withdraw
        case .viewActivity:
            return nil
        default:
            return nil
        }
    }

    var allowed: Bool {
        switch self {
        case .deposit, .withdraw, .viewActivity:
            return true
        default:
            return false
        }
    }
}
