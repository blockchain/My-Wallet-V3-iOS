// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainNamespace
import FeatureStakingDomain
import MoneyKit

extension EarnProduct {

    public func id(_ asset: Currency) -> String {
        switch self {
        case .staking:
            return "CryptoStakingAccount.\(asset.code)"
        case .savings:
            return "CryptoInterestAccount.\(asset.code)"
        case .active:
            return "CryptoActiveRewardsAccount.\(asset.code)"
        default:
            return asset.code
        }
    }

    func deposit(_ asset: Currency) -> Tag.Event {
        switch self {
        case .staking:
            return blockchain.ux.asset[asset.code].account[id(asset)].staking.deposit
        case .savings:
            return blockchain.ux.asset[asset.code].account[id(asset)].rewards.deposit
        case .active:
            return blockchain.ux.asset[asset.code].account[id(asset)].active.rewards.deposit
        default:
            return blockchain.ux.asset[asset.code]
        }
    }

    func withdraw(_ asset: Currency) -> Tag.Event {
        switch self {
        case .savings:
            return blockchain.ux.asset[asset.code].account[id(asset)].rewards.withdraw
        case .active:
            return blockchain.ux.asset[asset.code].account[id(asset)].active.rewards.withdraw
        case .staking:
            return blockchain.ux.asset[asset.code].account[id(asset)].staking.withdraw
        default:
            return blockchain.ux.asset[asset.code]
        }
    }

    var totalTitle: String {
        switch self {
        case .staking:
            return L10n.totalStaked
        case .active:
            return L10n.totalSubscribed
        default:
            return L10n.totalDeposited
        }
    }

    var withdrawDisclaimer: String? {
        switch self {
        case .staking:
            return L10n.stakingWithdrawDisclaimer
        default:
            return nil
        }
    }

    var rateSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .staking:
            return .init(
                title: LocalizationConstants.Staking.InfoSheet.Rate.title,
                description: LocalizationConstants.Staking.InfoSheet.Rate.description
            )
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.Rate.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.Rate.description
            )
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.Rate.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.Rate.description
            )
        default:
            return nil
        }
    }

    var totalEarnedSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.Earnings.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.Earnings.description
            )
        default:
            return nil
        }
    }

    var onHoldSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.OnHold.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.OnHold.description
            )
        default:
            return nil
        }
    }

    var triggerSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .active:
            return .init(
                title: LocalizationConstants.ActiveRewards.InfoSheet.Trigger.title,
                description: LocalizationConstants.ActiveRewards.InfoSheet.Trigger.description
            )
        default:
            return nil
        }
    }

    var frequencySheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.Frequency.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.Frequency.description
            )
        default:
            return nil
        }
    }

    var initialHoldPeriodSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.HoldPeriod.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.HoldPeriod.description
            )
        default:
            return nil
        }
    }

    var monthlyEarningsSheetModel: EarnSummaryView.SheetModel? {
        switch self {
        case .savings:
            return .init(
                title: LocalizationConstants.PassiveRewards.InfoSheet.MonthlyEarnings.title,
                description: LocalizationConstants.PassiveRewards.InfoSheet.MonthlyEarnings.description
            )
        default:
            return nil
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
