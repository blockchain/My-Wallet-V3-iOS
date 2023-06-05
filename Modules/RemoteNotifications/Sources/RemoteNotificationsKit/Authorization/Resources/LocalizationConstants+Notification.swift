// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants {
    enum Notifications {
        enum Authorization {
            static let title = NSLocalizedString(
                "Turn On Notifications",
                comment: "Notification authorization title"
            )
            static let message = NSLocalizedString(
                "We’ll notify you when big changes happen in the market. We’ll also send you payment and security alerts.",
                comment: "Notification authorization message"
            )
            static let dontAllow = NSLocalizedString(
                "Don't Allow",
                comment: "Notification authorization refuse button"
            )
            static let allow = NSLocalizedString(
                "OK",
                comment: "Notification authorization accept button"
            )
        }
    }
}
