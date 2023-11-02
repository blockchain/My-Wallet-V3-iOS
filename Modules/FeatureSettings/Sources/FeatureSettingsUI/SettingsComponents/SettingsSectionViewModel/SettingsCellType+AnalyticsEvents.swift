// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension SettingsSectionType.CellType {
    var analyticsEvent: [AnalyticsEvent] {
        switch self {
        case .badge(.emailVerification, _):
            [
                AnalyticsEvents.Settings.settingsEmailClicked,
                AnalyticsEvents.New.Security.emailChangeClicked
            ]
        case .badge(.mobileVerification, _):
            [AnalyticsEvents.Settings.settingsPhoneClicked]
        case .badge(.recoveryPhrase, _):
            [
                AnalyticsEvents.Settings.settingsRecoveryPhraseClick,
                AnalyticsEvents.New.Security.recoveryPhraseShown
            ]
        case .clipboard(.walletID):
            [AnalyticsEvents.Settings.settingsWalletIdCopyClick]
        case .common(.changePassword, _):
            [AnalyticsEvents.Settings.settingsPasswordClick]
        case .common(.changePIN, _):
            [
                AnalyticsEvents.Settings.settingsChangePinClick,
                AnalyticsEvents.New.Security.changePinClicked
            ]
        case .common(.rateUs, _):
            [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .rateUs)]
        case .common(.termsOfService, _):
            [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .termsOfService)]
        case .common(.privacyPolicy, _):
            [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .privacyPolicy)]
        case .common(.cookiesPolicy, _):
            [AnalyticsEvents.New.Settings.settingsHyperlinkClicked(destination: .cookiesPolicy)]
        default:
            []
        }
    }
}
