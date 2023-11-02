// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainNamespace
import FeatureStakingDomain
import MoneyKit

extension EarnProduct {

    public func id(_ asset: Currency) -> String {
        switch self {
        case .staking:
            "CryptoStakingAccount.\(asset.code)"
        case .savings:
            "CryptoInterestAccount.\(asset.code)"
        case .active:
            "CryptoActiveRewardsAccount.\(asset.code)"
        default:
            asset.code
        }
    }

    func deposit(_ asset: Currency) -> Tag.Event {
        switch self {
        case .staking:
            blockchain.ux.asset[asset.code].account[id(asset)].staking.deposit
        case .savings:
            blockchain.ux.asset[asset.code].account[id(asset)].rewards.deposit
        case .active:
            blockchain.ux.asset[asset.code].account[id(asset)].active.rewards.deposit
        default:
            blockchain.ux.asset[asset.code]
        }
    }

    func withdraw(_ asset: Currency) -> Tag.Event {
        switch self {
        case .savings:
            blockchain.ux.asset[asset.code].account[id(asset)].rewards.withdraw
        case .active:
            blockchain.ux.asset[asset.code].account[id(asset)].active.rewards.withdraw
        case .staking:
            blockchain.ux.asset[asset.code].account[id(asset)].staking.withdraw
        default:
            blockchain.ux.asset[asset.code]
        }
    }

    var totalTitle: String {
        switch self {
        case .staking:
            L10n.totalStaked
        case .active:
            L10n.totalSubscribed
        default:
            L10n.totalDeposited
        }
    }

    var withdrawDisclaimer: String? {
        switch self {
        case .staking:
            L10n.stakingWithdrawDisclaimer
        default:
            nil
        }
    }

    var rateSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .staking:
            .init(
                title: Localization.Staking.InfoSheet.Rate.title,
                description: Localization.Staking.InfoSheet.Rate.description
            )
        case .savings:
            .init(
                title: Localization.PassiveRewards.InfoSheet.Rate.title,
                description: Localization.PassiveRewards.InfoSheet.Rate.description
            )
        case .active:
            .init(
                title: Localization.ActiveRewards.InfoSheet.Rate.title,
                description: Localization.ActiveRewards.InfoSheet.Rate.description
            )
        default:
            nil
        }
    }

    var totalEarnedSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            .init(
                title: Localization.ActiveRewards.InfoSheet.Earnings.title,
                description: Localization.ActiveRewards.InfoSheet.Earnings.description
            )
        default:
            nil
        }
    }

    var onHoldSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            .init(
                title: Localization.ActiveRewards.InfoSheet.OnHold.title,
                description: Localization.ActiveRewards.InfoSheet.OnHold.description
            )
        default:
            nil
        }
    }

    var triggerSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            .init(
                title: Localization.ActiveRewards.InfoSheet.Trigger.title,
                description: Localization.ActiveRewards.InfoSheet.Trigger.description
            )
        default:
            nil
        }
    }

    var frequencySheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            .init(
                title: Localization.PassiveRewards.InfoSheet.Frequency.title,
                description: Localization.PassiveRewards.InfoSheet.Frequency.description
            )
        default:
            nil
        }
    }

    var initialHoldPeriodSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            .init(
                title: Localization.PassiveRewards.InfoSheet.HoldPeriod.title,
                description: Localization.PassiveRewards.InfoSheet.HoldPeriod.description
            )
        default:
            nil
        }
    }

    var monthlyEarningsSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            .init(
                title: Localization.PassiveRewards.InfoSheet.MonthlyEarnings.title,
                description: Localization.PassiveRewards.InfoSheet.MonthlyEarnings.description
            )
        default:
            nil
        }
    }

    var nextPaymentDate: String? {
        switch self {
        case .savings:
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.day = 1
            let month = components.month ?? 0
            components.month = month + 1
            components.calendar = .current
            let next = components.date ?? Date()
            return DateFormatter.long.string(from: next)
        default:
            return nil
        }
    }
}
