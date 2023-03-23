// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension KYC.Tier {

    public var headline: String? {
        switch self {
        case .verified:
            return LocalizationConstants.KYC.freeCrypto
        case .unverified:
            return nil
        }
    }

    public var tierDescription: String {
        switch self {
        case .unverified:
            return LocalizationConstants.KYC.unverified
        case .verified:
            return LocalizationConstants.KYC.verified
        }
    }

    public var requirementsDescription: String {
        switch self {
        case .verified:
            return LocalizationConstants.KYC.verificationRequirements
        case .unverified:
            return ""
        }
    }

    public var limitTimeframe: String {
        switch self {
        case .unverified:
            return "locked"
        case .verified:
            return LocalizationConstants.KYC.dailySwapLimit
        }
    }

    public var duration: String {
        switch self {
        case .unverified:
            return "0 minutes"
        case .verified:
            return LocalizationConstants.KYC.takesTenMinutes
        }
    }
}
