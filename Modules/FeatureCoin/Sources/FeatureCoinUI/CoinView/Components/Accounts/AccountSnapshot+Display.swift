// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Collections
import FeatureCoinDomain
import SwiftUI

extension Account.Snapshot {

    var color: Color {
        cryptoCurrency.color
    }

    var allowedActions: OrderedSet<Account.Action> {
        switch accountType {
        case .interest:
            [.rewards.withdraw, .rewards.deposit, .rewards.summary]
        case .privateKey:
            [.send, .receive, .swap, .sell, .activity]
        case .trading:
            [.buy, .sell, .swap, .send, .receive]
        case .exchange:
            [.exchange.withdraw, .exchange.deposit]
        case .staking:
            [.staking.deposit, .staking.summary]
        case .activeRewards:
            [.active.withdraw, .active.deposit, .active.summary]
        }
    }

    var importantActions: OrderedSet<Account.Action> {
        switch accountType {
        case .interest:
            [.rewards.withdraw, .rewards.deposit, .rewards.summary]
        case .staking:
            [.staking.deposit, .staking.summary]
        case .activeRewards:
            [.active.deposit, .active.summary]
        default:
            []
        }
    }
}
