// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

/// I'm adding this special enum here so that we have access from most places where Localization module is imported.
/// This is a part of moving away from the term `Private Key Wallet` and replacing it with `DeFi Wallet` which we don't
/// want to translate.
public enum NonLocalizedConstants {

    /// Returns the string of `DeFi Wallet` which is not translated.
    public static let defiWalletTitle = "DeFi Wallet"
}

public enum LocalizationConstants {

    public static let searchPlaceholder = NSLocalizedString(
        "Search",
        comment: "Search bar: generic placeholder"
    )
    public static let searchCancelButtonTitle = NSLocalizedString(
        "Cancel",
        comment: "Search bar: cancel button"
    )

    public static let no = NSLocalizedString("No", comment: "No")
    public static let yes = NSLocalizedString("Yes", comment: "Yes")
    public static let wallet = NSLocalizedString("Wallet", comment: "Wallet")
    public static let verified = NSLocalizedString("Verified", comment: "")
    public static let unverified = NSLocalizedString("Unverified", comment: "")
    public static let verify = NSLocalizedString("Verify", comment: "")
    public static let beginNow = NSLocalizedString("Begin Now", comment: "")
    public static let enterCode = NSLocalizedString("Enter Verification Code", comment: "")
    public static let tos = NSLocalizedString("Terms of Service", comment: "")
    public static let touchId = NSLocalizedString("Touch ID", comment: "")
    public static let faceId = NSLocalizedString("Face ID", comment: "")
    public static let disable = NSLocalizedString("Disable", comment: "")
    public static let disabled = NSLocalizedString("Disabled", comment: "")
    public static let unknown = NSLocalizedString("Unknown", comment: "")
    public static let unconfirmed = NSLocalizedString("Unconfirmed", comment: "")
    public static let enable = NSLocalizedString("Enable", comment: "")
    public static let changeEmail = NSLocalizedString("Change Email", comment: "")
    public static let addEmail = NSLocalizedString("Add Email", comment: "")
    public static let newEmail = NSLocalizedString("New Email Address", comment: "")
    public static let settings = NSLocalizedString("Settings", comment: "")
    public static let addNew = NSLocalizedString("+Add New", comment: "+Add New")
    public static let activeRewardsAccount = NSLocalizedString("Active Rewards Account", comment: "Rewards Account")
    public static let rewardsAccount = NSLocalizedString("Rewards Account", comment: "Rewards Account")
    public static let stakingAccount = NSLocalizedString("Staking Account", comment: "Staking Account")
    public static let balances = NSLocalizedString(
        "Balances",
        comment: "Generic translation, may be used in multiple places."
    )

