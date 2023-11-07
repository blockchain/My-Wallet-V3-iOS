// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit

private typealias LocalizedStrings = LocalizationConstants.KYC.LimitsOverview.Feature

extension LimitedTradeFeature {

    var icon: Icon {
        switch id {
        case .send:
            Icon.send
        case .receive:
            Icon.qrCode
        case .swap:
            Icon.swap
        case .sell:
            Icon.sell
        case .buyWithCard:
            Icon.creditcard
        case .buyWithBankAccount:
            Icon.bank
        case .withdraw:
            Icon.bank
        case .rewards:
            Icon.interest
        }
    }

    var title: String {
        switch id {
        case .send:
            LocalizedStrings.featureName_send
        case .receive:
            LocalizedStrings.featureName_receive
        case .swap:
            LocalizedStrings.featureName_swap
        case .sell:
            LocalizedStrings.featureName_sell
        case .buyWithCard:
            LocalizedStrings.featureName_buyWithCard
        case .buyWithBankAccount:
            LocalizedStrings.featureName_buyWithBankAccount
        case .withdraw:
            LocalizedStrings.featureName_withdraw
        case .rewards:
            LocalizedStrings.featureName_rewards
        }
    }

    var message: String? {
        let text: String? = switch id {
        case .send:
            LocalizedStrings.toTradingAccountsOnlyNote
        case .receive:
            LocalizedStrings.fromTradingAccountsOnlyNote
        default:
            nil
        }
        return text
    }

    var valueDisplayString: String {
        guard enabled else {
            return LocalizedStrings.disabled
        }
        guard let limit else {
            return LocalizedStrings.enabled
        }
        return limit.displayString
    }

    var timeframeDisplayString: String? {
        guard enabled, limit?.value != nil else {
            return nil
        }
        return limit?.timeframeDisplayString
    }
}

extension LimitedTradeFeature.PeriodicLimit {

    var displayString: String {
        guard let value else {
            return LocalizedStrings.unlimited
        }
        return value.shortDisplayString
    }

    var timeframeDisplayString: String {
        let format: String = switch period {
        case .day:
            LocalizedStrings.limitedPerDay
        case .month:
            LocalizedStrings.limitedPerMonth
        case .year:
            LocalizedStrings.limitedPerYear
        }
        return format
    }
}
