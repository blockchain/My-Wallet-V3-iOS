// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum FeatureAuthentication {}
}

extension LocalizationConstants.FeatureAuthentication {

    // MARK: - Email Login

    public enum EmailLogin {
        public static let navigationTitle = NSLocalizedString(
            "Log In",
            comment: "Login screen: login form title"
        )
        public static let manualPairingTitle = NSLocalizedString(
            "Manual Pairing Login",
            comment: "Manual Pairing screen: title"
        )
        public enum VerifyDevice {
            public static let title = NSLocalizedString(
                "Verify Device",
                comment: "Verify device screen: Verify device screen title"
            )
            public static let description = NSLocalizedString(
                "If you have an account registered with this email address, you will receive an email with a link to verify your device.",
                comment: "Verify device screen: Verify device screen description"
            )
            public enum Button {}
        }

        public enum TextFieldTitle {
            public static let walletIdentifier = NSLocalizedString(
                "Wallet Identifier",
                comment: "Login screen: wallet identifier field title"
            )
            public static let email = NSLocalizedString(
                "Email",
                comment: "Login screen: email text field title"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Login screen: password field title"
            )
            public static let smsCode = NSLocalizedString(
                "SMS Code",
                comment: "Login screen: sms authentication text field title"
            )
            public static let authenticatorCode = NSLocalizedString(
                "Authenticator Code",
                comment: "Login screen: authenticator text field title"
            )
            public static let hardwareKeyCode = NSLocalizedString(
                "Verify with your hardware key",
                comment: "Login screen: verify with hardware key title prefix"
            )
        }

        public enum TextFieldPlaceholder {
            public static let email = NSLocalizedString(
                "your@email.com",
                comment: "Login screen: placeholder for email text field"
            )
        }

        public enum TextFieldFootnote {
            public static let email = NSLocalizedString(
                "Email: ",
                comment: "Login screen: prefix for email on footnote"
            )
            public static let wallet = NSLocalizedString(
                "Wallet: ",
                comment: "Login screen: prefix for wallet identifier footnote"
            )
            public static let hardwareKeyInstruction = NSLocalizedString(
                "Tap hardware key to verify",
                comment: "Login screen: hardware key usage instruction"
            )
            public static let lostTwoFACodePrompt = NSLocalizedString(
                "Lost access to your 2FA device?",
                comment: "Login screen: a prompt for user to reset their 2FA if they lost their 2FA device"
            )
        }

        public enum TextFieldError {
            public static let invalidEmail = NSLocalizedString(
                "Invalid Email",
                comment: "Login screen: invalid email error"
            )
            public static let incorrectWalletIdentifier = NSLocalizedString(
                "Incorrect Wallet Identifier",
                comment: "Manual Login screen: incorrect wallet identifier"
            )
            public static let incorrectPassword = NSLocalizedString(
                "Incorrect Password",
                comment: "Login screen: wrong password error"
            )
            public static let missingTwoFACode = NSLocalizedString(
                "Missing 2FA code",
                comment: "Login screen: missing 2FA code error"
            )
            public static let incorrectTwoFACode = NSLocalizedString(
                "Incorrect 2FA code. %d attempts left",
                comment: "Login screen: wrong 2FA code error"
            )
            public static let accountLocked = NSLocalizedString(
                "This account has been locked due to too many failed authentications",
                comment: "Login screen: a message saying that the account is locked"
            )
        }

        public enum Link {
            public static let forgotPasswordLink = NSLocalizedString(
                "Forgot your password?",
                comment: "Login screen: link for forgot password"
            )

            public static let resetTwoFALink = NSLocalizedString(
                "Reset your 2FA",
                comment: "Login screen: link for resetting 2FA"
            )
        }

        public enum Divider {
            public static let or = NSLocalizedString(
                "or",
                comment: "Login screen: Divider OR label"
            )
        }

