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
                "skip"
            case .update:
                "update"
            case .status:
                "status"
            case .goToWeb:
                "goToWeb"
            }
        }

        var title: String {
            switch self {
            case .skip:
                LocalizedString.Button.skip
            case .update:
                LocalizedString.Button.update
            case .status:
                LocalizedString.Button.status
            case .goToWeb:
                LocalizedString.Button.goToWeb
            }
        }

        var url: URL? {
            switch self {
            case .goToWeb(url: let url),
                 .status(url: let url),
                 .update(url: let url):
                URL(string: url)
            case .skip:
                nil
            }
        }

        var isStatus: Bool {
            switch self {
            case .goToWeb,
                 .skip,
                 .update:
                false
            case .status:
                true
            }
        }
    }

    var logo: String {
        "logo-blockchain-black"
    }

    var badge: String {
        switch style {
        case .hardUpgrade, .softUpgrade:
            "outdated-badge"
        case .appMaintenance, .maintenance, .unsupportedOS:
            "maintenance-badge"
        }
    }

    var title: String {
        switch style {
        case .hardUpgrade, .softUpgrade:
            LocalizedString.Title.update
        case .appMaintenance, .maintenance:
            LocalizedString.Title.maintenance
        case .unsupportedOS:
            LocalizedString.Title.unsupportedOS
        }
    }

    var subtitle: String {
        switch style {
        case .hardUpgrade, .softUpgrade:
            LocalizedString.Subtitle.update
        case .appMaintenance:
            LocalizedString.Subtitle.appMaintenance
        case .maintenance:
            LocalizedString.Subtitle.maintenance
        case .unsupportedOS:
            LocalizedString.Subtitle.unsupportedOS
        }
    }

    var cta: Button {
        switch style {
        case .softUpgrade:
            .update(url: url)
        case .hardUpgrade:
            .update(url: url)
        case .appMaintenance, .unsupportedOS:
            .goToWeb(url: url)
        case .maintenance:
            .status(url: url)
        }
    }
}
