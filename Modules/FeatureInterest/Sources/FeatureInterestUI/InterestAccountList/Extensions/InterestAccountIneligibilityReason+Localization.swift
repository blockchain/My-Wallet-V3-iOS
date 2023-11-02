// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit

extension InterestAccountIneligibilityReason {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview.Action

    var displayString: String {
        switch self {
        case .eligible:
            LocalizationId.view
        case .tierTooLow:
            LocalizationId.tierTooLow
        case .unsupportedRegion:
            LocalizationId.notAvailable
        case .invalidAddress,
             .other:
            LocalizationId.unavailable
        }
    }
}
