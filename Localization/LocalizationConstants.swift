//
//  LocalizationConstants.swift
//  Localization
//
//  Created by AlexM on 1/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

import Foundation

public enum LocalizationConstants {

    public static let no = NSLocalizedString("No", comment: "No")
    public static let yes = NSLocalizedString("Yes", comment: "Yes")
    public static let wallet = NSLocalizedString("Wallet", comment: "Wallet")
    public static let verified = NSLocalizedString("Verified", comment: "")
    public static let unverified = NSLocalizedString("Unverified", comment: "")
    public static let verify = NSLocalizedString ("Verify", comment: "")
    public static let beginNow = NSLocalizedString("Begin Now", comment: "")
    public static let enterCode = NSLocalizedString ("Enter Verification Code", comment: "")
    public static let tos = NSLocalizedString ("Terms of Service", comment: "")
    public static let touchId = NSLocalizedString ("Touch ID", comment: "")
    public static let faceId = NSLocalizedString ("Face ID", comment: "")
    public static let disable = NSLocalizedString ("Disable", comment: "")
    public static let disabled = NSLocalizedString ("Disabled", comment: "")
    public static let unknown = NSLocalizedString ("Unknown", comment: "")
    public static let unconfirmed = NSLocalizedString("Unconfirmed", comment: "")
    public static let enable = NSLocalizedString ("Enable", comment: "")
    public static let changeEmail = NSLocalizedString ("Change Email", comment: "")
    public static let addEmail = NSLocalizedString ("Add Email", comment: "")
    public static let newEmail = NSLocalizedString ("New Email Address", comment: "")
    public static let settings = NSLocalizedString ("Settings", comment: "")
    public static let balances = NSLocalizedString(
        "Balances",
        comment: "Generic translation, may be used in multiple places."
    )

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
    public static let verifying = NSLocalizedString ("Verifying", comment: "")
    public static let openArg = NSLocalizedString("Open %@", comment: "")
    public static let youWillBeLeavingTheApp = NSLocalizedString("You will be leaving the app.", comment: "")
    public static let openMailApp = NSLocalizedString("Open Email App", comment: "")
    public static let goToSettings = NSLocalizedString("Go to Settings", comment: "")
    public static let swipeReceive = NSLocalizedString("Swipe to Receive", comment: "")
    public static let twostep = NSLocalizedString("Enable 2-Step", comment: "")
    public static let localCurrency = NSLocalizedString("Select Your Currency", comment: "")
    public static let localCurrencyDescription = NSLocalizedString(
        "Your local currency to store funds in that currency as funds in your Blockchain Wallet.",
        comment: "Your local currency to store funds in that currency as funds in your Blockchain Wallet."
    )
    public static let scanQRCode = NSLocalizedString("Scan QR Code", comment: "")
    public static let scanPairingCode = NSLocalizedString("Scan Pairing Code", comment: " ")
    public static let parsingPairingCode = NSLocalizedString("Parsing Pairing Code", comment: " ")
    public static let invalidPairingCode = NSLocalizedString("Invalid Pairing Code", comment: " ")
    
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

