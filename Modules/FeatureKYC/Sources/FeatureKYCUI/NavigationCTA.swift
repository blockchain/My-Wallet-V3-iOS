// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformUIKit
import UIKit

private typealias L10n = LocalizationConstants.NewKYC.Steps.AccountUsage

enum NavigationCTA {
    case dismiss
    case help
    case skip
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            UIImage(
                named: "Close Circle v2",
                in: .componentLibrary,
                compatibleWith: nil
            )?.withRenderingMode(.alwaysOriginal)
        case .help:
            UIImage(named: "ios_icon_more", in: .featureKYCUI, compatibleWith: nil)
        case .none, .skip:
            nil
        }
    }

    var title: String {
        switch self {
        case .dismiss, .help, .none:
            ""
        case .skip:
            L10n.skipButtonTitle
        }
    }

    var visibility: PlatformUIKit.Visibility {
        switch self {
        case .dismiss, .help, .skip:
            .visible
        case .none:
            .hidden
        }
    }
}
