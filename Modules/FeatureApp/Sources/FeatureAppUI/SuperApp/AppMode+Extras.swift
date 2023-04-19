// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI

extension AppMode {
    var title: String {
        switch self {
        case .trading:
            return LocalizationConstants.SuperApp.trading
        case .pkw:
            return LocalizationConstants.SuperApp.pkw
        case .universal:
            return ""
        }
    }

    var isTrading: Bool {
        self == .trading
    }

    var isDefi: Bool {
        self == .pkw
    }

    var backgroundGradient: [Color] {
        switch self {
        case .trading:
            return [
                Color(red: 1.0, green: 0, blue: 0.59),
                Color(red: 0.49, green: 0.20, blue: 0.73)
            ]
        case .pkw:
            return [
                Color(red: 0.42, green: 0.22, blue: 0.74),
                Color(red: 0.16, green: 0.47, blue: 0.83)
            ]
        case .universal:
            return []
        }
    }
}
