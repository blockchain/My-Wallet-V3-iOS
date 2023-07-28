// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension Image {
    public enum Logo {
        public static let blockchain = Image("logo_large")
    }

    public enum CircleIcon {
        public static let verifyDevice = Image("icon_verify_device")
        public static let importWallet = Image("icon_import_wallet")
        public static let resetAccount = Image("icon_reset_account")
        public static let warning = Image("icon_warning")
        public static let lockedIcon = Image("circle-locked-icon")
    }
}
