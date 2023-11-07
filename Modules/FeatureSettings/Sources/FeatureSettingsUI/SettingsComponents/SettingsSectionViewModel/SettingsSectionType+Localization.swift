// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension SettingsSectionType {
    var sectionTitle: String {
        switch self {
        case .profile:
            LocalizationConstants.Settings.Section.profile
        case .preferences:
            LocalizationConstants.Settings.Section.preferences
        case .connect:
            LocalizationConstants.Settings.Section.exchangeLink
        case .security:
            LocalizationConstants.Settings.Section.security
        case .cards:
            LocalizationConstants.Settings.Section.linkedCards
        case .banks:
            LocalizationConstants.Settings.Section.linkedBanks
        case .help:
            LocalizationConstants.Settings.Section.help
        case .referral:
            ""
        }
    }
}
