//
//  LocalizationConstants.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

//: Local Authentication - Face ID & Touch ID

let LCStringAuthCancel = NSLocalizedString("Cancel", comment: "")
let LCStringAuthUsePasscode = NSLocalizedString("Use Passcode", comment: "")

let LCStringFaceIDAuthenticate = NSLocalizedString("Authenticate to unlock your wallet", comment: "")
let LCStringTouchIDAuthenticate = NSLocalizedString("Authenticate to unlock your wallet", comment: "")

//: Authentication Errors
let LCStringAuthGenericError = NSLocalizedString("Authentication Failed. Please try again.", comment: "")
let LCStringAuthAuthenticationFailed = NSLocalizedString("Authentication was not successful because the user failed to provide valid credentials.", comment: "")
let LCStringAuthPasscodeNotSet = NSLocalizedString("Failed to Authenticate because a passcode has not been set on the device.", comment: "")

//: Deprecated Authentication Errors (remove once we stop supporting iOS >= 8.0 and iOS <= 11)
let LCStringAuthTouchIDLockout = NSLocalizedString("Unable to Authenticate because there were too many failed Touch ID attempts. Passcode is required to unlock Touch ID", comment: "")
let LCStringAuthTouchIDNotAvailable = NSLocalizedString("Unable to Authenticate because Touch ID is not available on the device.", comment: "")

//: Biometry Authentication Errors (only available on iOS 11, possibly including newer versions)
let LCStringAuthBiometryLockout = NSLocalizedString("Unable to Authenticate due to failing Authentication too many times.", comment: "")
let LCStringAuthBiometryNotAvailable = NSLocalizedString("Unable to Authenticate because the device does not support biometric Authentication.", comment: "")

//: Onboarding
struct LocalizationConstants {
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let continueString = NSLocalizedString("Continue", comment: "")
    static let error = NSLocalizedString("Error", comment: "")
    static let ok = NSLocalizedString("OK", comment: "")
    static let warning = NSLocalizedString("Warning", comment: "")
    static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
    static let syncingWallet = NSLocalizedString("Syncing Wallet", comment: "")
    static let verifying = NSLocalizedString ("Verifying", comment: "")

    struct Onboarding {
        static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
        static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
        static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
        static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
    }
}

/// LocalizationConstants class wrapper so that LocalizationConstants can be accessed from Obj-C.
/// Should deprecate this once Obj-C is no longer using this
@objc class LocalizationConstantsObjcBridge: NSObject {

    @objc class func onboardingRecoverFunds() -> String { return LocalizationConstants.Onboarding.recoverFunds }
}

