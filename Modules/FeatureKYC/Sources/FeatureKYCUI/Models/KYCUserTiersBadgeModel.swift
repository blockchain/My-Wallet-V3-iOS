// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import UIKit

struct KYCUserTiersBadgeModel {
    let color: UIColor
    let text: String

    init?(response: KYC.UserTiers) {
        let tiers = response.tiers

        // Note that we are only accounting for  `KYCVerified`.
        // Currently we aren't supporting other tiers outside of that.
        // If we add additional types to `KYC.Tier` we'll want to update this.
        guard tiers.isNotEmpty else { return nil }
        guard let verified = tiers.filter({ $0.tier == .verified }).first else { return nil }
        let locked = verified.state == .none
        guard locked == false else { return nil }
        self.color = KYCUserTiersBadgeModel.badgeColor(for: verified)
        self.text = KYCUserTiersBadgeModel.badgeText(for: verified)
    }

    private static func badgeColor(for tier: KYC.UserTier) -> UIColor {
        switch tier.state {
        case .none:
            .unverified
        case .rejected:
            .unverified
        case .pending, .under_review:
            .pending
        case .verified:
            .verified
        }
    }

    private static func badgeText(for tier: KYC.UserTier) -> String {
        switch tier.state {
        case .none:
            badgeString(tier: tier, description: LocalizationConstants.KYC.accountUnverifiedBadge)
        case .rejected:
            LocalizationConstants.KYC.verificationFailedBadge
        case .pending, .under_review:
            badgeString(tier: tier, description: LocalizationConstants.KYC.accountInReviewBadge)
        case .verified:
            badgeString(tier: tier, description: LocalizationConstants.KYC.accountApprovedBadge)
        }
    }

    private static func badgeString(tier: KYC.UserTier, description: String) -> String {
        localisedName(for: tier) + " - " + description
    }

    private static func localisedName(for tier: KYC.UserTier) -> String {
        switch tier.tier {
        case .unverified:
            LocalizationConstants.KYC.unverified
        case .verified:
            LocalizationConstants.KYC.verified
        }
    }
}
