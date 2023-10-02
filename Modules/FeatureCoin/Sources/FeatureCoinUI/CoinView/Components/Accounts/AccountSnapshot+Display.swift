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
            return [.rewards.withdraw, .rewards.deposit, .rewards.summary]
        case .privateKey:
            return [.send, .receive, .swap, .sell, .activity]
        case .trading:
            return [.buy, .sell, .swap, .send, .receive]
        case .exchange:
            return [.exchange.withdraw, .exchange.deposit]
        case .staking:
            return [.staking.deposit, .staking.summary]
        case .activeRewards:
            return [.active.withdraw, .active.deposit, .active.summary]
        }
    }

    var importantActions: OrderedSet<Account.Action> {
        switch accountType {
        case .interest:
            return [.rewards.withdraw, .rewards.deposit, .rewards.summary]
        case .staking:
            return [.staking.deposit, .staking.summary]
        case .activeRewards:
            return [.active.deposit, .active.summary]
        default:
            return []
        }
    }
}