        public enum Button {
            public static let scanPairingCode = NSLocalizedString(
                "Scan Pairing Code",
                comment: "Login screen: scan pairing code CTA button"
            )
            public static let openEmail = NSLocalizedString(
                "Open Email App",
                comment: "Verify device screen: Open email app CTA button"
            )
            public static let sendAgain = NSLocalizedString(
                "Send Again",
                comment: "Verify device screen: Send email again CTA button"
            )
            public static let apple = NSLocalizedString(
                "Continue with Apple",
                comment: "Login screen: sign in with Apple CTA button"
            )
            public static let google = NSLocalizedString(
                "Continue with Google",
                comment: "Login screen: sign in with Google CTA button"
            )
            public static let next = NSLocalizedString(
                "Next",
                comment: "Login screen: next button"
            )
            public static let _continue = NSLocalizedString(
                "Continue",
                comment: "Login screen: continue CTA button"
            )
            public static let resendSMS = NSLocalizedString(
                "Resend SMS",
                comment: "Login screen: resend SMS for 2FA CTA button"
            )
        }

        public enum Alerts {
            public enum SignInError {
                public static let title = NSLocalizedString(
                    "Error Signing In",
                    comment: "Error alert title"
                )
                public static let message = NSLocalizedString(
                    "For security reasons you cannot proceed with signing in.\nPlease try to log in on web.",
                    comment: "Error alert message"
                )
                public static let continueTitle = NSLocalizedString(
                    "Continue",
                    comment: ""
                )
            }

            public enum EmailAuthorizationAlert {
                public static let title = NSLocalizedString(
                    "Authorization Required",
                    comment: "Title for email authorization alert"
                )
                public static let message = NSLocalizedString(
                    "Please check your email to approve this login attempt.",
                    comment: "Message for email authorization alert"
                )
            }

            public enum SMSCode {
                public enum Failure {
                    public static let title = NSLocalizedString(
                        "Error Sending SMS",
                        comment: "Error alert title when sms failed"
                    )

                    public static let message = NSLocalizedString(
                        "There was an error sending you the SMS message.\nPlease try again.",
                        comment: "Error alert message when sms failed"
                    )
                }

                public enum Success {
                    public static let title = NSLocalizedString(
                        "Message sent",
                        comment: "Success alert title when sms sent"
                    )

                    public static let message = NSLocalizedString(
                        "We have sent you a verification code message.",
                        comment: "Success alert message when sms sent"
                    )
                }
            }

            public enum GenericNetworkError {
                public static let title = NSLocalizedString(
                    "Network Error",
                    comment: ""
                )
                public static let message = NSLocalizedString(
                    "We cannot establish a connection with our server.\nPlease try to sign in again.",
                    comment: ""
                )
            }
        }
    }

    // MARK: - Authorize Device

    public enum AuthorizeDevice {
        public static let title = NSLocalizedString(
            "Log In Request",
            comment: "Verify Device - New device log in request title"
        )
        public static let subtitle = NSLocalizedString(
            "We noticed a login attempt from a new device.",
            comment: "Verify Device - New device log in request subtitle"
        )
        public enum Details {
            public static let location = NSLocalizedString(
                "Location",
                comment: "Verify Device - Location details"
            )
            public static let ip = NSLocalizedString(
                "IP Address",
                comment: "Verify Device - IP details"
            )
            public static let browser = NSLocalizedString(
                "Browser",
                comment: "Verify Device - Browser details"
            )
            public static let date = NSLocalizedString(
                "Date",
                comment: "Verify Device - Date details"
            )
        }

        public static let description = NSLocalizedString(
            "If this was you, approve the device below. If you do not recognize this device, please deny this request.",
            comment: "Verify Device - Description details"
        )
        public enum Buttons {
            public static let approve = NSLocalizedString(
                "Approve",
                comment: "Verify Device - approve"
            )
            public static let deny = NSLocalizedString(
                "Deny",
                comment: "Verify Device - deny"
            )
        }
    }

    // MARK: - Authorization Result