    public struct Errors {
        public static let genericError = NSLocalizedString(
            "An error occured. Please try again.",
            comment: "Generic error message displayed when an error occurs."
        )
        public static let error = NSLocalizedString("Error", comment: "")
        public static let pleaseTryAgain = NSLocalizedString("Please try again", comment: "message shown when an error occurs and the user should attempt the last action again")
        public static let loadingSettings = NSLocalizedString("loading Settings", comment: "")
        public static let errorLoadingWallet = NSLocalizedString("Unable to load wallet due to no server response. You may be offline or Blockchain is experiencing difficulties. Please try again later.", comment: "")
        public static let cannotOpenURLArg = NSLocalizedString("Cannot open URL %@", comment: "")
        public static let unsafeDeviceWarningMessage = NSLocalizedString("Your device appears to be jailbroken. The security of your wallet may be compromised.", comment: "")
        public static let twoStep = NSLocalizedString("An error occurred while changing 2-Step verification.", comment: "")
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
            """, comment: "Message shown when the app has detected a possible man-in-the-middle attack.")
        public static let notEnoughXForFees = NSLocalizedString("Not enough %@ for fees", comment: "Message shown when the user has attempted to send more funds than the user can spend (input amount plus fees)")
        public static let balancesGeneric = NSLocalizedString("We are experiencing a service issue that may affect displayed balances. Don't worry, your funds are safe.", comment: "Message shown when an error occurs while fetching balance or transaction history")
    }

    public struct ServerStatus {
        public static let mainTitle = NSLocalizedString(
            "Service Unavailable",
            comment: "Service Unavailable"
        )

        public static let majorOutageSubtitle = NSLocalizedString(
            "We are experiencing an outage with the wallet. Please rest assured your funds are safe.",
            comment: "We are experiencing an outage with the wallet. Please rest assured your funds are safe."
        )
        public static let learnMore = NSLocalizedString(
            " Learn more.",
            comment: " Learn more"
        )
    }

    public struct Authentication {
        public struct DefaultPasswordScreen {
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
        public struct ImportKeyPasswordScreen {
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
        public struct EtherPasswordScreen {
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
            """, comment: "")
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
    }

    public struct Pin {
        public struct Accessibility {
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
            
            public static let swipeHint = NSLocalizedString(
                "Swipe right to see your addresses",
                comment: "Accessiblity hint for swipe to receive label"
            )
        }
        
        public struct LogoutAlert {
            public static let title = NSLocalizedString(
                "Log Out",
                comment: "Log out alert title"
            )
            
            public static let message = NSLocalizedString(
                "Do you really want to log out?",
                comment: "Log out alert message"
            )
        }
        
        public static let swipeToReceiveLabel = NSLocalizedString(
            "Swipe to receive",
            comment: "Title label indicating the can swipe the screen to see his wallet addresses on login"
        )
        
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
        
        public static let tooManyAttemptsMessage = NSLocalizedString(
            "Please enter your wallet password.",
            comment: "Message for alert that tells the user he had too many PIN attempts"
        )
        
        public static let revealAddress = NSLocalizedString(
        """
        Enable this option to reveal a receive address when you swipe left on the PIN screen, making
        receiving bitcoin even faster. Five addresses will be loaded consecutively, after which logging in is
        required to show new addresses.
        """, comment: "")

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
    }

    public struct DeepLink {
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
    
    public struct Dashboard {
        public struct Balance {
            public static let totalBalance = NSLocalizedString(
                "Total Balance",
                comment: "Dashboard: total balance component - title"
            )
            public static let notice = NSLocalizedString(
                "You have a pending {swap/buy/sell} order that may impact your total balance.",
                comment: "Dashboard: balance notice"
            )
            public static let lockboxNotice = NSLocalizedString(
                "The Total Balance shown on this device does not include your linked Lockbox.",
                comment: "Dashboard: lockbox notice"
            )
        }
    
        public static let chartsError = NSLocalizedString(
            "An error occurred while retrieving the latest chart data. Please try again later.",
            comment: "The error message for when the method fetchChartDataForAsset fails."
        )
        public static let bitcoinPrice = NSLocalizedString(
            "Bitcoin Price",
            comment: "The title of the Bitcoin price chart on the dashboard."
        )
        public static let etherPrice = NSLocalizedString(
            "Ether Price",
            comment: "The title of the Ethereum price chart on the dashboard."
        )
        public static let bitcoinCashPrice = NSLocalizedString(
            "Bitcoin Cash Price",
            comment: "The title of the Bitcoin Cash price chart on the dashboard."
        )
        public static let stellarPrice = NSLocalizedString(
            "Stellar Price",
            comment: "The title of the Stellar price chart on the dashboard."
        )
        public static let seeCharts = NSLocalizedString(
            "See Charts",
            comment: "The title of the action button in the price preview views."
        )
        public static let activity = NSLocalizedString("Activity", comment: "Activity tab item")
        public static let send = NSLocalizedString("Send", comment: "Send tab item")
        public static let request = NSLocalizedString("Request", comment: "request tab item")
    }

    public struct VersionUpdate {
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
    
    public struct TabItems {
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

    public struct DashboardScreen {
        public static let title = NSLocalizedString(
            "Home",
            comment: "Dashboard screen: title label"
        )
    }
    
    public struct CustodyWalletInformation {
        public static let title = NSLocalizedString(
            "Trading Wallet",
            comment: "Trading Wallet"
        )
        public struct Description {
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
    
    public struct Exchange {
        public static let title = NSLocalizedString("Exchange", comment: "Title for the Exchange")
        public static let connect = NSLocalizedString("Connect", comment: "Connect")
        public static let connected = NSLocalizedString("Connected", comment: "Connected")
        public static let twoFactorNotEnabled = NSLocalizedString("Please enable 2FA on your Exchange account to complete deposit.", comment: "User must have 2FA enabled to deposit from send.")
        public struct Alerts {
            public static let connectingYou = NSLocalizedString("Taking You To the Exchange", comment: "Taking You To the Exchange")
            public static let newWindow = NSLocalizedString("A new window should open within 10 seconds.", comment: "A new window should open within 10 seconds.")
            public static let success = NSLocalizedString("Success!", comment: "Success!")
            public static let successDescription = NSLocalizedString("Please return to the Exchange to complete account setup.", comment: "Please return to the Exchange to complete account setup.")
            public static let error = NSLocalizedString("Connection Error", comment: "Connection Error")
            public static let errorDescription = NSLocalizedString("We could not connect your Wallet to the Exchange. Please go back to the Exchange and try again.", comment: "We could not connect your Wallet to the Exchange. Please go back to the Exchange and try again.")
        }
        public struct EmailVerification {
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
        public struct Launch {
            public static let launchExchange = NSLocalizedString("Launch the Exchange", comment: "")
            public static let contactSupport = NSLocalizedString("Contact Support", comment: "")
        }
        public struct ConnectionPage {
            public struct Descriptors {
                public static let description = NSLocalizedString("There's a new way to trade. Link your Wallet for instant access.", comment: "Description of the exchange.")
                public static let lightningFast = NSLocalizedString("Trade Lightning Fast", comment: "")
                public static let withdrawDollars = NSLocalizedString("Deposit & Withdraw Euros/Dollars", comment: "")
                public static let accessCryptos = NSLocalizedString("Access More Cryptos", comment: "")
                public static let builtByBlockchain = NSLocalizedString("Built by Blockchain.com", comment: "")
            }
            
            public struct Features {
                public static let exchangeWillBeAbleTo = NSLocalizedString("Our Exchange will be able to:", comment: "")
                public static let shareStatus = NSLocalizedString("Share your Gold or Silver Level status for unlimited trading", comment: "")
                public static let shareAddresses = NSLocalizedString("Sync addresses with your Wallet so you can securely sweep crypto between accounts", comment: "")
                public static let lowFees = NSLocalizedString("Low Fees", comment: "")
                public static let builtByBlockchain = NSLocalizedString("Built by Blockchain.com", comment: "")
                
                public static let exchangeWillNotBeAbleTo = NSLocalizedString("Will Not:", comment: "")
                public static let viewYourPassword = NSLocalizedString("Access the crypto in your wallet, access your keys, or view your password.", comment: "")
            }
            
            public struct Actions {
                public static let learnMore = NSLocalizedString("Learn More", comment: "")
                public static let connectNow = NSLocalizedString("Connect Now", comment: "")
            }
            
            public struct Send {
                public static let destination = NSLocalizedString(
                    "Exchange %@ Wallet",
                    comment: "Exchange address as per asset type"
                )
            }
        }
        
        public struct Send {
            public static let destination = NSLocalizedString(
                "Exchange %@ Wallet",
                comment: "Exchange address for a wallet"
            )
        }
    }

    public struct SideMenu {
        public static let loginToWebWallet = NSLocalizedString("Pair Web Wallet", comment: "")
        public static let logout = NSLocalizedString("Logout", comment: "")
        public static let debug = NSLocalizedString("Debug", comment: "")
        public static let logoutConfirm = NSLocalizedString("Do you really want to log out?", comment: "")
        public static let buySellBitcoin = NSLocalizedString(
            "Buy & Sell Bitcoin",
            comment: "Item displayed on the side menu of the app for when the user wants to buy and sell Bitcoin."
        )
        public static let buyCrypto = NSLocalizedString(
            "Buy Crypto",
            comment: "Item displayed on the side menu of the app for when the user wants to buy crypto."
        )
        public static let sellCrypto = NSLocalizedString(
            "Sell Crypto",
            comment: "Item displayed on the side menu of the app for when the user wants to sell crypto."
        )
        public static let addresses = NSLocalizedString(
            "Addresses",
            comment: "Item displayed on the side menu of the app for when the user wants to view their crypto addresses."
        )
        public static let backupFunds = NSLocalizedString(
            "Secret Private Key Recovery Phrase",
            comment: "Item displayed on the side menu of the app for when the user wants to back up their funds by saving their 12 word mneumonic phrase."
        )
        public static let airdrops = NSLocalizedString(
            "Airdrops",
            comment: "Item displayed on the side menu of the app for airdrop center navigation"
        )
        public static let swap = NSLocalizedString(
            "Swap",
            comment: "Item displayed on the side menu of the app for when the user wants to exchange crypto-to-crypto."
        )
        public static let settings = NSLocalizedString(
            "Settings",
            comment: "Item displayed on the side menu of the app for when the user wants to view their wallet settings."
        )
        public static let support = NSLocalizedString(
            "Support",
            comment: "Item displayed on the side menu of the app for when the user wants to contact support."
        )
        public static let new = NSLocalizedString(
            "New",
            comment: "New tag shown for menu items that are new."
        )
        public static let lockbox = NSLocalizedString(
            "Lockbox",
            comment: "Lockbox menu item title."
        )
        public static let exchange = NSLocalizedString(
            "Exchange",
            comment: "The Exchange"
        )
        public static let secureChannel = NSLocalizedString(
            "Web Log In",
            comment: "Web Log In menu item title."
        )
    }

    public struct BuySell {
        public static let tradeCompleted = NSLocalizedString("Trade Completed", comment: "")
        public static let tradeCompletedDetailArg = NSLocalizedString("The trade you created on %@ has been completed!", comment: "")
        public static let viewDetails = NSLocalizedString("View details", comment: "")
        public static let errorTryAgain = NSLocalizedString("Something went wrong, please try reopening Buy & Sell Bitcoin again.", comment: "")
        public static let buySellAgreement = NSLocalizedString(
            "By tapping Begin Now, you agree to Coinify's Terms of Service & Privacy Policy",
            comment: "Disclaimer shown when starting KYC from Buy-Sell"
        )
        
        public struct DeprecationError {
            public static let message = NSLocalizedString("This feature is currently unavailable on iOS. Please visit our web wallet at Blockchain.com to proceed.", comment: "")
        }
    }

    public struct AddressAndKeyImport {

        public static let nonSpendable = NSLocalizedString("Non-Spendable", comment: "Text displayed to indicate that part of the funds in the user’s wallet is not spendable.")

        public static let copyWalletId = NSLocalizedString("Copy Wallet ID", comment: "")

        public static let copyCTA = NSLocalizedString("Copy to clipboard", comment: "")
        public static let copyWarning = NSLocalizedString(
        """
        Warning: Your wallet identifier is sensitive information. Copying it may compromise the security of your wallet.
        """, comment: "")

        public static let importedWatchOnlyAddressArgument = NSLocalizedString("Imported watch-only address %@", comment: "")
        public static let importedPrivateKeyArgument = NSLocalizedString("Imported Private Key %@", comment: "")
        public static let loadingImportKey = NSLocalizedString("Importing key", comment: "")
        public static let loadingProcessingKey = NSLocalizedString("Processing key", comment: "")
        public static let importedKeyButForIncorrectAddress = NSLocalizedString("You’ve successfully imported a private key.", comment: "")
        public static let importedKeyDoesNotCorrespondToAddress = NSLocalizedString("NOTE: The scanned private key does not correspond to this watch-only address. If you want to spend from this address, make sure that you scan the correct private key.", comment: "")
        public static let importedKeySuccess = NSLocalizedString("You can now spend from this address.", comment: "")
        public static let incorrectPrivateKey = NSLocalizedString("Incorrect private key", comment: "Incorrect private key")
        public static let keyAlreadyImported = NSLocalizedString("Key already imported", comment: "")
        public static let keyNeedsBip38Password = NSLocalizedString("Needs BIP38 Password", comment: "")
        public static let incorrectBip38Password = NSLocalizedString("Wrong BIP38 Password", comment: "")
        public static let unknownErrorPrivateKey = NSLocalizedString("There was an error importing this private key.", comment: "")
        public static let addressNotPresentInWallet = NSLocalizedString("Your wallet does not contain this address.", comment: "")
        public static let addressNotWatchOnly = NSLocalizedString("This address is not watch-only.", comment: "")
        public static let keyBelongsToOtherAddressNotWatchOnly = NSLocalizedString("This private key belongs to another address that is not watch only", comment: "")
        public static let unknownKeyFormat = NSLocalizedString("Unknown key format", comment: "")
        public static let unsupportedPrivateKey = NSLocalizedString("Unsupported Private Key Format", comment: "")
        public static let addWatchOnlyAddressWarning = NSLocalizedString("You are about to import a non-spendable address, an address (or public key script) stored in the wallet without the corresponding private key. This means that the funds can be spent ONLY if you have the private key stored elsewhere. If you do not have the private key stored, do NOT instruct anyone to send you bitcoin to the non-spendable address. These options are recommended for advanced users only. Continue?", comment: "")
        public static let addWatchOnlyAddressWarningPrompt = NSLocalizedString("These options are recommended for advanced users only. Continue?", comment: "")
    }

    public struct SendAsset {
        public static let useTotalSpendableBalance = NSLocalizedString(
            "Use total spendable balance: ",
            comment: "String displayed to the user when they want to send their full balance to an address."
        )
        public static let invalidXAddressY = NSLocalizedString(
            "Invalid %@ address: %@",
            comment: "String presented to the user when they try to scan a QR code with an invalid address."
        )
        public static let send = NSLocalizedString(
            "Send",
            comment: "Text displayed on the button for when a user wishes to send crypto."
        )
        public static let confirmPayment = NSLocalizedString(
            "Confirm Payment",
            comment: "Header displayed asking the user to confirm their payment."
        )
        public static let paymentSent = NSLocalizedString(
            "Payment sent",
            comment: "Alert message shown when crypto is successfully sent to a recipient."
        )
        public static let transferAllFunds = NSLocalizedString(
            "Confirm Transfer",
            comment: "Title shown to use when transferring funds from legacy addresses to their new wallet"
        )
        
        public static let paxComingSoonTitle = NSLocalizedString("USD Digital Coming Soon!", comment: "")
        public static let paxComingSoonMessage = NSLocalizedString("We’re bringing USD Digital to iOS. While you wait, Send, Receive & Exchange USD Digital on the web.", comment: "")
        public static let paxComingSoonLinkText = NSLocalizedString("What is USD Digital?", comment: "")
        public static let notEnoughEth = NSLocalizedString("Not Enough ETH", comment: "")
        public static let notEnoughEthDescription = NSLocalizedString("You'll need ETH to send your ERC20 Token", comment: "")
        public static let invalidDestinationAddress = NSLocalizedString("Invalid ETH Address", comment: "")
        public static let invalidDestinationDescription = NSLocalizedString("You must enter a valid ETH address to send your ERC20 Token", comment: "")
        public static let notEnough = NSLocalizedString("Not Enough", comment: "")
        public static let myPaxWallet = NSLocalizedString("My USD Digital Wallet", comment: "")
    }

    public struct SendEther {
        public static let waitingForPaymentToFinishTitle = NSLocalizedString("Waiting for payment", comment: "")
        public static let waitingForPaymentToFinishMessage = NSLocalizedString("Please wait until your previous transaction confirms", comment: "")
    }

    public struct WalletPicker {
        public static let title = selectAWallet
        public static let selectAWallet = NSLocalizedString("Select a Wallet", comment: "Select a Wallet")
    }
    
    public struct ErrorAlert {
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
    
    public struct PaymentReceivedAlert {
        public static let titleSuffix = NSLocalizedString(
            "Received",
            comment: "alert title suffix announcing a payment was received")
    }

    public struct Address {
        public struct Accessibility {
            public static let addressLabel = NSLocalizedString(
                "This is your address",
                comment: "Accessibility hint for the user's wallet address")
            public static let addressImageView = NSLocalizedString(
                "This is your address QR code",
                comment: "Accessibility hint for the user's wallet address qr code image")
            public static let copyButton = NSLocalizedString(
                "Copy",
                comment: "Accessibility hint for the user's wallet address copy button")
            public static let shareButton = NSLocalizedString(
                "Share",
                comment: "Accessibility hint for the user's wallet address copy button")
        }
        public static let copyButton = NSLocalizedString(
            "Copy",
            comment: "copy address button title before copy was made")
        public static let copiedButton = NSLocalizedString(
            "Copied!",
            comment: "copy address button title after copy was made")
        public static let shareButton = NSLocalizedString(
            "Share",
            comment: "share address button title")
        public static let titleFormat = NSLocalizedString(
            "%@ Wallet Address",
            comment: "format for wallet address title on address screen")
        public static let creatingStatusLabel = NSLocalizedString(
            "Creating a new address",
            comment: "Creating a new address status label")
        public static let loginToRefreshAddress = NSLocalizedString(
            "Log in to refresh addresses",
            comment: "Message that let the user know he has to login to refresh his wallet addresses")
    }

    public struct Transactions {
        public static let paxfee = NSLocalizedString("USD-D Fee", comment: "String displayed to indicate that a transaction is due to a fee associated to sending USD-D.")
        public static let allWallets = NSLocalizedString("All Wallets", comment: "Label of selectable item that allows user to show all transactions of a certain asset")
        public static let noTransactions = NSLocalizedString("No Transactions", comment: "Text displayed when no recent transactions are being shown")
        public static let noTransactionsAssetArgument = NSLocalizedString("Transactions occur when you send and receive %@.", comment: "Helper text displayed when no recent transactions are being shown")
        public static let requestArgument = NSLocalizedString("Request %@", comment: "Text shown when a user can request a certain asset")
        public static let getArgument = NSLocalizedString("Get %@", comment: "Text shown when a user can purchase a certain asset")
        public static let justNow = NSLocalizedString("Just now", comment: "text shown when a transaction has just completed")
        public static let secondsAgo = NSLocalizedString("%lld seconds ago", comment: "text shown when a transaction has completed seconds ago")
        public static let oneMinuteAgo = NSLocalizedString("1 minute ago", comment: "text shown when a transaction has completed one minute ago")
        public static let minutesAgo = NSLocalizedString("%lld minutes ago", comment: "text shown when a transaction has completed minutes ago")
        public static let oneHourAgo = NSLocalizedString("1 hour ago", comment: "text shown when a transaction has completed one hour ago")
        public static let hoursAgo = NSLocalizedString("%lld hours ago", comment: "text shown when a transaction has completed hours ago")
        public static let yesterday = NSLocalizedString("Yesterday", comment: "text shown when a transaction has completed yesterday")
    }

    public struct Lockbox {
        public static let getYourLockbox = NSLocalizedString(
            "Get Your Lockbox",
            comment: "Title prompting the user to buy a lockbox."
        )
        public static let safelyStoreYourLockbox = NSLocalizedString(
            "Safely store your crypto currency offline.",
            comment: "Subtitle prompting the user to buy a lockbox."
        )
        public static let buyNow = NSLocalizedString(
            "Buy Now",
            comment: "Buy now CTA for a lockbox device."
        )
        public static let alreadyOwnOne = NSLocalizedString(
            "Already own one?",
            comment: "Title for anouncement card for the lockbox."
        )
        public static let announcementCardSubtitle = NSLocalizedString(
            "From your computer log into blockchain.com and connect your Lockbox.",
            comment: "Subtitle for anouncement card for the lockbox."
        )
        public static let balancesComingSoon = NSLocalizedString(
            "Balances Coming Soon",
            comment: "Title displayed to the user when they have a synced lockbox."
        )
        public static let balancesComingSoonSubtitle = NSLocalizedString(
            "We are unable to display your Lockbox balance at this time. Don’t worry, your funds are safe. We’ll be adding this feature soon. While you wait, you can check your balance on the web.",
            comment: "Subtitle display to the user when they have a synced lockbox."
        )
        public static let checkMyBalance = NSLocalizedString(
            "Check My Balance",
            comment: "CTA for when the user has a synced lockbox."
        )
        public static let wantToLearnMoreX = NSLocalizedString(
            "Want to learn more? Tap here to visit %@",
            comment: "Footer text in the lockbox view."
        )
    }

    public struct Stellar {
        public static let required = NSLocalizedString("Required", comment: "Required")
        public static let memoPlaceholder = NSLocalizedString("Used to identify transactions", comment: "Used to identify transactions")
        public static let sendingToExchange = NSLocalizedString("Sending to an Exchange?", comment: "Sending to an Exchange?")
        public static let addAMemo = NSLocalizedString("Add a Memo to avoid losing funds or use Swap to exchange in this wallet.", comment: "Add a Memo to avoid losing funds or use Swap to exchange in this wallet.")
        public static let memoTitle = NSLocalizedString("Memo", comment: "Memo title")
        public static let memoDescription = NSLocalizedString(
            "Memos are used to communicate optional information to the recipient.",
            comment: "Description of what a memo is and the two types of memos you can send."
        )
        public static let memoText = NSLocalizedString("Memo Text", comment: "memo text")
        public static let memoID = NSLocalizedString("Memo ID", comment: "memo ID")
        public static let minimumBalance = NSLocalizedString(
            "Minimum Balance",
            comment: "Title of page explaining XLM's minimum balance"
        )
        public static let minimumBalanceInfoExplanation = NSLocalizedString(
            "Stellar requires that all Stellar accounts hold a minimum balance of lumens, or XLM. This means you cannot send a balance out of your Stellar Wallet that would leave your Stellar Wallet with less than the minimum balance. This also means that in order to send XLM to a new Stellar account, you must send enough XLM to meet the minimum balance requirement.",
            comment: "General explanation for minimum balance for XLM."
        )
        public static let minimumBalanceInfoCurrentArgument = NSLocalizedString(
            "The current minimum balance requirement is %@.",
            comment: "Explanation for the current minimum balance for XLM."
        )
        public static let totalFundsLabel = NSLocalizedString(
            "Total Funds",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let xlmReserveRequirement = NSLocalizedString(
            "XLM Reserve Requirement",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let transactionFee = NSLocalizedString(
            "Transaction Fee",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let availableToSend = NSLocalizedString(
            "Available to Send",
            comment: "Example used to explain the minimum balance requirement for XLM."
        )
        public static let minimumBalanceMoreInformation = NSLocalizedString(
            "You can read more information about Stellar's minimum balance requirement at Stellar.org",
            comment: "Helper text for user to learn more about the minimum balance requirement for XLM."
        )
        public static let readMore = NSLocalizedString(
            "Read More",
            comment: "Button title for user to learn more about the minimum balance requirement for XLM."
        )
        public static let viewOnArgument = NSLocalizedString(
            "View on %@",
            comment: "Button title for viewing a transaction on the explorer")
        public static let cannotSendXLMAtThisTime = NSLocalizedString(
            "Cannot send XLM at this time. Please try again.",
            comment: "Error displayed when XLM cannot be sent due to an error."
        )
        public static let notEnoughXLM = NSLocalizedString(
            "Not enough XLM.",
            comment: "Error message displayed if the user tries to send XLM but does not have enough of it."
        )
        public static let invalidDestinationAddress = NSLocalizedString(
            "Invalid destination address",
            comment: "Error message displayed if the user tries to send XLM to an invalid address"
        )
        public static let useSpendableBalanceX = NSLocalizedString(
            "Use total spendable balance: ",
            comment: "Tappable text displayed in the send XLM screen for when the user wishes to send their full spendable balance."
        )
        public static let minimumForNewAccountsError = NSLocalizedString(
            "Minimum of 1.0 XLM needed for new accounts",
            comment: "This is the error shown when too little XLM is sent to a primary key that does not yet have an XLM account"
        )
        public static let kycAirdropDescription = NSLocalizedString(
            "Complete your profile to start instantly trading crypto from the security of your wallet.",
            comment: "Description displayed on the onboarding card prompting the user to complete KYC to receive their airdrop."
        )
        public static let weNowSupportStellar = NSLocalizedString(
            "We Now Support Stellar",
            comment: "Title displayed in the onboarding card showing that we support Stellar."
        )
        public static let weNowSupportStellarDescription = NSLocalizedString(
            "XLM is a token that enables quick, low cost global transactions. Send, receive, and trade XLM in the wallet today.",
            comment: "Description displayed in the onboarding card showing that we support Stellar."
        )
        public static let getStellarNow = NSLocalizedString(
            "Get Stellar Now",
            comment: "CTA prompting the user to join the XLM waitlist."
        )
        public static let ohNo = NSLocalizedString(
            "Oh no!",
            comment: "Error title shown when deep linking from a claim your XLM link."
        )
    }
    
    public struct TodayExtension {
        public struct Headers {
            public static let prices = NSLocalizedString("Prices", comment: "Prices")
            public static let balance = NSLocalizedString("Wallet Balance", comment: "Wallet Balance")
        }
    }
    
    public struct WalletAction {
        public struct Default {
            public struct Deposit {
                public static let title = NSLocalizedString("Deposit", comment: "Deposit")
                public struct Crypto {
                    public static let description = NSLocalizedString("Add %@ to your Interest Account", comment: "Add %@ to your Interest Account")
                }
                public struct Fiat {
                    public static let description = NSLocalizedString("Add Cash from Your Bank", comment: "Add Cash from Your Bank")
                }
            }
            public struct Withdraw {
                public static let title = NSLocalizedString("Withdraw", comment: "Withdraw")
                public static let description = NSLocalizedString("Cashout to Your Bank", comment: "Cashout to Your Bank")
            }
            public struct Transfer {
                public static let title = NSLocalizedString("Send", comment: "Send")
                public static let description = NSLocalizedString("Transfer Between Your %@ Wallets", comment: "Transfer Between Your %@ Wallets")
            }
            public struct Interest {
                public static let title = NSLocalizedString("Interest Summary", comment: "Interest Summary")
                public static let description = NSLocalizedString("View your accrued %@ Interest", comment: "View your accrued %@ Interest")
            }
            public struct Activity {
                public static let title = NSLocalizedString("Activity", comment: "Activity")
                public static let description = NSLocalizedString("View All Transactions", comment: "View All Transactions")
            }
            public struct Send {
                public static let title = NSLocalizedString("Send", comment: "Send")
                public static let description = NSLocalizedString("Transfer %@ to Any Wallet", comment: "Transfer %@ to Any Wallet")
            }
            public struct Receive {
                public static let title = NSLocalizedString("Receive", comment: "Receive")
                public static let description = NSLocalizedString("Accept or Share Your %@ Address", comment: "Accept or Share Your %@ Address")
            }
            public struct Swap {
                public static let title = NSLocalizedString("Swap", comment: "Swap")
                public static let description = NSLocalizedString("Exchange %@ for Another Crypto", comment: "Exchange %@ for Another Crypto")
            }
            public struct Buy {
                public static let title = NSLocalizedString("Buy", comment: "Buy")
                public static let description = NSLocalizedString("Use your Card or Cash", comment: "Use your Card or Cash")
            }
            public struct Sell {
                public static let title = NSLocalizedString("Sell", comment: "Sell")
                public static let description = NSLocalizedString("Convert Your Crypto to Cash", comment: "Convert Your Crypto to Cash")
            }
        }
    }

    public struct GeneralError {
        public static let loadingData = NSLocalizedString(
            "An error occurred while loading the data. Please try again.",
            comment: "A general data loading error display in an alert controller"
        )
    }
    
    public struct Airdrop {
        
        public struct CenterScreen {
            public static let title = NSLocalizedString(
                "Airdrops",
                comment: "Airdrop center screen: title"
            )
            public struct Cell {
                public static let fiatMiddle = NSLocalizedString(
                    "of",
                    comment: "Airdrop center screen: cell title"
                )
                public static let availableDescriptionPrefix = NSLocalizedString(
                    "Drops on",
                    comment: "Airdrop center screen: available cell description"
                )
                public static let endedDescriptionPrefix = NSLocalizedString(
                    "Ended on",
                    comment: "Airdrop center screen: ended cell description"
                )
            }
            
            public struct Header {
                public static let startedTitle = NSLocalizedString(
                    "Available",
                    comment: "Airdrop center screen: available header title"
                )
                public static let endedTitle = NSLocalizedString(
                    "Ended",
                    comment: "Airdrop center screen: ended header title"
                )
            }
        }
        
        public struct StatusScreen {
            public static let title = NSLocalizedString(
                "Airdrop",
                comment: "Airdrop status screen: title"
            )
            public struct Blockstack {
                public static let title = NSLocalizedString(
                    "Blockstack (STX)",
                    comment: "Airdrop status screen: blockstack, title"
                )
                public static let description = NSLocalizedString(
                    "Own your digital identity and data with hundreds of decentralized apps built with Blockstack.",
                    comment: "Airdrop status screen: blockstack, description"
                )
            }
            public struct Stellar {
                public static let title = NSLocalizedString(
                    "Stellar (XLM)",
                    comment: "Airdrop status screen: stellar, title"
                )
                public static let description = NSLocalizedString(
                    "Stellar is an open-source, decentralized payment protocol that allows for fast and cheap cross-border transactions between any pair of currencies.",
                    comment: "Airdrop status screen: stellar, description"
                )
            }
            public struct Cell {
                public struct Status {
                    public static let label = NSLocalizedString(
                        "Status",
                        comment: "Airdrop status screen: blockstack, status"
                    )
                    public static let received = NSLocalizedString(
                        "Received",
                        comment: "Airdrop status screen: received status"
                    )
                    public static let expired = NSLocalizedString(
                        "Offer Expired",
                        comment: "Airdrop status screen: received status"
                    )
                    public static let failed = NSLocalizedString(
                        "Ineligible",
                        comment: "Airdrop status screen: received status"
                    )
                    public static let claimed = NSLocalizedString(
                        "Claimed",
                        comment: "Airdrop status screen: claimed status"
                    )
                    public static let enrolled = NSLocalizedString(
                        "Enrolled",
                        comment: "Airdrop status screen: enrolled status"
                    )
                    public static let notRegistered = NSLocalizedString(
                        "Not Registered",
                        comment: "Airdrop status screen: not registered status"
                    )
                }
                public struct Amount {
                    public static let label = NSLocalizedString(
                        "Amount",
                        comment: "Airdrop status screen: amount label"
                    )
                    public static let valuePlaceholder = NSLocalizedString(
                        "xxx",
                        comment: "Airdrop status screen: amount value placeholder label"
                    )
                    public static let value = NSLocalizedString(
                        " %@ (%@ %@)",
                        comment: "Airdrop status screen: amount value format"
                    )
                }
                public static let date = NSLocalizedString(
                    "Date",
                    comment: "Airdrop status screen: date"
                )

                public static let airdropName = NSLocalizedString(
                    "Airdrop",
                    comment: "Airdrop status screen: airdrop name"
                )
                public static let currency = NSLocalizedString(
                    "Currency",
                    comment: "Airdrop status screen: currency"
                )
            }
        }
        
        public struct IntroScreen {
            public static let title = NSLocalizedString(
                "Get Free Crypto.",
                comment: "Airdrop intro screen: title"
            )
            public static let subtitle = NSLocalizedString(
                "With Blockchain Airdrops, get free crypto sent right to your Blockchain Wallet.",
                comment: "Airdrop intro screen: subtitle"
            )
            public static let disclaimerPrefix = NSLocalizedString(
                "Due to local laws, USA, Canada and Japan nationals cannot particpate in the Blockstack Airdrop.",
                comment: "Airdrop intro screen: description"
            )
            public static let disclaimerLearnMoreLink = NSLocalizedString(
                "Learn more",
                comment: "Airdrop intro screen: learn more link"
            )
            public static let ctaButton = NSLocalizedString(
                "Upgrade to Gold. Get $10",
                comment: "Airdrop intro screen: CTA button"
            )
            public struct InfoCell {
                public struct Number {
                    public static let title = NSLocalizedString(
                        "Current Airdrop",
                        comment: "Airdrop intro screen number of airdrop cell: title"
                    )
                    public static let value = NSLocalizedString(
                        "02 - Blockstack",
                        comment: "Airdrop intro screen number of airdrop cell: value"
                    )
                }
                public struct Currency {
                    public static let title = NSLocalizedString(
                        "Currency",
                        comment: "Airdrop intro screen currency of airdrop cell: title"
                    )
                    public static let value = NSLocalizedString(
                        "Stacks",
                        comment: "Airdrop intro screen currency of airdrop cell: value"
                    )
                }
            }
        }
        
        public static let invalidCampaignUser = NSLocalizedString(
            "We're sorry, the airdrop program is currently not available where you are.",
            comment: "Error message displayed when the user that is trying to register for the campaign cannot register."
        )
        public static let alreadyRegistered = NSLocalizedString(
            "Looks like you've already received your airdrop!",
            comment: "Error message displayed when the user has already claimed their airdrop."
        )
        public static let xlmCampaignOver = NSLocalizedString(
            "We're sorry, the XLM airdrop is over. Complete your profile to be eligible for future airdrops and access trading.",
            comment: "Error message displayed when the XLM airdrop is over."
        )
        public static let genericError = NSLocalizedString(
            "Oops! We had trouble processing your airdrop. Please try again.",
            comment: "Generic airdrop error."
        )
    }
    
    public struct AuthType {
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
}

extension LocalizationConstants {
    public struct Accessibility {}
}
