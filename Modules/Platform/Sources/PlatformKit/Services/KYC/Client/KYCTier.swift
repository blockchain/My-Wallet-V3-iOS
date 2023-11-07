// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension KYC.Tier {

    public var headline: String? {
        switch self {
        case .verified:
            LocalizationConstants.KYC.freeCrypto
        case .unverified:
            nil
        }
    }

    public var tierDescription: String {
        switch self {
        case .unverified:
            LocalizationConstants.KYC.unverified
        case .verified:
            LocalizationConstants.KYC.verified
        }
    }

    public var requirementsDescription: String {
        switch self {
        case .verified:
            LocalizationConstants.KYC.verificationRequirements
        case .unverified:
            ""
        }
    }

    public var limitTimeframe: String {
        switch self {
        case .unverified:
            "locked"
        case .verified:
            LocalizationConstants.KYC.dailySwapLimit
        }
    }

    public var duration: String {
        switch self {
        case .unverified:
            "0 minutes"
        case .verified:
            LocalizationConstants.KYC.takesTenMinutes
        }
    }
}