    public enum AuthorizationResult {
        public enum Success {
            public static let title = NSLocalizedString(
                "Your Device is Verified!",
                comment: "Authorization result: success title"
            )
            public static let message = NSLocalizedString(
                "Return to your browser to continue logging in.",
                comment: "Authorization result: success message"
            )
        }

        public enum LinkExpired {
            public static let title = NSLocalizedString(
                "Verification Link Expired",
                comment: "Authorization result: link expired title"
            )
            public static let message = NSLocalizedString(
                "The device approval link has expired, please try again.",
                comment: "Authorization result: link expired message"
            )
        }

        public enum DeviceRejected {
            public static let title = NSLocalizedString(
                "Log In Rejected",
                comment: "Authorization result: device rejected title"
            )
            public static let message = NSLocalizedString(
                "If this wasn’t you trying to log in and it happens again, contact support.",
                comment: "Authorization result: device rejected message"
            )
        }

        public enum Unknown {
            public static let title = NSLocalizedString(
                "Oops!",
                comment: "Authorization result: unknown error title"
            )
            public static let message = NSLocalizedString(
                "Looks like something went wrong. Please try again.",
                comment: "Authorization result: unknown error message"
            )
        }
    }

    // MARK: - Second Password

    public enum SecondPasswordScreen {
        public static let title = NSLocalizedString(
            "Second Password Detected",
            comment: "Second Password Screen main title"
        )

        public static let description = NSLocalizedString(
            "We're moving away from 2nd passwords.\nTo use the mobile app, login on web to disable 2nd password. After logging on Web, tap on the User icon > Security > Advanced and tap the button named \"Remove Second Password\". You will then be able to login on the mobile app.",
            comment: "Second Password Screen description"
        )

        public static let learnMore = NSLocalizedString(
            "Learn More",
            comment: "Second Password Screen learn more text link"
        )

        public static let loginOnWebButtonTitle = NSLocalizedString(
            "Log In with Browser",
            comment: "Second Password Screen button link"
        )

        public static let returnToLogin = NSLocalizedString(
            "Return to Login",
            comment: "Return to login button"
        )
    }

    // MARK: - Import Wallet

    public enum ImportWallet {
        public static let importWalletTitle = NSLocalizedString(
            "Import Your Wallet?",
            comment: "Import Wallet Screen: title"
        )
        public static let importWalletMessage = NSLocalizedString(
            "There’s no account associated with the seed phrase you entered. You can import and manage your wallet instead.",
            comment: "Import Wallet Screen: message"
        )
        public enum Button {
            public static let importWallet = NSLocalizedString(
                "Import Wallet",
                comment: "Import Wallet screen: import wallet CTA button"
            )
            public static let goBack = NSLocalizedString(
                "Go Back",
                comment: "Import Wallet screen: go back CTA button"
            )
        }
    }

    // MARK: - Create Account

    public enum CreateAccount {
        public enum Step1 {
            public static let headerTitle = NSLocalizedString(
                "Let's get started",
                comment: "Create Account Step 1 screen: header title"
            )
            public static let headerSubtitle = NSLocalizedString(
                "What country do you live in?",
                comment: "Create Account Step 1 screen: header subtitle"
            )
        }

        public static let headerTitle = NSLocalizedString(
            "Create Your Account.",
            comment: "Create Account screen: header title"
        )
        public static let headerSubtitle = NSLocalizedString(
            "Enter your email address and password.",
            comment: "Create Account screen: header subtitle"
        )

        public enum TextFieldTitle {
            public static let email = NSLocalizedString(
                "Email",
                comment: "Create Account screen: email text field"
            )
            public static let password = NSLocalizedString(
                "Create Password",
                comment: "Create Account screen: password text field"
            )
            public static let passwordConfirmation = NSLocalizedString(
                "Confirm Password",
                comment: "Create Account screen: confirm password text field"
            )
            public static let country = NSLocalizedString(
                "Country of Residence",
                comment: "Create Account screen: country text field"
            )
            public static let state = NSLocalizedString(
                "State",
                comment: "Create Account screen: state text field"
            )