    public static let accountEndingIn = NSLocalizedString("Account Ending in", comment: "Account Ending in")
    public static let savingsAccount = NSLocalizedString("Savings Account", comment: "Savings Account")
    public static let more = NSLocalizedString("More", comment: "")
    public static let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "")
    public static let information = NSLocalizedString("Information", comment: "")
    public static let cancel = NSLocalizedString("Cancel", comment: "")
    public static let close = NSLocalizedString("Close", comment: "")
    public static let continueString = NSLocalizedString("Continue", comment: "")
    public static let okString = NSLocalizedString("OK", comment: "")
    public static let success = NSLocalizedString("Success", comment: "")
    public static let syncingWallet = NSLocalizedString("Syncing Wallet", comment: "")
    public static let tryAgain = NSLocalizedString("Try again", comment: "")
    public static let verifying = NSLocalizedString("Verifying", comment: "")
    public static let openArg = NSLocalizedString("Open %@", comment: "")
    public static let youWillBeLeavingTheApp = NSLocalizedString("You will be leaving the app.", comment: "")
    public static let openMailApp = NSLocalizedString("Open Email App", comment: "")
    public static let goToSettings = NSLocalizedString("Go to Settings", comment: "")
    public static let twostep = NSLocalizedString("Enable 2-Step", comment: "")
    public static let localCurrency = NSLocalizedString("Select Your Currency", comment: "")
    public static let localCurrencyDescription = NSLocalizedString(
        "Your local currency to store funds in that currency as funds in your Blockchain Wallet.",
        comment: "Your local currency to store funds in that currency as funds in your Blockchain Wallet."
    )
    public static let scanQRCode = NSLocalizedString("Scan a QR Code", comment: "")
    public static let scanPairingCode = NSLocalizedString("Scan Pairing Code", comment: " ")
    public static let parsingPairingCode = NSLocalizedString("Parsing Pairing Code", comment: " ")
    public static let invalidPairingCode = NSLocalizedString("Invalid Pairing Code", comment: " ")
    public static let noCameraAccessTitle = NSLocalizedString("No camera access", comment: "title: Camera access is not available")
    public static let noCameraAccessMessage = NSLocalizedString("There is a problem connecting to your camera, please check the permissions and try again", comment: "message: Camera access is not available")

    public static let dontShowAgain = NSLocalizedString(
        "Don’t show again",
        comment: "Text displayed to the user when an action has the option to not be asked again."
    )
    public static let loading = NSLocalizedString(
        "Loading",
        comment: "Text displayed when there is an asynchronous action that needs to complete before the user can take further action."
    )
    public static let learnMore = NSLocalizedString(
        "Learn More",
        comment: "Learn more button"
    )

    public static let availableTo = NSLocalizedString("Available to", comment: "Available to")
    public static let accounts = NSLocalizedString("Accounts", comment: "Accounts")

    public enum Errors {
        public static let genericError = NSLocalizedString(
            "An error occurred. Please try again.",
            comment: "Generic error message displayed when an error occurs."
        )
        public static let error = NSLocalizedString("Error", comment: "")
        public static let errorCode = NSLocalizedString("Error code", comment: "")
        public static let pleaseTryAgain = NSLocalizedString("Please try again", comment: "message shown when an error occurs and the user should attempt the last action again")
        public static let loadingSettings = NSLocalizedString("loading Settings", comment: "")
        public static let errorLoadingWallet = NSLocalizedString("Unable to load wallet due to no server response. You may be offline or Blockchain is experiencing difficulties. Please try again later.", comment: "")
        public static let cannotOpenURLArg = NSLocalizedString("Cannot open URL %@", comment: "")
        public static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
        public static let twoStep = NSLocalizedString("An error occurred while changing 2-Step verification.", comment: "")
        public static let network = NSLocalizedString("Network Error", comment: "Network Error title")
        public static let noInternetConnection = NSLocalizedString("No internet connection.", comment: "")
        public static let noInternetConnectionPleaseCheckNetwork = NSLocalizedString("No internet connection available. Please check your network settings.", comment: "")
        public static let warning = NSLocalizedString("Warning", comment: "")
        public static let checkConnection = NSLocalizedString("Please check your internet connection.", comment: "")
        public static let timedOut = NSLocalizedString("Connection timed out. Please check your internet connection.", comment: "")
        public static let siteMaintenanceError = NSLocalizedString("Blockchain’s servers are currently under maintenance. Please try again later", comment: "")
        public static let invalidServerResponse = NSLocalizedString("Invalid server response. Please try again later.", comment: "")
        public static let invalidStatusCodeReturned = NSLocalizedString("Invalid Status Code Returned %@", comment: "")
        public static let requestFailedCheckConnection = NSLocalizedString("Blockchain Wallet cannot obtain an Internet connection. Please check the connectivity on your device and try again.", comment: "")
        public static let errorLoadingWalletIdentifierFromKeychain = NSLocalizedString("An error was encountered retrieving your wallet identifier from the keychain. Please close the application and try again.", comment: "")
        public static let cameraAccessDenied = NSLocalizedString("Camera Access Denied", comment: "")
        public static let cameraAccessDeniedMessage = NSLocalizedString("Blockchain does not have access to the camera. To enable access, go to your device Settings.", comment: "")
        public static let microphoneAccessDeniedMessage = NSLocalizedString("Blockchain does not have access to the microphone. To enable access, go to your device Settings.", comment: "")
        public static let nameAlreadyInUse = NSLocalizedString("This name is already in use. Please choose a different name.", comment: "")
        public static let failedToRetrieveDevice = NSLocalizedString("Unable to retrieve the input device.", comment: "AVCaptureDeviceError: failedToRetrieveDevice")
        public static let inputError = NSLocalizedString("There was an error with the device input.", comment: "AVCaptureDeviceError: inputError")
        public static let noEmail = NSLocalizedString("Please provide an email address.", comment: "")
        public static let differentEmail = NSLocalizedString("New email must be different", comment: "")
        public static let failedToValidateCertificateTitle = NSLocalizedString("Failed to validate server certificate", comment: "Message shown when the app has detected a possible man-in-the-middle attack.")
        public static let failedToValidateCertificateMessage = NSLocalizedString(
            """
            A connection cannot be established because the server certificate could not be validated. Please check your network settings and ensure that you are using a secure connection.
            """, comment: "Message shown when the app has detected a possible man-in-the-middle attack."
        )
        public static let notEnoughXForFees = NSLocalizedString("Not enough %@ for fees", comment: "Message shown when the user has attempted to send more funds than the user can spend (input amount plus fees)")
        public static let balancesGeneric = NSLocalizedString("We are experiencing a service issue that may affect displayed balances. Don't worry, your funds are safe.", comment: "Message shown when an error occurs while fetching balance or transaction history")
        public static let noSourcesAvailable = NSLocalizedString("%@ is not available in your region.", comment: "Error title shown when there are no accounts available in your region")
        public static let noSourcesAvailableMessage = NSLocalizedString("At the moment we do not support %@ in your region, you may still use the wallet to manage your crypto.", comment: "Error message shown when there are no accounts available in your region")
        public static let insufficientInterestWithdrawalBalance = NSLocalizedString("Unable to Withdraw", comment: "Error title shown when the customer is unable to withdraw their crypto from the interest account.")
        public static let insufficientInterestWithdrawalBalanceMessage = NSLocalizedString("You do not have sufficient balance to withdraw from your rewards account, we have a 7 day holding period for interest accounts - if you believe this to be incorrect and a problem, please contact support.", comment: "Error message shown when the customer is unable to withdraw their crypto from the interest account.")
    }

    public enum Authentication {

        public enum Support {
            public static let title = NSLocalizedString("Having Trouble Logging In?", comment: "Having Trouble Logging In?")
            public static let description = NSLocalizedString("We're here to help. Explore common log in issues below in FAQs or if you'd prefer to chat with a member of our support team, select live chat or our email form below.", comment: "We're here to help. Explore common log in issues below in FAQs or if you'd prefer to chat with a member of our support team, select live chat or our email form below.")
            public static let chatNow = NSLocalizedString("Chat Now", comment: "Chat Now")
            public static let contactUs = NSLocalizedString("Contact Us", comment: "Contact Us")
            public static let viewFAQ = NSLocalizedString("View FAQs", comment: "View FAQs")
            public static let version = NSLocalizedString("iOS Version", comment: "iOS Version")
            public static let latestVersion = NSLocalizedString("Latest Version", comment: "Latest Version")
            public static let newVersionAvailable = NSLocalizedString("New Version Available", comment: "New Version Available")
        }

        public enum CountryAndStatePickers {
            public static let suggestedSelectionTitle = NSLocalizedString(
                "Suggested",
                comment: "Country and State Pickers: Suggested Section Title"
            )

            public static let countriesPickerTitle = NSLocalizedString(
                "Select Your Country",
                comment: "Country Picker: Page Title"
            )
            public static let countriesPickerSubtitle = NSLocalizedString(
                "What country do you live in?",
                comment: "Country Picker: Page Subtitle"
            )
            public static let countriesSectionTitle = NSLocalizedString(
                "Countries",
                comment: "Country Picker: Countries Section Title"
            )

            public static let statesPickerTitle = NSLocalizedString(
                "Select Your State",
                comment: "State Picker: Page Title"
            )
            public static let statesPickerSubtitle = NSLocalizedString(
                "What State do you live in?",
                comment: "State Picker: Page Subtitle"
            )
            public static let statesSectionTitle = NSLocalizedString(
                "States",
                comment: "State Picker: States Section Title"
            )
        }

        public enum DefaultPasswordScreen {
            public static let title = NSLocalizedString(
                "Second Password Required",
                comment: "Password screen: title for general action"
            )
            public static let description = NSLocalizedString(
                "To use this service, we require you to enter your second password.",
                comment: "Password screen: description"
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "Password screen: continue button"
            )
        }

        public enum ImportKeyPasswordScreen {
            public static let title = NSLocalizedString(
                "Private Key Needed",
                comment: "Password screen: title for general action"
            )
            public static let description = NSLocalizedString(
                "The private key you are attempting to import is encrypted. Please enter the password below.",
                comment: "Password screen: description"
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "Password screen: continue button"
            )
        }

        public enum EtherPasswordScreen {
            public static let title = NSLocalizedString(
                "Second Password Required",
                comment: "Password screen: title for general action"
            )
            public static let description = NSLocalizedString(
                "To use this service, we require you to enter your second password. You should only need to enter this once to set up your Ether wallet.",
                comment: "Password screen: description"
            )
            public static let button = NSLocalizedString(
                "Continue",
                comment: "Password screen: continue button"
            )
        }

        public static let password = NSLocalizedString("Password", comment: "")
        public static let secondPasswordIncorrect = NSLocalizedString("Second Password Incorrect", comment: "")
        public static let recoveryPhrase = NSLocalizedString("Backup phrase", comment: "")
        public static let twoStepSMS = NSLocalizedString("2-Step has been enabled for SMS", comment: "")
        public static let twoStepOff = NSLocalizedString("2-Step has been disabled.", comment: "")
        public static let checkLink = NSLocalizedString("Please check your email and click on the verification link.", comment: "")
        public static let googleAuth = NSLocalizedString("Google Authenticator", comment: "")
        public static let yubiKey = NSLocalizedString("Yubi Key", comment: "")
        public static let enableTwoStep = NSLocalizedString(
            """
            You can enable 2-step Verification via SMS on your mobile phone. In order to use other authentication methods instead, please login to our web wallet.
            """, comment: ""
        )
        public static let verifyEmail = NSLocalizedString("Please verify your email address first.", comment: "")
        public static let resendVerificationEmail = NSLocalizedString("Resend verification email", comment: "")

        public static let resendVerification = NSLocalizedString("Resend verification SMS", comment: "")
        public static let enterVerification = NSLocalizedString("Enter your verification code", comment: "")
        public static let errorDecryptingWallet = NSLocalizedString("An error occurred due to interruptions during PIN verification. Please close the app and try again.", comment: "")
        public static let hasVerified = NSLocalizedString("Your mobile number has been verified.", comment: "")
        public static let invalidSharedKey = NSLocalizedString("Invalid Shared Key", comment: "")
        public static let forgotPassword = NSLocalizedString("Forgot Password?", comment: "")
        public static let passwordRequired = NSLocalizedString("Password Required", comment: "")
        public static let loadingWallet = NSLocalizedString("Loading Your Wallet", comment: "")
        public static let noPasswordEntered = NSLocalizedString("No Password Entered", comment: "")
        public static let failedToLoadWallet = NSLocalizedString("Failed To Load Wallet", comment: "")
        public static let failedToLoadWalletDetail = NSLocalizedString("An error was encountered loading your wallet. You may be offline or Blockchain is experiencing difficulties. Please close the application and try again later or re-pair your device.", comment: "")
        public static let forgetWallet = NSLocalizedString("Forget Wallet", comment: "")
        public static let forgetWalletDetail = NSLocalizedString("This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere otherwise any bitcoin in this wallet will be inaccessible!!", comment: "")
        public static let enterPassword = NSLocalizedString("Enter Password", comment: "")
        public static let retryValidation = NSLocalizedString("Retry Validation", comment: "")
        public static let manualPairing = NSLocalizedString("Manual Pairing", comment: "")
        public static let invalidTwoFactorAuthenticationType = NSLocalizedString("Invalid two-factor authentication type", comment: "")
        public static let recaptchaVerificationFailure = NSLocalizedString("Couldn't create your wallet, please try again.", comment: "")
    }

    public enum Pin {
        public enum Accessibility {
            public static let faceId = NSLocalizedString(
                "Face id authentication",
                comment: "Accessiblity label for face id biometrics authentication"
            )

            public static let touchId = NSLocalizedString(
                "Touch id authentication",
                comment: "Accessiblity label for touch id biometrics authentication"
            )

            public static let backspace = NSLocalizedString(
                "Backspace button",
                comment: "Accessiblity label for backspace button"
            )
        }

        public enum LogoutAlert {
            public static let title = NSLocalizedString(
                "Log Out",
                comment: "Log out alert title"
            )

            public static let message = NSLocalizedString(
                "Do you really want to log out?",
                comment: "Log out alert message"
            )
        }

        public static let enableFaceIdTitle = NSLocalizedString(
            "Enable Face ID",
            comment: "Title for alert letting the user to enable face id"
        )

        public static let enableTouchIdTitle = NSLocalizedString(
            "Enable Touch ID",
            comment: "Title for alert letting the user to enable touch id"
        )

        public static let enableBiometricsMessage = NSLocalizedString(
            "Quickly sign into your wallet instead of using your PIN.",
            comment: "Title for alert letting the user to enable biometrics authenticators"
        )

        public static let enableBiometricsNotNowButton = NSLocalizedString(
            "Not now",
            comment: "Cancel button for alert letting the user to enable biometrics authenticators"
        )

        public static let logoutButton = NSLocalizedString(
            "Log Out",
            comment: "Button for opting out in the PIN screen"
        )

        public static let changePinTitle = NSLocalizedString(
            "Change PIN",
            comment: "Title for changing PIN flow"
        )

        public static let pinSuccessfullySet = NSLocalizedString(
            "Your New PIN is Ready",
            comment: "PIN was set successfully message label"
        )

        public static let createYourPinLabel = NSLocalizedString(
            "Create Your PIN",
            comment: "Create PIN code title label"
        )

        public static let confirmYourPinLabel = NSLocalizedString(
            "Confirm Your PIN",
            comment: "Confirm PIN code title label"
        )

        public static let enterYourPinLabel = NSLocalizedString(
            "Enter Your PIN",
            comment: "Enter PIN code title label"
        )

        public static let tooManyAttemptsTitle = NSLocalizedString(
            "Too Many PIN Attempts",
            comment: "Title for alert that tells the user he had too many PIN attempts"
        )

        public static let tooManyAttemptsWarningMessage = NSLocalizedString(
            "You've made too many failed attempts to log in with your PIN. Please try again in 60 seconds.",
            comment: "Warning essage for alert that tells the user he had too many PIN attempts"
        )

        public static let CannotLoginTitle = NSLocalizedString(
            "Can't log in?",
            comment: "Title for alert that instructs users what to do if they cannot log in with their PIN"
        )

        public static let CannotLoginMessage = NSLocalizedString(
            "To access your Wallet, please log in on the web.\nBelow is what you'll need.",
            comment: "Alert message that instructs users what to do if they cannot log in with their PIN"
        )

        public static let CannotLoginRemarkMessage = NSLocalizedString(
            "If your account has added security measures like Google Authenticator, please have that ready.",
            comment: "Remark message that instructs users to prepare any 2FA measures for logging in with web."
        )

        public static let tooManyAttemptsLogoutMessage = NSLocalizedString(
            "Please log in with your Wallet ID and password.",
            comment: "Message for alert that tells the user he had too many PIN attempts, and his account is now logged out"
        )

        public static let genericError = NSLocalizedString(
            "An error occured. Please try again",
            comment: "Fallback error for all other errors that may occur during the PIN validation/change flow."
        )
        public static let newPinMustBeDifferent = NSLocalizedString(
            "Your new PIN must be different",
            comment: "Error message displayed to the user that they must enter a PIN code that is different from their previous PIN."
        )
        public static let chooseAnotherPin = NSLocalizedString(
            "Please choose another PIN",
            comment: "Error message displayed to the user when they must enter another PIN code."
        )

        public static let incorrect = NSLocalizedString(
            "Incorrect PIN",
            comment: "Error message displayed when the entered PIN is incorrect and the user should try to enter the PIN code again."
        )
        public static let backoff = NSLocalizedString(
            "PIN Disabled",
            comment: "Error message displayed when the user entered a PIN in when the PIN function is locked due to exponential backoff retry algorithm."
        )
        public static let tryAgain = NSLocalizedString(
            "Try again in",
            comment: "Error message displayed when the user entered wrong PIN or PIN function is locked. Prompts user to try again later"
        )
        public static let seconds = NSLocalizedString(
            "s",
            comment: "Time indicator for how much seconds to wait before retrying a PIN"
        )
        public static let minutes = NSLocalizedString(
            "m",
            comment: "Time indicator for how much minutes to wait before retrying a PIN"
        )
        public static let hours = NSLocalizedString(
            "h",
            comment: "Time indicator for how much hours to wait before retrying a PIN"
        )
        public static let pinsDoNotMatch = NSLocalizedString(
            "PINs don't match",
            comment: "Message presented to user when they enter an incorrect PIN when confirming a PIN."
        )
        public static let cannotSaveInvalidWalletState = NSLocalizedString(
            "Cannot save PIN Code while wallet is not initialized or password is null",
            comment: "Error message displayed when the wallet is in an invalid state and the user tried to enter a new PIN code."
        )
        public static let responseKeyOrValueLengthZero = NSLocalizedString(
            "PIN Response Object key or value length 0",
            comment: "Error message displayed to the user when the PIN-store endpoint is returning an invalid response."
        )
        public static let responseSuccessLengthZero = NSLocalizedString(
            "PIN response Object success length 0",
            comment: "Error message displayed to the user when the PIN-store endpoint is returning an invalid response."
        )
        public static let decryptedPasswordLengthZero = NSLocalizedString(
            "Decrypted PIN Password length 0",
            comment: "Error message displayed when the user’s decrypted password length is 0."
        )
        public static let validationError = NSLocalizedString(
            "PIN Validation Error",
            comment: "Title of the error message displayed to the user when their PIN cannot be validated if it is correct."
        )
        public static let validationErrorMessage = NSLocalizedString(
            """
            An error occurred validating your PIN code with the remote server. You may be offline or Blockchain may be experiencing difficulties. Would you like retry validation or instead enter your password manually?
            """, comment: "Error message displayed to the user when their PIN cannot be validated if it is correct."
        )

        public enum WebLoginInstructions {
            public enum Title {
                public static let walletIdOrEmail = NSLocalizedString(
                    "Wallet ID or Email",
                    comment: "An instruction title for logging in using Wallet ID or Email"
                )
                public static let password = NSLocalizedString(
                    "Your Password",
                    comment: "An instruction title for logging in using password"
                )
            }

            public enum Details {
                public static let walletIdOrEmail = NSLocalizedString(
                    "Use your email address or the Wallet ID. Locate your Wallet ID at the bottom of most Blockchain.com emails.",
                    comment: "An instruction details for logging in using Wallet ID or Email"
                )
                public static let password = NSLocalizedString(
                    "This is the unique password you entered when creating your wallet.",
                    comment: "An instruction details for logging in using Personal Password"
                )
            }
        }

        public enum Button {
            public static let toWebLogin = NSLocalizedString(
                "Log In on the Web ->",
                comment: "A CTA Button to go to login.blockchain.com website"
            )
        }
    }

    public enum DeepLink {
        public static let deepLinkUpdateTitle = NSLocalizedString(
            "Link requires app update",
            comment: "Title of alert shown if the deep link requires a newer version of the app."
        )
        public static let deepLinkUpdateMessage = NSLocalizedString(
            "The link you have used is not supported on this version of the app. Please update the app to access this link.",
            comment: "Message of alert shown if the deep link requires a newer version of the app."
        )
        public static let updateNow = NSLocalizedString(
            "Update Now",
            comment: "Action of alert shown if the deep link requires a newer version of the app."
        )
    }

    public enum VersionUpdate {
        public static let versionPrefix = NSLocalizedString(
            "v",
            comment: "Version top note for a `recommended` update alert"
        )

        public static let title = NSLocalizedString(
            "Update Available",
            comment: "Title for a `recommended` update alert"
        )

        public static let description = NSLocalizedString(
            "Ready for the the best Blockchain App yet? Download our latest build and get more out of your Crypto.",
            comment: "Description for a `recommended` update alert"
        )

        public static let updateNowButton = NSLocalizedString(
            "Update Now",
            comment: "`Update` button for an alert that notifies the user that a new app version is available on the store"
        )
    }

    public enum TabItems {
        public static let home = NSLocalizedString(
            "Home",
            comment: "Tab item: home"
        )
        public static let activity = NSLocalizedString(
            "Activity",
            comment: "Tab item: activity"
        )
        public static let swap = NSLocalizedString(
            "Swap",
            comment: "Tab item: swap"
        )
        public static let send = NSLocalizedString(
            "Send",
            comment: "Tab item: send"
        )
        public static let request = NSLocalizedString(
            "Request",
            comment: "Tab item: request"
        )
        public static let prices = NSLocalizedString(
            "Prices",
            comment: "Tab item: prices"
        )
        public static let buyAndSell = NSLocalizedString(
            "Buy & Sell",
            comment: "Tab item: buy and sell"
        )
        public static let rewards = NSLocalizedString(
            "Rewards",
            comment: "Tab item: rewards"
        )
        public static let nft = NSLocalizedString(
            "NFT",
            comment: "Tab item: nft"
        )
    }

    public static let openWebsite = NSLocalizedString(
        "Open Website",
        comment: "Open Website"
    )

    public enum FrequentActionItem {

        public static let swap = (
            name: NSLocalizedString(
                "Swap",
                comment: "fequent action item: Swap"
            ),
            description: NSLocalizedString(
                "Exchange for Another Crypto",
                comment: "fequent action description: Swap"
            )
        )

        public static let send = (
            name: NSLocalizedString(
                "Send",
                comment: "fequent action item: Send"
            ),
            description: NSLocalizedString(
                "Send to Any Wallet",
                comment: "fequent action description: Send"
            )
        )

        public static let receive = (
            name: NSLocalizedString(
                "Receive",
                comment: "fequent action item: Receive"
            ),
            description: NSLocalizedString(
                "Copy Your Addresses & QR Codes",
                comment: "fequent action description: Receive"
            )
        )

        public static let rewards = (
            name: NSLocalizedString(
                "Rewards",
                comment: "fequent action item: Rewards"
            ),
            description: NSLocalizedString(
                "Earn Rewards on Your Crypto",
                comment: "fequent action description: Rewards"
            )
        )

        public static let deposit = (
            name: NSLocalizedString(
                "Add Cash",
                comment: "fequent action item: Add Cash"
            ),
            description: NSLocalizedString(
                "Add Cash from Your Bank",
                comment: "fequent action description: Add Cash"
            )
        )

        public static let withdraw = (
            name: NSLocalizedString(
                "Cash Out",
                comment: "fequent action item: Cash Out"
            ),
            description: NSLocalizedString(
                "Cash Out from Your Bank",
                comment: "fequent action description: Cash Out"
            )
        )

        public static let buy = NSLocalizedString(
            "Buy",
            comment: "fequent action description: Buy"
        )

        public static let sell = NSLocalizedString(
            "Sell",
            comment: "fequent action description: Sell"
        )
    }

    public enum ErrorScreen {
        public static let title = NSLocalizedString(
            "Oops! Something Went Wrong.",
            comment: "Pending active card error screen: title"
        )
        public static let subtitle = NSLocalizedString(
            "Please go back and try again.",
            comment: "Pending active card error screen: subtitle"
        )
        public static let button = NSLocalizedString(
            "OK",
            comment: "Pending active card error screen: ok button"
        )
    }

    public enum TimeoutScreen {
        public enum Buy {
            public static let title = NSLocalizedString(
                "Your Buy Order Has Started.",
                comment: "Your Buy Order Has Started."
            )
        }

        public enum Sell {
            public static let title = NSLocalizedString(
                "Your Sell Order Has Started.",
                comment: "Your Sell Order Has Started."
            )
        }

        public static let subtitle = NSLocalizedString(
            "We’re completing your transaction now. We’ll contact you when it has finished.",
            comment: "We’re completing your transaction now. We’ll contact you when it has finished."
        )
        public static let supplementaryButton = NSLocalizedString(
            "View Transaction",
            comment: "View Transaction"
        )
        public static let button = NSLocalizedString(
            "OK",
            comment: "Pending active card error screen: ok button"
        )
    }

    public enum DashboardScreen {
        public static let title = NSLocalizedString(
            "Home",
            comment: "Dashboard screen: title label"
        )
        public static let portfolio = NSLocalizedString(
            "Portfolio",
            comment: "Dashboard screen: Portfolio tab"
        )
        public static let prices = NSLocalizedString(
            "Prices",
            comment: "Dashboard screen: Prices tab"
        )
    }

    public enum CustodyWalletInformation {
        public static let title = NSLocalizedString(
            "Trading Wallet",
            comment: "Trading Wallet"
        )
        public enum Description {
            public static let partOne = NSLocalizedString(
                "When you buy crypto, we store your funds securely for you in a Crypto Trading Wallet. These funds are stored by us on your behalf. You can keep them safe with us or transfer them to your non-custodial Wallet to own and store yourself.",
                comment: "When you buy crypto, we store your funds securely for you in a Crypto Trading Wallet. These funds are stored by us on your behalf. You can keep them safe with us or transfer them to your non-custodial Wallet to own and store yourself."
            )
            public static let partTwo = NSLocalizedString(
                "If you want to swap or send these funds, you need to transfer them to your non-custodial crypto wallet.",
                comment: "If you want to swap or send these funds, you need to transfer them to your non-custodial crypto wallet."
            )
        }
    }

    public enum Exchange {
        public static let title = NSLocalizedString("Exchange", comment: "Title for the Exchange")
        public static let launch = NSLocalizedString("Launch", comment: "Launch - opens exchange website url")
        public static let connected = NSLocalizedString("Connected", comment: "Connected")
        public static let twoFactorNotEnabled = NSLocalizedString("Please enable 2FA on your Exchange account to complete deposit.", comment: "User must have 2FA enabled to deposit from send.")
        public enum Alerts {
            public static let connectingYou = NSLocalizedString("Taking You To the Exchange", comment: "Taking You To the Exchange")
            public static let newWindow = NSLocalizedString("A new window should open within 10 seconds.", comment: "A new window should open within 10 seconds.")
            public static let success = NSLocalizedString("Success!", comment: "Success!")
            public static let successDescription = NSLocalizedString("Please return to the Exchange to complete account setup.", comment: "Please return to the Exchange to complete account setup.")
            public static let error = NSLocalizedString("Connection Error", comment: "Connection Error")
            public static let errorDescription = NSLocalizedString("We could not connect your Wallet to the Exchange. Please go back to the Exchange and try again.", comment: "We could not connect your Wallet to the Exchange. Please go back to the Exchange and try again.")
        }

        public enum EmailVerification {
            public static let title = NSLocalizedString("Verify Your Email", comment: "")
            public static let description = NSLocalizedString(
                "We just sent you a verification email. Your email address needs to be verified before you can connect to The Exchange.",
                comment: ""
            )
            public static let didNotGetEmail = NSLocalizedString("Didn't get the email?", comment: "")
            public static let sendAgain = NSLocalizedString("Send Again", comment: "")
            public static let openMail = NSLocalizedString("Open Mail", comment: "")
            public static let justAMoment = NSLocalizedString("Just a moment.", comment: "")
            public static let verified = NSLocalizedString("Email Verified", comment: "")
            public static let verifiedDescription = NSLocalizedString(
                "You're all set to connect your Blockchain Wallet to the Exchange.",
                comment: ""
            )
        }

        public enum Launch {
            public static let launchExchange = NSLocalizedString("Launch the Exchange", comment: "")
            public static let contactSupport = NSLocalizedString("Contact Support", comment: "")
        }

        public enum ConnectionPage {
            public enum Descriptors {
                public static let description = NSLocalizedString("There's a new way to trade. Link your Wallet for instant access.", comment: "Description of the exchange.")
                public static let lightningFast = NSLocalizedString("Trade Lightning Fast", comment: "")
                public static let withdrawDollars = NSLocalizedString("Deposit & Withdraw Euros/Dollars", comment: "")
                public static let accessCryptos = NSLocalizedString("Access More Cryptos", comment: "")
                public static let builtByBlockchain = NSLocalizedString("Built by Blockchain.com", comment: "")
            }

            public enum Features {
                public static let exchangeWillBeAbleTo = NSLocalizedString("Our Exchange will be able to:", comment: "")
                public static let shareStatus = NSLocalizedString("Share your Full or Limited Access status for unlimited trading", comment: "")
                public static let shareAddresses = NSLocalizedString("Sync addresses with your Wallet so you can securely sweep crypto between accounts", comment: "")
                public static let lowFees = NSLocalizedString("Low Fees", comment: "")
                public static let builtByBlockchain = NSLocalizedString("Built by Blockchain.com", comment: "")

                public static let exchangeWillNotBeAbleTo = NSLocalizedString("Will Not:", comment: "")
                public static let viewYourPassword = NSLocalizedString("Access the crypto in your wallet, access your keys, or view your password.", comment: "")
            }

            public enum Actions {
                public static let learnMore = NSLocalizedString("Learn More", comment: "")
                public static let connectNow = NSLocalizedString("Connect Now", comment: "")
            }

            public enum Send {
                public static let destination = NSLocalizedString(
                    "Exchange %@ Wallet",
                    comment: "Exchange address as per asset type"
                )
            }
        }

        public enum Send {
            public static let destination = NSLocalizedString(
                "Exchange %@ Wallet",
                comment: "Exchange address for a wallet"
            )
        }
    }

    public enum SideMenu {
        public static let logout = NSLocalizedString("Logout", comment: "")
        public static let logoutConfirm = NSLocalizedString("Do you really want to log out?", comment: "")
    }

    public enum BuySell {
        public static let tradeCompleted = NSLocalizedString("Trade Completed", comment: "")
        public static let tradeCompletedDetailArg = NSLocalizedString("The trade you created on %@ has been completed!", comment: "")
        public static let viewDetails = NSLocalizedString("View details", comment: "")
        public static let errorTryAgain = NSLocalizedString("Something went wrong, please try reopening Buy & Sell Bitcoin again.", comment: "")
        public static let buySellAgreement = NSLocalizedString(
            "By tapping Begin Now, you agree to Coinify's Terms of Service & Privacy Policy",
            comment: "Disclaimer shown when starting KYC from Buy-Sell"
        )

        public enum DeprecationError {
            public static let message = NSLocalizedString("This feature is currently unavailable on iOS. Please visit our web wallet at Blockchain.com to proceed.", comment: "")
        }
    }

    public enum AddressAndKeyImport {
        public static let copyWalletId = NSLocalizedString("Copy Wallet ID", comment: "")
        public static let copyCTA = NSLocalizedString("Copy to clipboard", comment: "")
        public static let copyWarning = NSLocalizedString(
            "Warning: Your wallet identifier is sensitive information. Copying it may compromise the security of your wallet.",
            comment: ""
        )
        public static let nonSpendable = NSLocalizedString(
            "Non-Spendable",
            comment: "Text displayed to indicate that part of the funds in the user’s wallet is not spendable."
        )
    }

    public enum WalletPicker {
        public static let title = selectAWallet
        public static let selectAWallet = NSLocalizedString("Select a Wallet", comment: "Select a Wallet")
    }

    public enum ErrorAlert {
        public static let title = NSLocalizedString(
            "Oops!",
            comment: "Generic error bottom sheet title"
        )
        public static let message = NSLocalizedString(
            "Something went wrong. Please try again.",
            comment: "Generic error bottom sheet message"
        )
        public static let button = NSLocalizedString(
            "OK",
            comment: "Generic error bottom sheet OK button"
        )
    }

    public enum Address {
        public enum Accessibility {
            public static let addressLabel = NSLocalizedString(
                "This is your address",
                comment: "Accessibility hint for the user's wallet address"
            )
            public static let addressImageView = NSLocalizedString(
                "This is your address QR code",
                comment: "Accessibility hint for the user's wallet address qr code image"
            )
            public static let copyButton = NSLocalizedString(
                "Copy",
                comment: "Accessibility hint for the user's wallet address copy button"
            )
            public static let shareButton = NSLocalizedString(
                "Share",
                comment: "Accessibility hint for the user's wallet address copy button"
            )
        }

        public static let copyButton = NSLocalizedString(
            "Copy",
            comment: "copy address button title before copy was made"
        )
        public static let copiedButton = NSLocalizedString(
            "Copied!",
            comment: "copy address button title after copy was made"
        )
        public static let shareButton = NSLocalizedString(
            "Share",
            comment: "share address button title"
        )
        public static let titleFormat = NSLocalizedString(
            "%@ Wallet Address",
            comment: "format for wallet address title on address screen"
        )
        public static let creatingStatusLabel = NSLocalizedString(
            "Creating a new address",
            comment: "Creating a new address status label"
        )
        public static let loginToRefreshAddress = NSLocalizedString(
            "Log in to refresh addresses",
            comment: "Message that let the user know he has to login to refresh his wallet addresses"
        )
    }

    public enum WalletAction {
        public enum Default {
            public enum Deposit {
                public static let title = NSLocalizedString("Add Cash", comment: "Add Cash")
                public enum Crypto {
                    public static let description = NSLocalizedString("Add %@ to your Rewards Account", comment: "Add %@ to your Rewards Account")
                }

                public enum Fiat {
                    public static let description = NSLocalizedString("Add cash from your bank or card", comment: "Add cash from your bank or card")
                }
            }

            public enum Withdraw {
                public static let title = NSLocalizedString("Cash Out", comment: "Cash Out")
                public static let description = NSLocalizedString("Cash out to your bank", comment: "Cash out to your bank")
            }

            public enum Transfer {
                public static let title = NSLocalizedString("Send", comment: "Send")
                public static let description = NSLocalizedString("Transfer %@ to Any Wallet", comment: "Transfer %@ to Any Wallet")
            }

            public enum Interest {
                public static let title = NSLocalizedString("Rewards Summary", comment: "Rewards Summary")
                public static let description = NSLocalizedString("View your accrued %@ Rewards", comment: "View your accrued %@ Rewards")
            }

            public enum Activity {
                public static let title = NSLocalizedString("Activity", comment: "Activity")
                public static let description = NSLocalizedString("View All Transactions", comment: "View All Transactions")
            }

            public enum Send {
                public static let title = NSLocalizedString("Send", comment: "Send")
                public static let description = NSLocalizedString("Transfer %@ to Any Wallet", comment: "Transfer %@ to Any Wallet")
            }

            public enum Sign {
                public static let title = NSLocalizedString("Sign", comment: "Sign")
            }

            public enum Receive {
                public static let title = NSLocalizedString("Receive", comment: "Receive")
                public static let description = NSLocalizedString("Accept or Share Your %@ Address", comment: "Accept or Share Your %@ Address")
            }

            public enum Swap {
                public static let title = NSLocalizedString("Swap", comment: "Swap")
                public static let description = NSLocalizedString("Exchange %@ for Another Crypto", comment: "Exchange %@ for Another Crypto")
            }

            public enum Buy {
                public static let title = NSLocalizedString("Buy", comment: "Buy")
                public static let description = NSLocalizedString("Use your Card or Cash", comment: "Use your Card or Cash")
            }

            public enum Sell {
                public static let title = NSLocalizedString("Sell", comment: "Sell")
                public static let description = NSLocalizedString("Convert Your Crypto to Cash", comment: "Convert Your Crypto to Cash")
            }
        }
    }

    public enum GeneralError {
        public static let loadingData = NSLocalizedString(
            "An error occurred while loading the data. Please try again.",
            comment: "A general data loading error display in an alert controller"
        )
    }

    public enum AuthType {
        public static let google = NSLocalizedString(
            "Google",
            comment: "2FA alert: google type"
        )
        public static let yubiKey = NSLocalizedString(
            "Yubi Key",
            comment: "2FA alert: google type"
        )
        public static let sms = NSLocalizedString(
            "SMS",
            comment: "2FA alert: sms type"
        )
    }

    public enum AccountPicker {
        public static let noWallets = NSLocalizedString(
            "No Wallets",
            comment: "Title text for account picker when no wallets are available"
        )

        public static let mostPopularSection = NSLocalizedString(
            "Most Popular",
            comment: "Most Popular Crypto Section Header"
        )

        public static let otherCryptoSection = NSLocalizedString(
            "Other Cryptos",
            comment: "Other Cryptos Section Header"
        )
    }
}

extension LocalizationConstants {
    public struct Accessibility {}
}
