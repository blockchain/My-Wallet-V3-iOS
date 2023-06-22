// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import ToolKit

extension SettingsSectionType.CellType {
    var action: SettingsScreenAction {
        switch self {
        case .badge(let type, let presenter):
            guard !presenter.isLoading else { return .none }
            switch type {
            case .currencyPreference:
                return .showCurrencySelectionScreen
            case .tradingCurrencyPreference:
                return .showTradingCurrencySelectionScreen
            case .emailVerification:
                return .showUpdateEmailScreen
            case .limits:
                return .presentTradeLimits
            case .mobileVerification:
                return .showUpdateMobileScreen
            case .pitConnection:
                return .launchPIT
            case .recoveryPhrase:
                return .showBackupScreen
            case .blockchainDomains:
                return .showBlockchainDomains
            }
        case .cards(let type):
            switch type {
            case .skeleton:
                return .none
            case .linked(let presenter):
                return .showRemoveCardScreen(presenter.cardData)
            case .add(let presenter):
                guard !presenter.isLoading else { return .none }
                return presenter.action
            }
        case .banks(let type):
            switch type {
            case .skeleton:
                return .none
            case .linked(let presenter):
                return .showRemoveBankScreen(presenter.data)
            case .add(let presenter):
                guard !presenter.isLoading else { return .none }
                return presenter.action
            }
        case .clipboard(let type):
            switch type {
            case .walletID:
                return .promptGuidCopy
            }
        case .common(let type, _):
            switch type {
            case .changePassword:
                return .launchChangePassword
            case .changePIN:
                return .showChangePinScreen
            case .webLogin:
                return .showWebLogin
            case .rateUs:
                return .showAppStore
            case .termsOfService:
                return .showURL(URL(string: Constants.Url.termsOfService)!)
            case .privacyPolicy:
                return .showURL(URL(string: Constants.Url.privacyPolicy)!)
            case .cookiesPolicy:
                return .showURL(URL(string: Constants.Url.cookiesPolicy)!)
            case .logout:
                return .logout
            case .contactSupport:
                return .showContactSupport
            case .notifications:
                return .showNotificationsSettings
            case .userDeletion:
                return .showUserDeletionScreen
            case .blockchainDomains:
                return .showBlockchainDomains
            case .theme:
                return .showThemeSettings
            }
        case .switch:
            return .none

        case .refferal(_, let viewModel):
            return .showReferralScreen(viewModel.referral)
        }
    }
}
