// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension AppUpgradeState {

    private typealias LocalizedString = LocalizationConstants.AppUpgrade

    enum Button: Identifiable {

        case goToWeb(url: String)
        case skip
        case status(url: String)
        case update(url: String)

        var id: String {
            switch self {
            case .skip:
                return "skip"
            case .update:
                return "update"
            case .status:
                return "status"
            case .goToWeb:
                return "goToWeb"
            }
        }

        var title: String {
            switch self {
            case .skip:
                return LocalizedString.Button.skip
            case .update:
                return LocalizedString.Button.update
            case .status:
                return LocalizedString.Button.status
            case .goToWeb:
                return LocalizedString.Button.goToWeb
            }
        }

        var url: URL? {
            switch self {
            case .goToWeb(url: let url),
                 .status(url: let url),
                 .update(url: let url):
                return URL(string: url)
            case .skip:
                return nil
            }
        }

        var isStatus: Bool {
            switch self {
            case .goToWeb,
                 .skip,
                 .update:
                return false
            case .status:
                return true
            }
        }
    }

    var logo: String {
        "logo-blockchain-black"
    }

    var badge: String {
        switch style {
        case .hardUpgrade, .softUpgrade:
            return "outdated-badge"
        case .appMaintenance, .maintenance, .unsupportedOS:
            return "maintenance-badge"
        }
    }

    var title: String {
        switch style {
        case .hardUpgrade, .softUpgrade:
            return LocalizedString.Title.update
        case .appMaintenance, .maintenance:
            return LocalizedString.Title.maintenance
        case .unsupportedOS:
            return LocalizedString.Title.unsupportedOS
        }
    }

    var subtitle: String {
        switch style {
        case .hardUpgrade, .softUpgrade:
            return LocalizedString.Subtitle.update
        case .appMaintenance:
            return LocalizedString.Subtitle.appMaintenance
        case .maintenance:
            return LocalizedString.Subtitle.maintenance
        case .unsupportedOS:
            return LocalizedString.Subtitle.unsupportedOS
        }
    }

    var cta: Button {
        switch style {
        case .softUpgrade:
            return .update(url: url)
        case .hardUpgrade:
            return .update(url: url)
        case .appMaintenance, .unsupportedOS:
            return .goToWeb(url: url)
        case .maintenance:
            return .status(url: url)
        }
    }
}
