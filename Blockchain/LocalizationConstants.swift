//
//  LocalizationConstants.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

let LCStringError = NSLocalizedString("Error", comment: "")
let LCStringOK = NSLocalizedString("OK", comment: "")

let LCStringLoadingVerifying = NSLocalizedString("Verifying", comment: "")

//: Local Authentication - Face ID & Touch ID

let LCStringAuthCancel = NSLocalizedString("Cancel", comment: "")
let LCStringAuthUsePasscode = NSLocalizedString("Use Passcode", comment: "")

let LCStringFaceIDAuthenticate = NSLocalizedString("Authenticate with Face ID", comment: "")
let LCStringTouchIDAuthenticate = NSLocalizedString("Authenticate with Touch ID", comment: "")

//: Authentication Errors
let LCStringAuthGenericError = NSLocalizedString("Authentication Failed. Please try again.", comment: "")
let LCStringAuthAuthenticationFailed = NSLocalizedString("Authentication was not successful because the user failed to provide valid credentials.", comment: "")
let LCStringAuthPasscodeNotSet = NSLocalizedString("Failed to Authenticate because a passcode has not been set on the device.", comment: "")

//: Deprecated Authentication Errors (remove once we stop supporting iOS >= 8.0 and iOS <= 11)
let LCStringAuthTouchIDLockout = NSLocalizedString("Unable to Authenticate because there were too many failed Touch ID attempts. Passcode is required to unlock Touch ID", comment: "")
let LCStringAuthTouchIDNotAvailable = NSLocalizedString("Unable to Authenticate because Touch ID is not available on the device.", comment: "")
let LCStringAuthTouchIDNotEnrolled = NSLocalizedString("Unable to Authenticate because Touch ID has no enrolled fingers.", comment: "")

//: Biometry Authentication Errors (only available on iOS 11, possibly including newer versions)
let LCStringAuthBiometryLockout = NSLocalizedString("Unable to Authenticate due to failing Authentication too many times.", comment: "")
let LCStringAuthBiometryNotAvailable = NSLocalizedString("Unable to Authenticate because the device does not support biometric Authentication.", comment: "")
let LCStringAuthBiometryNotEnrolled = NSLocalizedString("Unable to Authenticate because biometric Authentication is not enrolled.", comment: "")
