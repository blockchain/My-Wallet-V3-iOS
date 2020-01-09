//
//  LocalizationConstants+Biometry.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 21/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public extension LocalizationConstants {
    struct Biometry {
        public static let touchIDEnableInstructions = NSLocalizedString(
            "Touch ID is not enabled on this device. To enable Touch ID, go to Settings -> Touch ID & Passcode and add a fingerprint.",
            comment: "The error description for when the user is not enrolled in biometric authentication."
        )
        //: Biometry Authentication Errors (only available on iOS 11, possibly including newer versions)
        public static let biometricsLockout = NSLocalizedString(
            "Unable to authenticate due to failing authentication too many times.",
            comment: "The error description for when the user has made too many failed authentication attempts using biometrics."
        )
        public static let biometricsNotSupported = NSLocalizedString(
            "Unable to authenticate because the device does not support biometric authentication.",
            comment: "The error description for when the device does not support biometric authentication."
        )
        public static let unableToUseBiometrics = NSLocalizedString(
            "Unable to use biometrics.",
            comment: "The error message displayed to the user upon failure to authenticate using biometrics."
        )
        public static let biometryWarning = NSLocalizedString(
            "Enabling this feature will allow all users with a registered %@ fingerprint on this device to access to your wallet.",
            comment: "The message displayed in the alert view when the biometry switch is toggled in the settings view."
        )
        public static let enableX = NSLocalizedString(
            "Enable %@",
            comment: "The title of the biometric authentication button in the wallet setup view. The value depends on the type of biometry."
        )
        public static let authenticationReason = NSLocalizedString(
            "Authenticate to unlock your wallet",
            comment: "The app-provided reason for requesting authentication, which displays in the authentication dialog presented to the user."
        )
        public static let genericError = NSLocalizedString(
            "Authentication Failed. Please try again.",
            comment: "Fallback error for all other errors that may occur during biometric authentication."
        )
        public static let usePasscode = NSLocalizedString(
            "Use Passcode",
            comment: "Fallback title for when biometric authentication fails."
        )
        public static let authenticationFailed = NSLocalizedString(
            "Authentication was not successful because the user failed to provide valid credentials.",
            comment: "The internal error description if biometric authentication fails because the user failed to provide valid credentials."
        )
        public static let passcodeNotSet = NSLocalizedString(
            "Failed to Authenticate because a passcode has not been set on the device.",
            comment: "The internal error description if biometric authentication fails because no passcode has been set."
        )
        public static let notConfigured = NSLocalizedString(
            "Biometrics authenticator is not configured on your device",
            comment: "The message displayed in the alert when biometry is not configured on the device"
        )
        public static let cancelButton = NSLocalizedString(
            "Cancel",
            comment: "Biometry Alert: Cancel Button"
        )
    }
}
