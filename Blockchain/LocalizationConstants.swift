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

//: Onboarding
struct LocalizationConstants {
    static let verified = NSLocalizedString("Verified", comment: "")
    static let unverified = NSLocalizedString("Unverified", comment: "")
    static let verify = NSLocalizedString ("Verify", comment: "")
    static let enterCode = NSLocalizedString ("Enter Verification Code", comment: "")
    static let tos = NSLocalizedString ("Terms of Service", comment: "")
    static let touchId = NSLocalizedString ("Touch ID", comment: "")
    static let faceId = NSLocalizedString ("Face ID", comment: "")
    static let disable = NSLocalizedString ("Disable", comment: "")
    static let disabled = NSLocalizedString ("Disabled", comment: "")
    static let unknown = NSLocalizedString ("Unknown", comment: "")
    static let unconfirmed = NSLocalizedString("Unconfirmed", comment: "")
    static let enable = NSLocalizedString ("Enable", comment: "")
    static let changeEmail = NSLocalizedString ("Change Email", comment: "")
    static let addEmail = NSLocalizedString ("Add Email", comment: "")
    static let newEmail = NSLocalizedString ("New Email Address", comment: "")
    static let settings = NSLocalizedString ("Settings", comment: "")

    static let more = NSLocalizedString("More", comment: "")
    static let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "")
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
    static let swipeReceive = NSLocalizedString("Swipe to Receive", comment: "")
    static let twostep = NSLocalizedString("Enable 2-Step", comment: "")
    static let localCurrency = NSLocalizedString("Local Currency", comment: "")
    static let scanQRCode = NSLocalizedString("Scan QR Code", comment: "")
    static let dontShowAgain = NSLocalizedString(
        "Don't show again",
        comment: "Text displayed to the user when an action has the option to not be asked again."
    )
    static let myEtherWallet = NSLocalizedString(
        "My Ether Wallet",
        comment: "The default name of the ether wallet."
    )
    static let loading = NSLocalizedString(
        "Loading",
        comment: "Text displayed when there is an asynchronous action that needs to complete before the user can take further action."
    )

    struct Errors {
        static let error = NSLocalizedString("Error", comment: "")
        static let loadingSettings = NSLocalizedString("loading Settings", comment: "")
        static let errorLoadingWallet = NSLocalizedString("Unable to load wallet due to no server response. You may be offline or Blockchain is experiencing difficulties. Please try again later.", comment: "")
        static let cannotOpenURLArg = NSLocalizedString("Cannot open URL %@", comment: "")
        static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
        static let twoStep = NSLocalizedString("An error occurred while changing 2-Step verification.", comment: "")
        static let noInternetConnection = NSLocalizedString("No internet connection.", comment: "")
        static let noInternetConnectionPleaseCheckNetwork = NSLocalizedString("No internet connection available. Please check your network settings.", comment: "")
        static let warning = NSLocalizedString("Warning", comment: "")
        static let checkConnection = NSLocalizedString("Please check your internet connection.", comment: "")
        static let timedOut = NSLocalizedString("Connection timed out. Please check your internet connection.", comment: "")
        static let siteMaintenanceError = NSLocalizedString("Blockchain's servers are currently under maintenance. Please try again later", comment: "")
        static let invalidServerResponse = NSLocalizedString("Invalid server response. Please try again later.", comment: "")
        static let invalidStatusCodeReturned = NSLocalizedString("Invalid Status Code Returned %@", comment: "")
        static let requestFailedCheckConnection = NSLocalizedString("Request failed. Please check your internet connection.", comment: "")
        static let errorLoadingWalletIdentifierFromKeychain = NSLocalizedString("An error was encountered retrieving your wallet identifier from the keychain. Please close the application and try again.", comment: "")
        static let cameraAccessDenied = NSLocalizedString("Camera Access Denied", comment: "")
        static let cameraAccessDeniedMessage = NSLocalizedString("Blockchain does not have access to the camera. To enable access, go to your device Settings.", comment: "")
        static let nameAlreadyInUse = NSLocalizedString("This name is already in use. Please choose a different name.", comment: "")
        static let failedToRetrieveDevice = NSLocalizedString("Unable to retrieve the input device.", comment: "AVCaptureDeviceError: failedToRetrieveDevice")
        static let inputError = NSLocalizedString("There was an error with the device input.", comment: "AVCaptureDeviceError: inputError")
        static let noEmail = NSLocalizedString("Please provide an email address.", comment: "")
        static let differentEmail = NSLocalizedString("New email must be different", comment: "")
    }

    struct Authentication {
        static let recoveryPhrase = NSLocalizedString("Recovery Phrase", comment: "")
        static let twoStepSMS = NSLocalizedString("2-Step has been enabled for SMS", comment: "")
        static let twoStepOff = NSLocalizedString("2-Step has been disabled.", comment: "")
        static let checkLink = NSLocalizedString("Please check your email and click on the verification link.", comment: "")
        static let googleAuth = NSLocalizedString("Google Authenticator", comment: "")
        static let yubiKey = NSLocalizedString("Yubi Key", comment: "")
        static let enableTwoStep = NSLocalizedString(
            """
            You can enable 2-step Verification via SMS on your mobile phone. In order to use other authentication methods instead, please login to our web wallet.
            """, comment: "")
        static let verifyEmail = NSLocalizedString("Please verify your email address first.", comment: "")
        static let resendVerificationEmail = NSLocalizedString("Resend verification email", comment: "")

        static let resendVerification = NSLocalizedString("Resend verification SMS", comment: "")
        static let enterVerification = NSLocalizedString("Enter your verification code", comment: "")
        static let errorDecryptingWallet = NSLocalizedString("An error occurred due to interruptions during PIN verification. Please close the app and try again.", comment: "")
        static let hasVerified = NSLocalizedString("Your mobile number has been verified.", comment: "")
        static let invalidSharedKey = NSLocalizedString("Invalid Shared Key", comment: "")
        static let didCreateNewWalletTitle = NSLocalizedString("Your wallet was successfully created.", comment: "")
        static let didCreateNewWalletMessage = NSLocalizedString("Before accessing your wallet, please choose a pin number to use to unlock your wallet. It's important you remember this pin as it cannot be reset or changed without first unlocking the app.", comment: "")
        static let walletPairedSuccessfullyTitle = NSLocalizedString("Wallet Paired Successfully.", comment: "")
        static let walletPairedSuccessfullyMessage = NSLocalizedString("Before accessing your wallet, please choose a pin number to use to unlock your wallet. It's important you remember this pin as it cannot be reset or changed without first unlocking the app.", comment: "")
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
        static let manualPairingAuthorizationRequiredMessage = NSLocalizedString("Please check your email and authorize this log-in attempt. After doing so, please return here and try logging in again", comment: "")
        static let secondPasswordRequired = NSLocalizedString("Second Password Required", comment: "")
        static let etherSecondPasswordPrompt = NSLocalizedString("To use this service, we require you to enter your second password. You should only need to enter this once to set up your Ether wallet.", comment: "Text shown when a user whose wallet requires a second password needs to create an ether account to proceed")
        static let secondPasswordIncorrect = NSLocalizedString("Second Password Incorrect", comment: "")
        static let secondPasswordDefaultDescription = NSLocalizedString("This action requires the second password for your wallet. Please enter it below and press continue.", comment: "")
        static let privateKeyNeeded = NSLocalizedString("Private Key Needed", comment: "")
        static let privateKeyPasswordDefaultDescription = NSLocalizedString("The private key you are attempting to import is encrypted. Please enter the password below.", comment: "")
        static let password = NSLocalizedString("Password", comment: "")
    }

    struct Pin {

        static let revealAddress = NSLocalizedString(
        """
        Enable this option to reveal a receive address when you swipe left on the PIN screen, making
        receiving bitcoin even faster. Five addresses will be loaded consecutively, after which logging in is
        required to show new addresses.
        """, comment: "")

        static let genericError = NSLocalizedString(
            "An error occured. Please try again.",
            comment: "Fallback error for all other errors that may occur during the pin validation/change flow."
        )
        static let pinCodeCommonMessage = NSLocalizedString(
            "The PIN you have selected is extremely common and may be easily guessed by someone with access to your phone within 3 tries. Would you like to use this PIN anyway?",
            comment: "Error message displayed to the user when they enter a common pin and is asked if they would like to continue using that common pin or try another one."
        )
        static let newPinMustBeDifferent = NSLocalizedString(
            "New PIN must be different",
            comment: "Error message displayed to the user that they must enter a pin code that is different from their previous pin."
        )
        static let chooseAnotherPin = NSLocalizedString(
            "Please choose another PIN",
            comment: "Error message displayed to the user when they must enter another pin code."
        )

        static let incorrect = NSLocalizedString(
            "Incorrect PIN. Please retry.",
            comment: "Error message displayed when the entered pin is incorrect and the user should try to enter the pin code again."
        )
        static let cannotSaveInvalidWalletState = NSLocalizedString(
            "Cannot save PIN Code while wallet is not initialized or password is null",
            comment: "Error message displayed when the wallet is in an invalid state and the user tried to enter a new pin code."
        )
        static let responseKeyOrValueLengthZero = NSLocalizedString(
            "PIN Response Object key or value length 0",
            comment: "Error message displayed to the user when the pin-store endpoint is returning an invalid response."
        )
        static let validationCannotBeCompleted = NSLocalizedString(
            "PIN Validation cannot be completed. Please enter your wallet password manually.",
            comment: "Error message displayed when the user's pin cannot be validated and instead they are prompted to enter their password."
        )
        static let incorrectUnknownError = NSLocalizedString(
            "PIN Code Incorrect. Unknown Error Message.",
            comment: "Error message displayed when the pin cannot be validated and the error is unknown."
        )
        static let responseSuccessLengthZero = NSLocalizedString(
            "PIN Response Object success length 0",
            comment: "Error message displayed to the user when the pin-store endpoint is returning an invalid response."
        )
        static let decryptedPasswordLengthZero = NSLocalizedString(
            "Decrypted PIN Password length 0",
            comment: "Error message displayed when the user's decrypted password length is 0."
        )
        static let validationError = NSLocalizedString(
            "PIN Validation Error",
            comment: "Title of the error message displayed to the user when their PIN cannot be validated if it is correct."
        )
        static let validationErrorMessage = NSLocalizedString(
        """
        An error occurred validating your PIN code with the remote server. You may be offline or Blockchain may be experiencing difficulties. Would you like retry validation or instead enter your password manually?
        """, comment: "Error message displayed to the user when their PIN cannot be validated if it is correct."
        )
        static let pinsDoNotMatch = NSLocalizedString(
            "PINs do not match",
            comment: "Message presented to user when they enter an incorrect pin when confirming a pin."
        )
    }

    struct Biometrics {
        static let touchIDEnableInstructions = NSLocalizedString(
            "Touch ID is not enabled on this device. To enable Touch ID, go to Settings -> Touch ID & Passcode and add a fingerprint.",
            comment: "The error description for when the user is not enrolled in biometric authentication."
        )
        //: Biometry Authentication Errors (only available on iOS 11, possibly including newer versions)
        static let biometricsLockout = NSLocalizedString(
            "Unable to authenticate due to failing authentication too many times.",
            comment: "The error description for when the user has made too many failed authentication attempts using biometrics."
        )
        static let biometricsNotSupported = NSLocalizedString(
            "Unable to authenticate because the device does not support biometric authentication.",
            comment: "The error description for when the device does not support biometric authentication."
        )
        static let unableToUseBiometrics = NSLocalizedString(
            "Unable to use biometrics.",
            comment: "The error message displayed to the user upon failure to authenticate using biometrics."
        )
        static let biometryWarning = NSLocalizedString(
            "Enabling this feature will allow all users with a registered %@ fingerprint on this device to access to your wallet.",
            comment: "The message displayed in the alert view when the biometry switch is toggled in the settings view."
        )
        static let enableX = NSLocalizedString(
            "Enable %@",
            comment: "The title of the biometric authentication button in the wallet setup view. The value depends on the type of biometry."
        )
        static let authenticationReason = NSLocalizedString(
            "Authenticate to unlock your wallet",
            comment: "The app-provided reason for requesting authentication, which displays in the authentication dialog presented to the user."
        )
        static let genericError = NSLocalizedString(
            "Authentication Failed. Please try again.",
            comment: "Fallback error for all other errors that may occur during biometric authentication."
        )
        static let usePasscode = NSLocalizedString(
            "Use Passcode",
            comment: "Fallback title for when biometric authentication fails."
        )
        static let authenticationFailed = NSLocalizedString(
            "Authentication was not successful because the user failed to provide valid credentials.",
            comment: "The internal error description if biometric authentication fails because the user failed to provide valid credentials."
        )
        static let passcodeNotSet = NSLocalizedString(
            "Failed to Authenticate because a passcode has not been set on the device.",
            comment: "The internal error description if biometric authentication fails because no passcode has been set."
        )
        //: Deprecated Authentication Errors (remove once we stop supporting iOS >= 8.0 and iOS <= 11)
        static let touchIDLockout = NSLocalizedString(
            "Unable to Authenticate because there were too many failed Touch ID attempts. Passcode is required to unlock Touch ID",
            comment: "The error description for when the user has made too many failed authentication attempts using Touch ID."
        )
    }

    struct Onboarding {
        static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
        static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
        static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
        static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
        static let askToUserOldWalletTitle = NSLocalizedString("We’ve detected a previous installation of Blockchain Wallet on your phone.", comment: "")
        static let askToUserOldWalletMessage = NSLocalizedString("Please choose from the options below.", comment: "")
        static let loginExistingWallet = NSLocalizedString("Login existing Wallet", comment: "")
        static let biometricInstructions = NSLocalizedString("Use %@ instead of PIN to authenticate Blockchain and access your wallet.", comment: "")
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

    struct Exchange {
        static let navigationTitle = NSLocalizedString(
            "Exchange",
            comment: "Title text shown on navigation bar for exchanging a crypto asset for another"
        )
        static let loading = NSLocalizedString(
            "Loading Exchange",
            comment: "Text presented when the wallet is loading the exchange"
        )
        static let loadingTransactions = NSLocalizedString("Loading transactions", comment: "")
        static let gettingQuote = NSLocalizedString("Getting quote", comment: "")
        static let confirming = NSLocalizedString("Confirming", comment: "")
        static let useMinimum = NSLocalizedString(
            "Use minimum",
            comment: "Text displayed on button for user to tap to create a trade with the minimum amount of crypto allowed"
        )
        static let useMaximum = NSLocalizedString(
            "Use maximum",
            comment: "Text displayed on button for user to tap to create a trade with the maximum amount of crypto allowed"
        )
    }

    struct AddressAndKeyImport {

        static let nonSpendable = NSLocalizedString("Non-Spendable", comment: "Text displayed to indicate that part of the funds in the user's wallet is not spendable.")

        static let copyWalletId = NSLocalizedString("Copy Wallet ID", comment: "")

        static let copyCTA = NSLocalizedString("Copy to clipboard", comment: "")
        static let copyWarning = NSLocalizedString(
        """
        Warning: Your wallet identifier is sensitive information. Copying it may compromise the security of your wallet.
        """, comment: "")

        static let importedWatchOnlyAddressArgument = NSLocalizedString("Imported watch-only address %@", comment: "")
        static let importedPrivateKeyArgument = NSLocalizedString("Imported Private Key %@", comment: "")
        static let loadingImportKey = NSLocalizedString("Importing key", comment: "")
        static let loadingProcessingKey = NSLocalizedString("Processing key", comment: "")
        static let importedKeyButForIncorrectAddress = NSLocalizedString("You've successfully imported a private key.", comment: "")
        static let importedKeyDoesNotCorrespondToAddress = NSLocalizedString("NOTE: The scanned private key does not correspond to this watch-only address. If you want to spend from this address, make sure that you scan the correct private key.", comment: "")
        static let importedKeySuccess = NSLocalizedString("You can now spend from this address.", comment: "")
        static let incorrectPrivateKey = NSLocalizedString("Incorrect private key", comment: "Incorrect private key")
        static let keyAlreadyImported = NSLocalizedString("Key already imported", comment: "")
        static let keyNeedsBip38Password = NSLocalizedString("Needs BIP38 Password", comment: "")
        static let incorrectBip38Password = NSLocalizedString("Wrong BIP38 Password", comment: "")
        static let unknownErrorPrivateKey = NSLocalizedString("There was an error importing this private key.", comment: "")
        static let addressNotPresentInWallet = NSLocalizedString("Your wallet does not contain this address.", comment: "")
        static let addressNotWatchOnly = NSLocalizedString("This address is not watch-only.", comment: "")
        static let keyBelongsToOtherAddressNotWatchOnly = NSLocalizedString("This private key belongs to another address that is not watch only", comment: "")
        static let unknownKeyFormat = NSLocalizedString("Unknown key format", comment: "")
        static let unsupportedPrivateKey = NSLocalizedString("Unsupported Private Key Format", comment: "")
        static let addWatchOnlyAddressWarning = NSLocalizedString("You are about to import a watch-only address, an address (or public key script) stored in the wallet without the corresponding private key. This means that the funds can be spent ONLY if you have the private key stored elsewhere. If you do not have the private key stored, do NOT instruct anyone to send you bitcoin to the watch-only address.", comment: "")
        static let addWatchOnlyAddressWarningPrompt = NSLocalizedString("These options are recommended for advanced users only. Continue?", comment: "")
    }

    struct SendAsset {
        static let invalidXAddressY = NSLocalizedString(
            "Invalid %@ address: %@",
            comment: "String presented to the user when they try to scan a QR code with an invalid address."
        )
    }

    struct SendEther {
        static let waitingForPaymentToFinishTitle = NSLocalizedString("Waiting for payment", comment: "")
        static let waitingForPaymentToFinishMessage = NSLocalizedString("Please wait until your last ether transaction confirms.", comment: "")
    }

    struct Settings {
        static let notificationsDisabled = NSLocalizedString(
        """
        You currently have email notifications enabled. Changing your email will disable email notifications.
        """, comment: "")
        static let cookiePolicy = NSLocalizedString("Cookie Policy", comment: "")
        static let allRightsReserved = NSLocalizedString("All rights reserved.", comment: "")
        static let useBiometricsAsPin = NSLocalizedString("Use %@ as PIN", comment: "")
    }

    struct SwipeToReceive {
        static let pleaseLoginToLoadMoreAddresses = NSLocalizedString("Please login to load more addresses.", comment: "")
    }

    struct ReceiveAsset {
        static let xPaymentRequest = NSLocalizedString("%@ payment request", comment: "Subject of the email sent when requesting for payment from another user.")
    }

    struct Backup {
        static let reminderBackupMessageFirstBitcoin = NSLocalizedString(
            "Congrats, you have bitcoin! Now let’s backup your wallet to ensure you can access your funds if you forget your password.",
            comment: "Reminder message for when the user has just received funds prior to having completed the backup phrase."
        )
        static let reminderBackupMessageHasFunds = NSLocalizedString(
            "For your security, we do not keep any passwords on file. Backup your wallet to ensure your funds are safe in case you lose your password.",
            comment: "Reminder message for when the user already has funds prior to having completed the backup phrase."
        )
    }

    struct LegacyUpgrade {
        static let upgrade = NSLocalizedString(
            "Upgrade",
            comment: "The title of the side menu entry item."
        )
        static let upgradeFeatureOne = NSLocalizedString(
            "Always know the market price",
            comment: "The description in the first view of the legacy wallet upgrade flow."
        )
        static let upgradeFeatureTwo = NSLocalizedString(
            "Easy one time wallet backup keeps you in control of your funds.",
            comment: "The description in the second view of the legacy wallet upgrade flow."
        )
        static let upgradeFeatureThree = NSLocalizedString(
            "Everything you need to store, spend and receive BTC, ETH and BCH.",
            comment: "The description in the third view of the legacy wallet upgrade flow."
        )
        static let upgradeSuccess = NSLocalizedString(
            "You are now running our most secure wallet",
            comment: "The message displayed in the alert view after completing the legacy upgrade flow."
        )
        static let upgradeSuccessTitle = NSLocalizedString(
            "Success!",
            comment: "The title of the alert view after completing the legacy upgrade flow."
        )
    }

    struct AppReviewFallbackPrompt {
        static let title = NSLocalizedString(
            "Rate Blockchain Wallet",
            comment: "The title of the fallback app review prompt."
        )
        static let message = NSLocalizedString(
            "Enjoying the Blockchain Wallet? Please take a moment to leave a review in the App Store and let others know about it.",
            comment: "The message of the fallback app review prompt."
        )
        static let affirmativeActionTitle = NSLocalizedString(
            "Yes, rate Blockchain Wallet",
            comment: "The title for the affirmative prompt action."
        )
        static let secondaryActionTitle = NSLocalizedString(
            "Ask Me Later",
            comment: "The title for the secondary prompt action."
        )
    }

    struct KYC {
        static let failedToConfirmNumber = NSLocalizedString(
            "Failed to confirm number. Please try again.",
            comment: "Error message displayed to the user when the mobile confirmation steps fails."
        )
    }
}

