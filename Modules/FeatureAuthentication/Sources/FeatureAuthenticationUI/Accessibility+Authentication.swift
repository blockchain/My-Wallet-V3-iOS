// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

final class AccessibilityIdentifiers: NSObject {

    // MARK: - Email Login

    enum WelcomeScreen {
        static let prefix = "WelcomeScreen."

        static let blockchainImage = "\(prefix)blockchainImage"
        static let welcomeTitleText = "\(prefix)titleText"
        static let welcomeSubtitleText = "\(prefix)subtitleText"
        static let welcomeMessageText = "\(prefix)messageText"
        static let createWalletButton = "\(prefix)createWalletButton"
        static let emailLoginButton = "\(prefix)emailLoginButton"
        static let restoreWalletButton = "\(prefix)restoreWalletButton"
        static let manualPairingButton = "\(prefix)manualPairingButton"
        static let buildVersionText = "\(prefix)buildVersionText"
    }

    enum SecondPasswordScreen {
        static let prefix = "SecondPasswordScreen."

        static let lockedIconImage = "\(prefix)lockedIconImage"
        static let titleText = "\(prefix)titleText"
        static let descriptionText = "\(prefix)descriptionText"
        static let learnMoreText = "\(prefix)learnMoreText"
        static let loginOnWebButton = "\(prefix)loginWithWebButton"
        static let returnButton = "\(prefix)returnButton"
    }

    enum EmailLoginScreen {
        static let prefix = "EmailLoginScreen."

        static let emailGroup = "\(prefix)emailGroup"
        static let nextButton = "\(prefix)nextButton"
        static let continueButton = "\(prefix)continueButton"
        static let loginTitleText = "\(prefix)loginTitleText"
    }

    enum ManualPairingScreen {
        static let prefix = "ManualPairingScreen."

        static let guidGroup = "\(prefix)guidGroup"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let continueButton = "\(prefix)continueButton"
    }

    enum VerifyDeviceScreen {
        static let prefix = "VerifyDeviceScreen."

        static let verifyDeviceImage = "\(prefix)verifyDeviceImage"
        static let verifyDeviceTitleText = "\(prefix)verifyDeviceTitleText"
        static let verifyDeviceDescriptionText = "\(prefix)verifyDeviceDescriptionText"
        static let sendAgainButton = "\(prefix)sendAgainButton"
        static let openMailAppButton = "\(prefix)openMailAppButton"
    }

    enum CredentialsScreen {
        static let prefix = "CredentialsScreen."

        static let emailGuidGroup = "\(prefix)emailGuidGroup"
        static let guidGroup = "\(prefix)guidGroup"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let troubleLoggingInButton = "\(prefix)troubleLoggingInButton"
        static let twoFAGroup = "\(prefix)twoFAGroup"
        static let resendSMSButton = "\(prefix)resendSMSButton"
        static let resetTwoFAButton = "\(prefix)resetTwoFAButton"
        static let nextButton = "\(prefix)questionCircleButton"
    }

    // MARK: - Account Recovery

    enum SeedPhraseScreen {
        static let prefix = "SeedPhraseScreen."

        static let instructionText = "\(prefix)instructionText"
        static let seedPhraseTextEditor = "\(prefix)seedPhraseTextEditor"
        static let invalidPhraseErrorText = "\(prefix)invalidPhraseErrorText"
        static let resetAccountPromptText = "\(prefix)resetAccountPromptText"
        static let resetAccountButton = "\(prefix)resetAccountButton"
        static let contactSupportButton = "\(prefix)contactSupportButton"
        static let continueButton = "\(prefix)continueButton"
        static let nextButton = "\(prefix)nextButton"
    }

    enum ResetAccountWarningScreen {
        static let prefix = "ResetAccountModal."

        static let resetAccountImage = "\(prefix)resetAccountImage"
        static let resetAccountTitleText = "\(prefix)resetAccountTitleText"
        static let resetAccountMessageText = "\(prefix)resetAccountMessageText"
        static let continueToResetButton = "\(prefix)continueToResetButton"
        static let retryRecoveryPhraseButton = "\(prefix)retryRecoveryPhraseButton"
    }

    enum LostFundsWarningScreen {
        static let prefix = "LostFundsWarningScreen."

        static let lostFundsWarningImage = "\(prefix)lostFundsWarningImage"
        static let lostFundsWarningTitleText = "\(prefix)lostFundsWarningTitleText"
        static let lostFundsWarningMessageText = "\(prefix)lostFundsWarningMessageText"
        static let resetAccountButton = "\(prefix)resetAccountButton"
        static let goBackButton = "\(prefix)goBackButton"
    }