            public static let referral = NSLocalizedString(
                "Have a referral code?",
                comment: "Create Account screen: referral text field"
            )
        }

        public enum TextFieldPlaceholder {
            public static let email = NSLocalizedString(
                "your@email.com",
                comment: "Create Account screen: email text field placeholder"
            )
            public static let country = NSLocalizedString(
                "Country of Residence",
                comment: "Create Account screen: Country placeholder"
            )
            public static let state = NSLocalizedString(
                "State of Residence",
                comment: "Create Account screen: State placeholder"
            )
            public static let referralCode = NSLocalizedString(
                "Enter referral code",
                comment: "Create Account screen: referral code text field placeholder"
            )
            public static let password = NSLocalizedString(
                "Minimum of 8 characters",
                comment: "Create Account screen: password placeholder"
            )
            public static let passwordConfirmation = NSLocalizedString(
                "Re-enter your password",
                comment: "Create Account screen: confirm password placeholder"
            )
        }

        public enum PasswordStrengthIndicator {
            public static let regularPassword = NSLocalizedString(
                "Regular",
                comment: "Create Account screen: regular password"
            )
            public static let strongPassword = NSLocalizedString(
                "Strong",
                comment: "Create Account screen: strong password"
            )
            public static let weakPassword = NSLocalizedString(
                "Weak",
                comment: "Create Account screen: weak password"
            )
        }

        public enum TextFieldError {
            public static let invalidEmail = NSLocalizedString(
                "Invalid Email",
                comment: "Create Account screen: invalid email error"
            )
            public static let confirmPasswordNotMatch = NSLocalizedString(
                "Passwords don't match",
                comment: "Create Account screen: passwords do not match error"
            )
            public static let invalidReferralCode = NSLocalizedString(
                "Please enter a valid referral code",
                comment: "Create Account screen: invalid referral code error"
            )
            public static let passwordsDontMatch = NSLocalizedString(
                "Passwords don't match",
                comment: "Create Account screen: passwords don't match error"
            )

            public static let referralCodeApplied = NSLocalizedString(
                "Referral code applied",
                comment: "Create Account screen: referral code applied"
            )
        }

        public static let agreementPrompt = NSLocalizedString(
            "I certify I am 18 years of age or older and I agree to Blockchain.com’s",
            comment: "Create Account screen: I agree to Blockchain.com’s Terms of Service & Privacy Policy."
        )
        public static let recoveryPhrase = NSLocalizedString(
            "Secret Private Key Recovery Phrase",
            comment: "Create Account screen: 'Secret Private Key Recovery Phrase' text, split to add emphasis"
        )
        public static let termsOfServiceLink = NSLocalizedString(
            "Terms of Services",
            comment: "Create Account screen: terms of service link"
        )
        public static let and = NSLocalizedString(
            "and",
            comment: "Create Account screen: and (connective)"
        )
        public static let privacyPolicyLink = NSLocalizedString(
            "Privacy Policy",
            comment: "Create Account screen: privacy policy link"
        )
        public static let createAccountButton = NSLocalizedString(
            "Get Started",
            comment: "Create Account screen: create account CTA button"
        )
        public static let nextButton = NSLocalizedString(
            "Next",
            comment: "Create Account screen: create account CTA button in nav bar"
        )

        public enum FatalError {
            public static let title = NSLocalizedString(
                "Unable to process",
                comment: "Unable to process"
            )
            public static let description = NSLocalizedString(
                "We are unable to create your Wallet.\nPlease, try again later.",
                comment: "We are unable to create your Wallet.\nPlease, try again later."
            )
            public static let action = NSLocalizedString(
                "Go back",
                comment: "Go back"
            )
        }
    }

    // MARK: - Seed Phrase

