// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum AccessibilityIdentifiers {
    enum PinScreen {
        static let prefix = "PinScreen."

        static let pinSecureViewTitle = "\(prefix)titleLabel"
        static let pinIndicatorFormat = "\(prefix)pinIndicator-"

        static let errorLabel = "\(prefix)errorLabel"
        static let lockTimeLabel = "\(prefix)lockTimeLabel"

        static let versionLabel = "\(prefix)versionLabel"
        static let swipeLabel = "\(prefix)swipeLabel"
    }

    enum Address {
        static let prefix = "AddressScreen."
        static let pageControl = "\(prefix)pageControl"
    }
}
