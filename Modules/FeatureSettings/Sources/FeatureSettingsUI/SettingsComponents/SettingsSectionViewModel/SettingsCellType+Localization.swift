// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformUIKit

extension SettingsSectionType.CellType.CommonCellType {

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.SettingsCell.Common

    var title: String {
        switch self {
        case .rateUs:
            return LocalizationConstants.Settings.rateUs
        case .webLogin:
            return LocalizationConstants.Settings.webLogin
        case .changePassword:
            return LocalizationConstants.Settings.changePassword
        case .changePIN:
            return LocalizationConstants.Settings.changePIN
        case .termsOfService:
            return LocalizationConstants.Settings.termsOfService
        case .privacyPolicy:
            return LocalizationConstants.Settings.privacyPolicy
        case .cookiesPolicy:
            return LocalizationConstants.Settings.cookiesPolicy
        case .logout:
            return LocalizationConstants.Settings.logout
        case .contactSupport:
            return LocalizationConstants.Settings.contactSupport
        case .notifications:
            return LocalizationConstants.Settings.Badge.notifications
        case .userDeletion:
            return LocalizationConstants.Settings.deleteAccount
        case .blockchainDomains:
            return LocalizationConstants.Settings.cryptoDomainsTitle
        case .theme:
            return LocalizationConstants.Settings.theme
        }
    }

    var icon: UIImage? {
        switch self {
        case .webLogin:
            return Icon.computer.uiImage
        case .contactSupport:
            return Icon.chat.uiImage
        case .logout:
            return Icon.logout.uiImage
        default:
            return nil
        }
    }

    var showsIndicator: Bool {
        switch self {
        case .logout:
            return false
        default:
            return true
        }
    }

    var overrideTintColor: UIColor? {
        switch self {
        case .logout:
            return Color.semantic.error
        default:
            return nil
        }
    }

    var accessibilityID: String {
        rawValue
    }

    func viewModel(presenter: CommonCellPresenting?) -> CommonCellViewModel {
        CommonCellViewModel(
            title: title,
            subtitle: nil,
            presenter: presenter,
            icon: icon,
            showsIndicator: showsIndicator,
            overrideTintColor: overrideTintColor,
            accessibilityID: "\(AccessibilityIDs.titleLabelFormat)\(accessibilityID)",
            titleAccessibilityID: "\(AccessibilityIDs.title).\(accessibilityID)"
        )
    }
}

extension SettingsSectionType.CellType.ClipboardCellType {

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.SettingsCell

    var title: String {
        switch self {
        case .walletID:
            return LocalizationConstants.Settings.walletID
        }
    }

    var accessibilityID: String {
        rawValue
    }

    var viewModel: ClipboardCellViewModel {
        .init(
            title: title,
            accessibilityID: "\(AccessibilityIDs.titleLabelFormat)\(accessibilityID)"
        )
    }
}
