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
    static let ok = NSLocalizedString("OK", comment: "")
    static let syncingWallet = NSLocalizedString("Syncing Wallet", comment: "")
    static let tryAgain = NSLocalizedString("Try again", comment: "")
    static let verifying = NSLocalizedString ("Verifying", comment: "")
    static let information = NSLocalizedString("Information", comment: "")

    struct Errors {
        static let error = NSLocalizedString("Error", comment: "")
        static let errorLoadingWallet = NSLocalizedString("Unable to load wallet due to no server response. You may be offline or Blockchain is experiencing difficulties. Please try again later.", comment: "")
        static let cannotOpenURLArg = NSLocalizedString("Cannot open URL %@", comment: "")
        static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
        static let noInternetConnection = NSLocalizedString("No internet connection.", comment: "")
        static let warning = NSLocalizedString("Warning", comment: "")
        static let timedOut = NSLocalizedString("Connection timed out. Please check your internet connection.", comment: "")
        static let invalidServerResponse = NSLocalizedString("Invalid server response. Please check your internet connection.", comment: "")
        static let invalidStatusCodeReturned = NSLocalizedString("Invalid Status Code Returned %@", comment: "")
        static let errorLoadingWalletIdentifierFromKeychain = NSLocalizedString("An error was encountered retrieving your wallet identifier from the keychain. Please close the application and try again.", comment: "")
    }

    struct Authentication {
        static let errorDecryptingWallet = NSLocalizedString("An error occurred due to interruptions during PIN verification. Please close the app and try again.", comment: "")
        static let invalidSharedKey = NSLocalizedString("Invalid Shared Key", comment: "")
        static let didCreateNewWalletTitle = NSLocalizedString("Your wallet was successfully created.", comment: "")
        static let didCreateNewWalletMessage = NSLocalizedString("Before accessing your wallet, please choose a pin number to use to unlock your wallet. It's important you remember this pin as it cannot be reset or changed without first unlocking the app.", comment: "")
        static let walletPairedSuccessfullyTitle = NSLocalizedString("Wallet Paired Successfully.", comment: "")
        static let walletPairedSuccessfullyMessage = NSLocalizedString("Before accessing your wallet, please choose a pin number to use to unlock your wallet. It's important you remember this pin as it cannot be reset or changed without first unlocking the app.", comment: "")
        static let newPinMustBeDifferent = NSLocalizedString("New PIN must be different", comment: "")
        static let chooseAnotherPin = NSLocalizedString("Please choose another PIN", comment: "")
        static let pinCodeCommonMessage = NSLocalizedString("The PIN you have selected is extremely common and may be easily guessed by someone with access to your phone within 3 tries. Would you like to use this PIN anyway?", comment: "")
        static let forgotPassword = NSLocalizedString("Forgot Password?", comment: "")
        static let passwordRequired = NSLocalizedString("Password Required", comment: "")
        static let downloadingWallet = NSLocalizedString("Downloading Wallet", comment: "")
        static let noPasswordEntered = NSLocalizedString("No Password Entered", comment: "")
        static let failedToLoadWallet = NSLocalizedString("Failed To Load Wallet", comment: "")
        static let failedToLoadWalletDetail = NSLocalizedString("An error was encountered loading your wallet. You may be offline or Blockchain is experiencing difficulties. Please close the application and try again later or re-pair your device.", comment: "")
        static let forgetWallet = NSLocalizedString("Forget Wallet", comment: "")
        static let forgetWalletDetail = NSLocalizedString("This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere otherwise any bitcoin in this wallet will be inaccessible!!", comment: "")
        static let enterPassword = NSLocalizedString("Enter Password", comment: "")
        static let retryValidation = NSLocalizedString("Retry Validation", comment: "")

        struct Pin {
            static let incorrect = NSLocalizedString("Incorrect PIN. Please retry.", comment: "")
            static let cannotSaveInvalidWalletState = NSLocalizedString("Cannot save PIN Code while wallet is not initialized or password is null", comment: "")
            static let responseKeyOrValueLengthZero = NSLocalizedString("PIN Response Object key or value length 0", comment: "")
            static let encryptedStringIsNil = NSLocalizedString("PIN Encrypted String is nil", comment: "")
            static let validationCannotBeCompleted = NSLocalizedString("PIN Validation cannot be completed. Please enter your wallet password manually.", comment: "")
            static let incorrectUnknownError = NSLocalizedString("PIN Code Incorrect. Unknown Error Message.", comment: "")
            static let responseSuccessLengthZero = NSLocalizedString("PIN Response Object success length 0", comment: "")
            static let decryptedPasswordLengthZero = NSLocalizedString("Decrypted PIN Password length 0", comment: "")
            static let validationError = NSLocalizedString("PIN Validation Error", comment: "")
            static let validationErrorMessage = NSLocalizedString("An error occurred validating your PIN code with the remote server. You may be offline or Blockchain may be experiencing difficulties. Would you like retry validation or instead enter your password manually?", comment: "")
        }
    }

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

    @objc class func noInternetConnection() -> String { return LocalizationConstants.Errors.noInternetConnection }

    @objc class func onboardingRecoverFunds() -> String { return LocalizationConstants.Onboarding.recoverFunds }

    @objc class func tryAgain() -> String { return LocalizationConstants.tryAgain }

    @objc class func passwordRequired() -> String { return LocalizationConstants.Authentication.passwordRequired }

    @objc class func downloadingWallet() -> String { return LocalizationConstants.Authentication.downloadingWallet }

    @objc class func timedOut() -> String { return LocalizationConstants.Errors.timedOut }

    @objc class func incorrectPin() -> String { return LocalizationConstants.Authentication.Pin.incorrect }
}