    public enum SeedPhrase {
        public enum NavigationTitle {
            public static let troubleLoggingIn = NSLocalizedString(
                "Trouble Logging In",
                comment: "Seed phrase screen: trouble logging in navigation title"
            )
            public static let restoreWallet = NSLocalizedString(
                "Restore Wallet",
                comment: "Seed phrase screen: restore wallet navigation title"
            )
        }

        public static let instruction = NSLocalizedString(
            "Enter your twelve word Secret Private Key Recovery Phrase to log in. Separate each word with a space.",
            comment: "Seed phrase screen: main instruction"
        )
        public static let restoreWalletInstruction = NSLocalizedString(
            "Enter your twelve word Secret Private Key Recovery Phrase (Seed Phrase) to restore wallet. Separate each word with a space.",
            comment: "Seed phrase screen: restore wallet main instruction"
        )
        public static let placeholder = NSLocalizedString(
            "Enter recovery phrase",
            comment: "Seed phrase screen: text field placeholder"
        )
        public static let invalidPhrase = NSLocalizedString(
            "Invalid recovery phrase",
            comment: "Seed phrase screen: invalid seed phrase error state"
        )
        public static let resetAccountPrompt = NSLocalizedString(
            "Can’t find your phrase?",
            comment: "Seed phrase screen: prompt for reset account if user lost their seed phrase"
        )
        public static let resetAccountLink = NSLocalizedString(
            "Reset Account",
            comment: "Seed phrase screen: link for reset account"
        )
        public static let contactSupportLink = NSLocalizedString(
            "Contact Support",
            comment: "Seed phrase screen: link for contact support"
        )
        public static let loginInButton = NSLocalizedString(
            "Log In",
            comment: "Seed phrase screen: login CTA button"
        )
        public static let next = NSLocalizedString(
            "Next",
            comment: "Seed phrase screen: next button"
        )
    }

    // MARK: - Reset Account Warning

    public enum ResetAccountWarning {
        public enum Title {
            public static let resetAccount = NSLocalizedString(
                "Reset Your Account?",
                comment: "Reset Account Warning: title"
            )
            public static let lostFund = NSLocalizedString(
                "Resetting Account May Result In\nLost Funds",
                comment: "Lost Fund Warning: title"
            )
            public static let recoveryFailed = NSLocalizedString(
                "Fund Recovery Failed",
                comment: "Fund Recovery Failed: title"
            )
        }

        public enum Message {
            public static let resetAccount = NSLocalizedString(
                "Resetting will restore your Trading, Interest, and Exchange accounts.",
                comment: "Reset account warning: message"
            )
            public static let lostFund = NSLocalizedString(
                "This means that if you lose your recovery phrase, you will lose access to your %@ funds. You can always restore your %@ funds later if you find your recovery phrase.",
                comment: "Lost fund warning: message, placeholder is replaced by DeFi Wallet"
            )
            public static let recoveryFailed = NSLocalizedString(
                "Don’t worry, your account is safe. Please contact support to finish the Account Recovery process. Your account will not show balances or transaction history until you complete the recovery process.",
                comment: "Fund Recovery Failed: message"
            )
        }

        public static let recoveryFailureCallout = NSLocalizedString(
            "Fund recovery failures can happen for a number of reasons. Our support team is able to help recover your account.",
            comment: "Fund Recovery Failed: callout message"
        )

        public enum Button {
            public static let continueReset = NSLocalizedString(
                "Continue to Reset",
                comment: "Continue to reset CTA Button"
            )
            public static let retryRecoveryPhrase = NSLocalizedString(
                "Retry Recovery Phrase",
                comment: "Retry Recovery Phrase CTA Button"
            )
            public static let resetAccount = NSLocalizedString(
                "Reset Account",
                comment: "Reset Account CTA Button"
            )
            public static let goBack = NSLocalizedString(
                "Go Back",
                comment: "Go Back CTA Button"
            )
            public static let learnMore = NSLocalizedString(
                "Learn more",
                comment: "Learn more button"
            )
            public static let contactSupport = NSLocalizedString(
                "Contact Support",
                comment: "Contact Support CTA Button"
            )
        }
    }

