//
//  LocalizationConstants.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
// swiftlint:disable line_length
// swiftlint:disable identifier_name

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

//: Onboarding
struct LocalizationConstants {
    static let information = NSLocalizedString("Information", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let continueString = NSLocalizedString("Continue", comment: "")
    static let okString = NSLocalizedString("OK", comment: "")
    static let success = NSLocalizedString("Success", comment: "")
    static let syncingWallet = NSLocalizedString("Syncing Wallet", comment: "")
    static let tryAgain = NSLocalizedString("Try again", comment: "")
    static let verifying = NSLocalizedString ("Verifying", comment: "")
    static let openArg = NSLocalizedString("Open %@", comment: "")
    static let youWillBeLeavingTheApp = NSLocalizedString("You will be leaving the app.", comment: "")
    static let openMailApp = NSLocalizedString("Open Mail App", comment: "")
    static let goToSettings = NSLocalizedString("Go to Settings", comment: "")
    static let scanQRCode = NSLocalizedString("Scan QR Code", comment: "")

    struct Errors {
        static let error = NSLocalizedString("Error", comment: "")
        static let errorLoadingWallet = NSLocalizedString("Unable to load wallet due to no server response. You may be offline or Blockchain is experiencing difficulties. Please try again later.", comment: "")
        static let cannotOpenURLArg = NSLocalizedString("Cannot open URL %@", comment: "")
        static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
        static let noInternetConnection = NSLocalizedString("No internet connection.", comment: "")
        static let noInternetConnectionPleaseCheckNetwork = NSLocalizedString("No internet connection available. Please check your network settings.", comment: "")
        static let warning = NSLocalizedString("Warning", comment: "")
        static let timedOut = NSLocalizedString("Connection timed out. Please check your internet connection.", comment: "")
        static let invalidServerResponse = NSLocalizedString("Invalid server response. Please try again later.", comment: "")
        static let invalidStatusCodeReturned = NSLocalizedString("Invalid Status Code Returned %@", comment: "")
        static let requestFailedCheckConnection = NSLocalizedString("Request failed. Please check your internet connection.", comment: "")
        static let errorLoadingWalletIdentifierFromKeychain = NSLocalizedString("An error was encountered retrieving your wallet identifier from the keychain. Please close the application and try again.", comment: "")
        static let cameraAccessDenied = NSLocalizedString("Camera Access Denied", comment: "")
        static let cameraAccessDeniedMessage = NSLocalizedString("Blockchain does not have access to the camera. To enable access, go to your device Settings.", comment: "")
        static let nameAlreadyInUse = NSLocalizedString("This name is already in use. Please choose a different name.", comment: "")
        static let failedToRetrieveDevice = NSLocalizedString("Unable to retrieve the input device.", comment: "AVCaptureDeviceError: failedToRetrieveDevice")
        static let inputError = NSLocalizedString("There was an error with the device input.", comment: "AVCaptureDeviceError: inputError")
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
        static let manualPairing = NSLocalizedString("Manual Pairing", comment: "")
        static let invalidTwoFactorAuthenticationType = NSLocalizedString("Invalid two-factor authentication type", comment: "")
        static let manualPairingAuthorizationRequiredTitle = NSLocalizedString("Authorization Required", comment: "")
        static let manualPairingAuthorizationRequiredMessage = NSLocalizedString("Please check your email. If you have already verified a login attempt, you should log in via our web wallet and pair your phone by scanning the QR code under Settings -> Wallet Information.", comment: "")
        static let secondPasswordRequired = NSLocalizedString("Second Password Required", comment: "")
        static let secondPasswordIncorrect = NSLocalizedString("Second Password Incorrect", comment: "")
        static let password = NSLocalizedString("Password", comment: "")
    }

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

    struct Biometrics {
        //: Touch ID specific instructions
        static let touchIDEnableInstructions = NSLocalizedString("Touch ID is not enabled on this device. To enable Touch ID, go to Settings -> Touch ID & Passcode and add a fingerprint.", comment: "")

        //: Biometry Authentication Errors (only available on iOS 11, possibly including newer versions)
        static let biometricsLockout = NSLocalizedString("Unable to Authenticate due to failing Authentication too many times.", comment: "")
        static let biometricsNotSupported = NSLocalizedString("Unable to Authenticate because the device does not support biometric Authentication.", comment: "")
        static let unableToUseBiometrics = NSLocalizedString("Unable to use biometrics.", comment: "")

        //: Deprecated Authentication Errors (remove once we stop supporting iOS >= 8.0 and iOS <= 11)
        static let touchIDLockout = NSLocalizedString("Unable to Authenticate because there were too many failed Touch ID attempts. Passcode is required to unlock Touch ID", comment: "")
    }

    struct Onboarding {
        static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
        static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
        static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
        static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
        static let askToUserOldWalletTitle = NSLocalizedString("We’ve detected a previous installation of Blockchain Wallet on your phone.", comment: "")
        static let askToUserOldWalletMessage = NSLocalizedString("Please choose from the options below.", comment: "")
        static let loginExistingWallet = NSLocalizedString("Login existing Wallet", comment: "")
    }

    struct SideMenu {
        static let loginToWebWallet = NSLocalizedString("Log in to Web Wallet", comment: "")
        static let logout = NSLocalizedString("Logout", comment: "")
        static let logoutConfirm = NSLocalizedString("Do you really want to log out?", comment: "")
        static let buySellBitcoin = NSLocalizedString("Buy & Sell Bitcoin", comment: "")
    }

    struct BuySell {
        static let tradeCompleted = NSLocalizedString("Trade Completed", comment: "")
        static let tradeCompletedDetailArg = NSLocalizedString("The trade you created on %@ has been completed!", comment: "")
        static let viewDetails = NSLocalizedString("View details", comment: "")
        static let errorTryAgain = NSLocalizedString("Something went wrong, please try reopening Buy & Sell Bitcoin again.", comment: "")
    }

    struct AddressAndKeyImport {
        static let importedWatchOnlyAddressArgument = NSLocalizedString("Imported watch-only address %@", comment: "")
        static let importedPrivateKeyArgument = NSLocalizedString("Imported Private Key %@", comment: "")
        static let loadingImportKey = NSLocalizedString("Importing key", comment: "")
        static let loadingProcessingKey = NSLocalizedString("Processing key", comment: "")
        static let importedKeyButForIncorrectAddress = NSLocalizedString("You've successfully imported a private key.", comment: "")
        static let importedKeyDoesNotCorrespondToAddress = NSLocalizedString("NOTE: The scanned private key does not correspond to this watch-only address. If you want to spend from this address, make sure that you scan the correct private key.", comment: "")
        static let importedKeySuccess = NSLocalizedString("You can now spend from this address.", comment: "")
        static let keyAlreadyImported = NSLocalizedString("Key already imported", comment: "")
        static let keyNeedsBip38Password = NSLocalizedString("Needs BIP38 Password", comment: "")
        static let incorrectBip38Password = NSLocalizedString("Wrong BIP38 Password", comment: "")
        static let unknownErrorPrivateKey = NSLocalizedString("There was an error importing this private key.", comment: "")
        static let addressNotPresentInWallet = NSLocalizedString("Your wallet does not contain this address.", comment: "")
        static let addressNotWatchOnly = NSLocalizedString("This address is not watch-only.", comment: "")
        static let keyBelongsToOtherAddressNotWatchOnly = NSLocalizedString("This private key belongs to another address that is not watch only.", comment: "")
        static let unknownKeyFormat = NSLocalizedString("Unknown key format.", comment: "")
        static let unsupportedPrivateKey = NSLocalizedString("Unsupported Private Key Format,", comment: "")
        static let addWatchOnlyAddressWarning = NSLocalizedString("You are about to import a watch-only address, an address (or public key script) stored in the wallet without the corresponding private key. This means that the funds can be spent ONLY if you have the private key stored elsewhere. If you do not have the private key stored, do NOT instruct anyone to send you bitcoin to the watch-only address.", comment: "")
        static let addWatchOnlyAddressWarningPrompt = NSLocalizedString("These options are recommended for advanced users only. Continue?", comment: "")
    }
}

// TODO: deprecate this once Obj-C is no longer using this
/// LocalizationConstants class wrapper so that LocalizationConstants can be accessed from Obj-C.
@objc class LocalizationConstantsObjcBridge: NSObject {

