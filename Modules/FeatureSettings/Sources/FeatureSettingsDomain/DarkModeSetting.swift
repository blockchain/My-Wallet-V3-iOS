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
            return LocalizationConstants.Settings.Theme.dark
        case .light:
            return LocalizationConstants.Settings.Theme.light
        case .automatic:
            return LocalizationConstants.Settings.Theme.settings
        }
    }
}
