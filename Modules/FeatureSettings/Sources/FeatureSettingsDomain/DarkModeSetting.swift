// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

public enum DarkModeSetting: String, Codable, Equatable, Hashable, CaseIterable {
    case light
    case dark
    case automatic

    public var title: String {
        switch self {
        case .dark:
            LocalizationConstants.Settings.Theme.dark
        case .light:
            LocalizationConstants.Settings.Theme.light
        case .automatic:
            LocalizationConstants.Settings.Theme.settings
        }
    }
}
