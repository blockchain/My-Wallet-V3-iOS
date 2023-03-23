// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCDomain
import PlatformKit

extension KYC.UserTiers {

    public static var unverified: KYC.UserTiers {
        KYC.UserTiers(
            tiers: [
                .init(tier: .verified, state: .none)
            ]
        )
    }

    public static var verifiedApproved: KYC.UserTiers {
        KYC.UserTiers(
            tiers: [
                .init(tier: .verified, state: .verified)
            ]
        )
    }
}