    @objc class func requestFailedCheckConnection() -> String { return LocalizationConstants.Errors.requestFailedCheckConnection }

    @objc class func information() -> String { return LocalizationConstants.information }

    @objc class func error() -> String { return LocalizationConstants.Errors.error }

    @objc class func noInternetConnection() -> String { return LocalizationConstants.Errors.noInternetConnection }

    @objc class func onboardingRecoverFunds() -> String { return LocalizationConstants.Onboarding.recoverFunds }

    @objc class func tryAgain() -> String { return LocalizationConstants.tryAgain }

    @objc class func passwordRequired() -> String { return LocalizationConstants.Authentication.passwordRequired }

    @objc class func downloadingWallet() -> String { return LocalizationConstants.Authentication.downloadingWallet }

    @objc class func timedOut() -> String { return LocalizationConstants.Errors.timedOut }

    @objc class func incorrectPin() -> String { return LocalizationConstants.Pin.incorrect }

    @objc class func logout() -> String { return LocalizationConstants.SideMenu.logout }

    @objc class func noPasswordEntered() -> String { return LocalizationConstants.Authentication.noPasswordEntered }

    @objc class func secondPasswordRequired() -> String { return LocalizationConstants.Authentication.secondPasswordRequired }

    @objc class func success() -> String { return LocalizationConstants.success }

    @objc class func syncingWallet() -> String { return LocalizationConstants.syncingWallet }

    @objc class func loadingImportKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingImportKey }

    @objc class func loadingProcessingKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingProcessingKey }

    @objc class func incorrectBip38Password() -> String { return LocalizationConstants.AddressAndKeyImport.incorrectBip38Password }

    @objc class func scanQRCode() -> String { return LocalizationConstants.scanQRCode }

<<<<<<< HEAD
    @objc class func nameAlreadyInUse() -> String { return LocalizationConstants.Errors.nameAlreadyInUse }
=======
    @objc class func unknownKeyFormat() -> String { return LocalizationConstants.AddressAndKeyImport.unknownKeyFormat }

    @objc class func unsupportedPrivateKey() -> String { return LocalizationConstants.AddressAndKeyImport.unsupportedPrivateKey }
>>>>>>> feat(Localization Constants): update constants for address importing
}
