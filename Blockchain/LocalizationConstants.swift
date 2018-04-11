//
//  LocalizationConstants.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

let BC_STRING_ERROR = NSLocalizedString("Error", comment: "")
let BC_STRING_OK = NSLocalizedString("OK", comment: "")

//: Local Authentication - Face ID & Touch ID

let BC_STRING_AUTH_CANCEL = NSLocalizedString("Cancel", comment: "")
let BC_STRING_AUTH_USE_PASSCODE = NSLocalizedString("Use Passcode", comment: "")

let BC_STRING_FACE_ID_AUTHENTICATE = NSLocalizedString("Authenticate with Face ID", comment: "")
let BC_STRING_TOUCH_ID_AUTHENTICATE = NSLocalizedString("Authenticate with Touch ID", comment: "")

//: Authentication Errors
let BC_STRING_AUTH_GENERIC_ERROR = NSLocalizedString("Authentication Failed. Please try again.", comment: "")
let BC_STRING_AUTH_AUTHENTICATION_FAILED = NSLocalizedString("Authentication was not successful because the user failed to provide valid credentials.", comment: "")
let BC_STRING_AUTH_APP_CANCEL = NSLocalizedString("Authentication was canceled by the application.", comment: "")
let BC_STRING_AUTH_PASSCODE_NOT_SET = NSLocalizedString("Failed to authenticate because a passcode has not been set on the device.", comment: "")

//: Deprecated Authentication Errors (remove once we stop supporting iOS >= 8.0 and iOS <= 11)
let BC_STRING_AUTH_TOUCH_ID_LOCKOUT = NSLocalizedString("Unable to authenticate because there were too many failed Touch ID attempts. Passcode is required to unlock Touch ID", comment: "")
let BC_STRING_AUTH_TOUCH_ID_NOT_AVAILABLE = NSLocalizedString("Unable to authenticate because Touch ID is not available on the device.", comment: "")
let BC_STRING_AUTH_TOUCH_ID_NOT_ENROLLED = NSLocalizedString("Unable to authenticate because Touch ID has no enrolled fingers.", comment: "")

//: Biometry Authentication Errors (only available on iOS 11, possibly including newer versions)
let BC_STRING_AUTH_BIOMETRY_LOCKOUT = NSLocalizedString("Unable to authenticate due to failing authentication too many times.", comment: "")
let BC_STRING_AUTH_BIOMETRY_NOT_AVAILABLE = NSLocalizedString("Unable to authenticate because the device does not support biometric authentication.", comment: "")
let BC_STRING_AUTH_BIOMETRY_NOT_ENROLLED = NSLocalizedString("Unable to authenticate because biometric authentication is not enrolled.", comment: "")
