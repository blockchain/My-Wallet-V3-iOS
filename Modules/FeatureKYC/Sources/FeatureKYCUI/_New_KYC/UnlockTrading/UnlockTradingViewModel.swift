// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

private typealias L10n = LocalizationConstants.NewKYC.UnlockTrading

struct UnlockTradingBenefit: Equatable, Identifiable {

    enum Status: Equatable {
        case enabled
        case badge(String)
    }

    let id: String
    let title: String
    let message: String?
    let iconName: String
    let iconTint: Color?
    let iconRenderingMode: Image.TemplateRenderingMode
    let status: Status
}

extension UnlockTradingBenefit {

    static func verifiedBenefits(active: Bool) -> [UnlockTradingBenefit] {
        [
            UnlockTradingBenefit(
                id: "kyc.tier.verified",
                title: L10n.benefit_verifiedTier_title,
                message: nil,
                iconName: "icon-verified",
                iconTint: nil,
                iconRenderingMode: .template,
                status: .badge(active ? L10n.benefit_tier_active_badgeTitle : L10n.benefit_tier_nonActive_badgeTitle)
            ),
            UnlockTradingBenefit(
                id: "swap.crypto.verified",
                title: L10n.benefit_verified_swap_title,
                message: L10n.benefit_verified_swap_info,
                iconName: "icon-swap",
                iconTint: nil,
                iconRenderingMode: .original,
                status: .enabled
            ),
            UnlockTradingBenefit(
                id: "buy.sell.crypto.verified",
                title: L10n.benefit_verified_buyAndSell_title,
                message: L10n.benefit_verified_buyAndSell_info,
                iconName: "icon-buy",
                iconTint: nil,
                iconRenderingMode: .original,
                status: .enabled
            ),
            UnlockTradingBenefit(
                id: "rewards.verified",
                title: L10n.benefit_verified_rewards_title,
                message: L10n.benefit_verified_rewards_info,
                iconName: "icon-interest",
                iconTint: nil,
                iconRenderingMode: .template,
                status: .enabled
            )
        ]
    }
}
