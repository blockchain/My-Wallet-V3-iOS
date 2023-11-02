// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureStakingDomain

extension EarnProduct {

    public var title: String {
        switch self {
        case .staking: L10n.staking
        case .savings: L10n.passive
        case .active: L10n.active
        case _: value.capitalized.localized()
        }
    }
}
