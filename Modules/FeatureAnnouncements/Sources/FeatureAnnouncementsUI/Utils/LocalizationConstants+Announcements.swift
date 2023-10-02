// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants.Announcements {
    static let done = NSLocalizedString("That’s all for now 🥳", comment: "Announcements: That’s all for now 🥳")

    public enum Sweep {

        public enum Prompt {
            public static let title = NSLocalizedString("Important update!", comment: "Announcements: Updated Title")
            public static let message = NSLocalizedString(
                "Please login to your web wallet and follow the given instructions.",
                comment: "Announcements: Updated Message"
            )
        }

        public enum Updated {
            public static let title = NSLocalizedString("You're all set!", comment: "Announcements: Sweep Prompt Title")
            public static let message = NSLocalizedString(
                "Your wallet has been updated to the latest version. Enjoy!",
                comment: "Announcements: Sweep Prompt Message"
            )
        }
    }
}
