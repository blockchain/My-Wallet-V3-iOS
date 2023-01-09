// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureStakingDomain

extension EarnProduct {

    public var title: String {
        switch self {
        case .staking: return L10n.staking
        case .savings: return L10n.passive
        case _: return value.capitalized.localized()
        }
    }
}