    // MARK: - Reset Password

    public enum ResetPassword {
        public static let navigationTitle = NSLocalizedString(
            "Reset Password",
            comment: "Reset password screen: navigation title"
        )
        public enum TextFieldTitle {
            public static let newPassword = NSLocalizedString(
                "New Password",
                comment: "Reset password screen: new password text field"
            )
            public static let confirmNewPassword = NSLocalizedString(
                "Confirm New Password",
                comment: "Reset password screen: confirm new password text field"
            )
        }

        public enum TextFieldPlaceholder {
            public static let newPassword = NSLocalizedString(
                "Enter new password",
                comment: "Reset password screen: new password text field"
            )
            public static let confirmNewPassword = NSLocalizedString(
                "Re-enter new password",
                comment: "Reset password screen: confirm new password text field"
            )
        }

        public static let passwordInstruction = NSLocalizedString(
            "Use at least 8 characters and a mix of letters, numbers, and symbols",
            comment: "Reset password screen: password instruction"
        )
        public static let confirmPasswordNotMatch = NSLocalizedString(
            "Passwords don't match",
            comment: "Reset password screen: passwords do not match error"
        )
        public static let securityCallOut = NSLocalizedString(
            "For your security, you may have to re-verify your identity before accessing your trading or rewards account.",
            comment: "Seed phrase screen: callout message for the security measure"
        )
        public enum Button {
            public static let resetPassword = NSLocalizedString(
                "Reset Password",
                comment: "Reset password screen: reset password button"
            )
            public static let learnMore = NSLocalizedString(
                "Learn more",
                comment: "Reset password screen: learn more: identity verification."
            )
            public static let next = NSLocalizedString(
                "Next",
                comment: "Reset password screen: next button"
            )
        }
    }

    // MARK: - Password Strength Indicator

    public enum PasswordStrength {
        public static let title = NSLocalizedString(
            "Password Strength",
            comment: "Reset password screen: password strength indicator title"
        )
        public static let weak = NSLocalizedString(
            "Weak",
            comment: "Reset password screen: password strength indicator: weak"
        )
        public static let medium = NSLocalizedString(
            "Medium",
            comment: "Reset password screen: password strength indicator: medium"
        )
        public static let strong = NSLocalizedString(
            "Strong",
            comment: "Reset password screen: password strength indicator: strong"
        )
    }

    // MARK: - Blockchain.com Account Warning

    public enum TradingAccountWarning {
        public static let title = NSLocalizedString(
            "Your Blockchain.com Account is Linked to another wallet",
            comment: "Blockchain.com Account Warning: title"
        )

        public static let message = NSLocalizedString(
            "Your Blockchain.com Account is associated with another wallet. Please log into the wallet referenced below for account access.",
            comment: "Blockchain.com Account Warning: message"
        )

        public static let walletIdMessagePrefix = NSLocalizedString(
            "Wallet ID: ",
            comment: "Blockchain.com Account Warning: wallet ID prefix"
        )

        public enum Button {
            public static let logout = NSLocalizedString(
                "Logout",
                comment: "Blockchain.com Account Warning: logout button"
            )

            public static let cancel = NSLocalizedString(
                "Cancel",
                comment: "Blockchain.com Account Warning: cancel button"
            )
        }
    }

    // MARK: - Skip Upgrade Screen

    public enum SkipUpgrade {
        public static let title = NSLocalizedString(
            "Skip Upgrade",
            comment: "Skip Upgrade screen: title"
        )
        public static let message = NSLocalizedString(
            "Looks like you don’t have a Blockchain.com Wallet setup. If you continue to skip, you will be taken back to the log in screen.",
            comment: "Skip Upgrade screen: message"
        )
        public enum Button {
            public static let skipUpgrade = NSLocalizedString(
                "Skip Upgrade",
                comment: "Skip Upgrade CTA button"
            )
            public static let upgradeAccount = NSLocalizedString(
                "Upgrade Account",
                comment: "Upgrade Account CTA button"
            )
        }
    }

