// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformUIKit

extension SettingsSectionType.CellType.CommonCellType {

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.SettingsCell.Common

    var title: String {
        switch self {
        case .rateUs:
            LocalizationConstants.Settings.rateUs
        case .webLogin:
            LocalizationConstants.Settings.webLogin
        case .changePassword:
            LocalizationConstants.Settings.changePassword
        case .changePIN:
            LocalizationConstants.Settings.changePIN
        case .termsOfService:
            LocalizationConstants.Settings.termsOfService
        case .privacyPolicy:
            LocalizationConstants.Settings.privacyPolicy
        case .cookiesPolicy:
            LocalizationConstants.Settings.cookiesPolicy
        case .logout:
            LocalizationConstants.Settings.logout
        case .contactSupport:
            LocalizationConstants.Settings.contactSupport
        case .notifications:
            LocalizationConstants.Settings.Badge.notifications
        case .userDeletion:
            LocalizationConstants.Settings.deleteAccount
        case .blockchainDomains:
            LocalizationConstants.Settings.cryptoDomainsTitle
        case .theme:
            LocalizationConstants.Settings.theme
        }
    }

    var icon: UIImage? {
        switch self {
        case .webLogin:
            Icon.computer.uiImage
        case .contactSupport:
            Icon.chat.uiImage
        case .logout:
            Icon.logout.uiImage
        default:
            nil
        }
    }

    var showsIndicator: Bool {
        switch self {
        case .logout:
            false
        default:
            true
        }
    }

    var overrideTintColor: UIColor? {
        switch self {
        case .logout:
            UIColor.semantic.error
        default:
            nil
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
            LocalizationConstants.Settings.walletID
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