// TODO: deprecate this once Obj-C is no longer using this
/// LocalizationConstants class wrapper so that LocalizationConstants can be accessed from Obj-C.
@objc class LocalizationConstantsObjcBridge: NSObject {
    @objc class func continueString() -> String { return LocalizationConstants.continueString }

    @objc class func warning() -> String { return LocalizationConstants.Errors.warning }

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

    @objc class func secondPasswordDefaultDescription() -> String { return LocalizationConstants.Authentication.secondPasswordDefaultDescription }

    @objc class func privateKeyNeeded() -> String { return LocalizationConstants.Authentication.privateKeyNeeded }

    @objc class func privateKeyDefaultDescription() -> String { return LocalizationConstants.Authentication.privateKeyPasswordDefaultDescription }

    @objc class func success() -> String { return LocalizationConstants.success }

    @objc class func syncingWallet() -> String { return LocalizationConstants.syncingWallet }

    @objc class func loadingImportKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingImportKey }

    @objc class func loadingProcessingKey() -> String { return LocalizationConstants.AddressAndKeyImport.loadingProcessingKey }

    @objc class func incorrectBip38Password() -> String { return LocalizationConstants.AddressAndKeyImport.incorrectBip38Password }

    @objc class func scanQRCode() -> String { return LocalizationConstants.scanQRCode }

    @objc class func nameAlreadyInUse() -> String { return LocalizationConstants.Errors.nameAlreadyInUse }

    @objc class func unknownKeyFormat() -> String { return LocalizationConstants.AddressAndKeyImport.unknownKeyFormat }

    @objc class func unsupportedPrivateKey() -> String { return LocalizationConstants.AddressAndKeyImport.unsupportedPrivateKey }

    @objc class func cookiePolicy() -> String { return LocalizationConstants.Settings.cookiePolicy }

    @objc class func gettingQuote() -> String { return LocalizationConstants.Exchange.gettingQuote }

    @objc class func confirming() -> String { return LocalizationConstants.Exchange.confirming }

    @objc class func loadingTransactions() -> String { return LocalizationConstants.Exchange.loadingTransactions }

    @objc class func xPaymentRequest() -> String { return LocalizationConstants.ReceiveAsset.xPaymentRequest }

    @objc class func invalidXAddressY() -> String { return LocalizationConstants.SendAsset.invalidXAddressY }

    @objc class func reminderBackupMessageFirstBitcoin() -> String { return LocalizationConstants.Backup.reminderBackupMessageFirstBitcoin }

    @objc class func reminderBackupMessageHasFunds() -> String { return LocalizationConstants.Backup.reminderBackupMessageHasFunds }

    @objc class func upgradeSuccess() -> String { return LocalizationConstants.LegacyUpgrade.upgradeSuccess }

    @objc class func upgradeSuccessTitle() -> String { return LocalizationConstants.LegacyUpgrade.upgradeSuccessTitle }

    @objc class func upgrade() -> String { return LocalizationConstants.LegacyUpgrade.upgrade }

    @objc class func upgradeFeatureOne() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureOne }

    @objc class func upgradeFeatureTwo() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureTwo }

    @objc class func upgradeFeatureThree() -> String { return LocalizationConstants.LegacyUpgrade.upgradeFeatureThree }

    @objc class func useBiometricsAsPin() -> String { return LocalizationConstants.Settings.useBiometricsAsPin }

    @objc class func biometryWarning() -> String { return LocalizationConstants.Biometrics.biometryWarning }

    @objc class func biometricInstructions() -> String { return LocalizationConstants.Onboarding.biometricInstructions }

    @objc class func enableBiometrics() -> String { return LocalizationConstants.Biometrics.enableX }

    @objc class func nonSpendable() -> String { return LocalizationConstants.AddressAndKeyImport.nonSpendable }

    @objc class func dontShowAgain() -> String { return LocalizationConstants.dontShowAgain }

    @objc class func loadingExchange() -> String { return LocalizationConstants.Exchange.loading }

    @objc class func etherSecondPasswordPrompt() -> String { return LocalizationConstants.Authentication.etherSecondPasswordPrompt }

    @objc class func myEtherWallet() -> String { return LocalizationConstants.myEtherWallet }
}