    // MARK: - Upgrade Account Screen

    public enum UpgradeAccount {
        public static let navigationTitle = NSLocalizedString(
            "Upgrade Account",
            comment: "Upgrade Account screen: navigation title"
        )
        public static let heading = NSLocalizedString(
            "Upgrade to a Unified\nBlockchain Account",
            comment: "Upgrade Account screen: heading"
        )
        public static let subheading = NSLocalizedString(
            "Would you like to upgrade to a single login for all your Blockchain.com accounts?",
            comment: "Upgrade Account screen: subheading"
        )
        public enum MessageList {
            public static let headingOne = NSLocalizedString(
                "One Login for All Accounts",
                comment: "Upgrade Account screen: heading one"
            )
            public static let bodyOne = NSLocalizedString(
                "Easily access your Blockchain.com Wallet and the Exchange with a single login.",
                comment: "Upgrade Account screen: body one"
            )
            public static let headingTwo = NSLocalizedString(
                "Greater Security Across Accounts",
                comment: "Upgrade Account screen: heading two"
            )
            public static let bodyTwo = NSLocalizedString(
                "Secure your investments across all Blockchain.com products.",
                comment: "Upgrade Account screen: body two"
            )
            public static let headingThree = NSLocalizedString(
                "Free Blockchain.com Wallet",
                comment: "Upgrade Account screen: heading three"
            )
            public static let bodyThree = NSLocalizedString(
                "Create a free Wallet account to do even more with your crypto.",
                comment: "Upgrade Account screen: body three"
            )
        }

        public static let upgradeAccountButton = NSLocalizedString(
            "Upgrade My Account",
            comment: "Upgrade Account CTA button"
        )
        public static let skipButton = NSLocalizedString(
            "I’ll Do This Later",
            comment: "Skip Upgrade CTA button"
        )
    }

    // MARK: - Password Required Screen

    public enum PasswordRequired {
        public static let title = NSLocalizedString(
            "Password Required",
            comment: "Password required screen title"
        )
        public static let emailField = NSLocalizedString(
            "Email",
            comment: "Email field title"
        )
        public static let walletIdentifier = NSLocalizedString(
            "Wallet ID",
            comment: "Wallet ID subtext"
        )
        public static let passwordField = NSLocalizedString(
            "Password",
            comment: "Password field title"
        )
        public static let passwordFieldPlaceholder = NSLocalizedString(
            "Enter your password",
            comment: "Password field placeholder"
        )
        public static let continueButton = NSLocalizedString(
            "Continue",
            comment: "Password required CTA"
        )
        public static let forgotButton = NSLocalizedString(
            "Forgot Password?",
            comment: "Forgot password CTA"
        )
        public static let forgetWalletButton = NSLocalizedString(
            "Forget Wallet",
            comment: "Forget wallet CTA"
        )
        public static let description = NSLocalizedString(
            "Not your account? If you would like to sign into a different account, press ‘Forget Wallet’ below.",
            comment: "Password required description"
        )
        public static let forgetWalletDescription = NSLocalizedString(
            "Forgetting this wallet account will erase all wallet data on this device. Ensure that you have your password and secret private key recovery phrase saved in a safe place before doing so.",
            comment: "Forget Wallet description"
        )
        public enum ForgetWalletAlert {
            public static let title = NSLocalizedString(
                "Warning",
                comment: "forget wallet alert title"
            )
            public static let message = NSLocalizedString(
                "This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere, otherwise any bitcoin in this wallet will be inaccessible!",
                comment: "forget wallet alert body"
            )
            public static let forgetButton = NSLocalizedString(
                "Forget wallet",
                comment: "forget wallet alert button"
            )
        }
    }
}
