// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Accessibility {
    public enum Identifier {}
}

// MARK: - Public

extension Accessibility.Identifier {

    public enum ContentLabelView {
        public static let title = "ContentLabelView.title"
        public static let description = "ContentLabelView.description"
    }

    /// General accessibility
    public enum General {

        /// Main CTA button
        public static let mainCTAButton = "mainCTAButton"
        public static let secondaryCTAButton = "secondaryCTAButton"
        public static let destructiveCTAButton = "desctructiveCTAButton"
        public static let cancelCTAButton = "cancelCTAButton"
        public static let restrictedAccountCTAButton = "restrictedAccountCTAButton"

        public static let destructiveBadgeView = "desctructiveBadgeView"
        public static let affirmativeBadgeView = "affirmativeBadgeView"
        public static let defaultBadgeView = "defaultBadgeView"
        public static let warningBadgeView = "warningBadgeView"

        // Segmented Button
        public static let primarySegmentedControl = "primarySegmentedControl"

        // Switch
        public static let defaultSwitchView = "defaultSwitchView"
    }
}

// MARK: - Internal

extension Accessibility.Identifier {
    enum NavigationBar {
        static let prefix = "NavigationBar."
        static let backButton = "\(prefix)backButton"
        static let drawerButton = "\(prefix)drawerButton"
        static let qrCodeButton = "\(prefix)qrCodeButton"
        static let dismissButton = "\(prefix)dismissButton"
        static let supportButton = "\(prefix)supportButton"
        static let skipButton = "\(prefix)skipButton"
    }
}

extension Accessibility.Identifier {
    enum LoadingView {
        static let prefixFormat = "LoadingView."
        static let statusLabel = "\(prefixFormat)statusLabel"
        static let loadingView = "\(prefixFormat)loadingView"
    }
}

extension Accessibility.Identifier {
    enum ReceiveCrypto {
        private static let prefix = "ReceiveScreen."
        static let instructionLabel = "\(prefix)instructionLabel"
        static let addressLabel = "\(prefix)addressLabel"
        static let qrCodeImageView = "\(prefix)qrCodeImageView"
        static let enterPasswordButton = "\(prefix)enterPasswordButton"
    }
}

extension Accessibility.Identifier {
    enum TextFieldView {
        private static let prefix = "TextFieldView."

        enum Card {
            private static let prefix = "\(TextFieldView.prefix)Card."
            static let name = "\(prefix)cardholderName"
            static let expirationDate = "\(prefix)expirationDate"
            static let number = "\(prefix)number"
            static let cvv = "\(prefix)cvv"
        }

        static let email = "\(prefix)statusLabel"
        static let newPassword = "\(prefix)newPassword"
        static let confirmNewPassword = "\(prefix)confirmNewPassword"
        static let password = "\(prefix)password"
        static let currentPassword = "\(prefix)currentPassword"
        static let description = "\(prefix)description"
        static let walletIdentifier = "\(prefix)walletIdentifier"
        static let recoveryPhrase = "\(prefix)recoveryPhrase"
        static let backupVerification = "\(prefix)backupVerification"
        static let mobileVerification = "\(prefix)mobileVerification"
        static let oneTimeCode = "\(prefix)oneTimeCode"
        static let addressLine = "\(prefix)addressLine"
        static let personFullName = "\(prefix)personFullName"
        static let city = "\(prefix)city"
        static let state = "\(prefix)state"
        static let postCode = "\(prefix)postCode"
        static let cryptoAddress = "\(prefix)cryptoAddress"
        static let memo = "\(prefix)memo"
    }
}

extension Accessibility.Identifier {
    public enum AnnouncementCard {
        static let prefix = "AnnouncementCard"
        public static let badge = "\(prefix).badge"
    }
}
