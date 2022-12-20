// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAppUpgradeDomain

public struct AppUpgradeState: Equatable {
    enum Style {
        case hardUpgrade
        case softUpgrade
        case appMaintenance
        case maintenance
        case unsupportedOS

        var isSkippable: Bool {
            switch self {
            case .softUpgrade, .unsupportedOS:
                return true
            default:
                return false
            }
        }
    }

    let style: Style
    let url: String

    public init?(
        data: AppUpgradeData,
        appVersion: String,
        currentOSVersion: String
    ) {
        if currentOSVersion < data.minimumOSVersion {
            self = AppUpgradeState(style: .unsupportedOS, url: data.websiteURL)
        } else if data.sitewideMaintenance {
            self = AppUpgradeState(style: .maintenance, url: data.statusURL)
        } else if data.redirectToWebsite {
            self = AppUpgradeState(style: .appMaintenance, url: data.websiteURL)
        } else if data.bannedVersions.contains(appVersion) {
            if appVersion >= data.appStoreVersion || data.bannedVersions.contains(data.appStoreVersion) {
                self = AppUpgradeState(style: .appMaintenance, url: data.websiteURL)
            } else {
                self = AppUpgradeState(style: .hardUpgrade, url: data.storeURI)
            }
        } else if appVersion < data.minimumAppVersion {
            self = AppUpgradeState(style: .hardUpgrade, url: data.storeURI)
        } else if appVersion < data.softUpgradeVersion {
            self = AppUpgradeState(style: .softUpgrade, url: data.storeURI)
        } else {
            return nil
        }
    }

    init(style: AppUpgradeState.Style, url: String) {
        self.style = style
        self.url = url
    }
}