    enum ResetAccountFailureScreen {
        static let prefix = "ResetAccountFailureScreen."

        static let resetAccountFailureImage = "\(prefix)resetAccountFailureImage"
        static let resetAccountFailureTitleText = "\(prefix)resetAccountFailureTitleText"
        static let resetAccountFailureMessageText = "\(prefix)resetAccountFailureMessageText"
        static let resetAccountFailureCallOutGroup = "\(prefix)resetAccountFailureCallOutGroup"
        static let contactSupportButton = "\(prefix)contactSupportButton"
    }

    enum ResetPasswordScreen {
        static let prefix = "ResetPasswordScreen."

        static let newPasswordGroup = "\(prefix)newPasswordGroup"
        static let passwordInstructionText = "\(prefix)passwordInstructionText"
        static let passwordStrengthIndicatorGroup = "\(prefix)passwordStrengthIndicatorGroup"
        static let confirmNewPasswordGroup = "\(prefix)confirmNewPasswordGroup"
        static let securityCallOutGroup = "\(prefix)securityCallOutGroup"
        static let resetPasswordButton = "\(prefix)resetPasswordButton"
    }

    enum ImportWalletScreen {
        static let prefix = "ImportWalletScreen."

        static let importWalletImage = "\(prefix)importWalletImage"
        static let importWalletTitleText = "\(prefix)importWalletTitleText"
        static let importWalletMessageText = "\(prefix)importWalletMessageText"
        static let importWalletButton = "\(prefix)importWalletButton"
        static let goBackButton = "\(prefix)goBackButton"
    }

    enum CreateAccountScreen {
        static let prefix = "CreateAccountScreen."

        static let emailGroup = "\(prefix)emailGroup"
        static let referralGroup = "\(prefix)referralGroup"
        static let agreementPromptText = "\(prefix)agreementPromptText"
        static let bakktAgreementPromptText = "\(prefix)bakktAgreementPromptText"
        static let termsOfServiceButton = "\(prefix)termsOfServiceButton"
        static let bakktTermsOfServiceButton = "\(prefix)bakktTermsOfServiceButton"
        static let privacyPolicyButton = "\(prefix)privacyPolicyButton"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let passwordInstructionText = "\(prefix)passwordInstructionText"
        static let passwordStrengthIndicatorGroup = "\(prefix)passwordStrengthIndicatorGroup"
        static let confirmPasswordGroup = "\(prefix)confirmPasswordGroup"
        static let createAccountButton = "\(prefix)createAccountButton"
        static let nextButton = "\(prefix)nextButton"
    }

    enum TradingAccountWarningScreen {
        static let prefix = "TradingAccountWarningScreen."

        static let image = "\(prefix)image"
        static let title = "\(prefix)title"
        static let message = "\(prefix)message"
        static let walletIdMessagePrefix = "\(prefix)walletIdMessagePrefix"
        static let logoutButton = "\(prefix)logoutButton"
        static let cancel = "\(prefix)cancelButton"
    }

    // MARK: - Upgrade Account (Unified sign in)

    enum SkipUpgradeScreen {
        static let prefix = "SkipUpgradeScreen."

        static let skipUpgradeImage = "\(prefix)skipUpgradeImage"
        static let skipUpgradeTitleText = "\(prefix)skipUpgradeTitleText"
        static let skipUpgradeMessageText = "\(prefix)skipUpgradeMessageText"
        static let skipUpgradeButton = "\(prefix)skipUpgradeButton"
        static let upgradeAccountButton = "\(prefix)upgradeAccountButton"
    }

    enum UpgradeAccountScreen {
        static let prefix = "UpgradeAccountScreen."

        static let heading = "\(prefix)heading"
        static let subheading = "\(prefix)subheading"
        static let messageList = "\(prefix)messageList"
        static let upgradeButton = "\(prefix)upgradeButton"
        static let skipButton = "\(prefix)skipButton"
    }

    // MARK: - Authorization Result

    enum AuthorizationResultScreen {
        static let prefix = "AuthorizationResultScreen."

        static let image = "\(prefix)image"
        static let title = "\(prefix)title"
        static let message = "\(prefix)message"
        static let button = "\(prefix)button"
    }

    // MARK: - Password Required Screen

    enum PasswordRequiredScreen {
        static let prefix = "PasswordRequiredScreen."

        static let header = "\(prefix)header"
        static let walletIdGroup = "\(prefix)walletIdGroup"
        static let description = "\(prefix)description"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let forgotWalletDesription = "\(prefix)forgotWalletDescription"
        static let forgotWalletButton = "\(prefix)forgotWalletButton"
    }
}
