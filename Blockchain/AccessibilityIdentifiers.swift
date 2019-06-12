//
//  AccessibilityIdentifiers.swift
//  Blockchain
//
//  Created by Jack on 03/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AccessibilityIdentifiers: NSObject {
    @objc(AccessibilityIdentifiers_WelcomeScreen) class WelcomeScreen: NSObject {
        @objc static let createWalletButton = "WelcomeScreen.createWalletButton"
        @objc static let loginButton = "WelcomeScreen.loginButton"
        @objc static let recoverFundsButton = "WelcomeScreen.recoverFundsButton"
    }
    
    @objc(AccessibilityIdentifiers_CreateWalletScreen) class CreateWalletScreen: NSObject {
        @objc static let emailField = "CreateWalletScreen.emailField"
        @objc static let passwordField = "CreateWalletScreen.passwordField"
        @objc static let confirmPasswordField = "CreateWalletScreen.confirmPasswordField"
        @objc static let privacyPolicyTappableView = "CreateWalletScreen.privacyPolicyTappableView"
        @objc static let termsOfServiceTappableView = "CreateWalletScreen.termsOfServiceTappableView"
        @objc static let createWalletButton = "CreateWalletScreen.createWalletButton"
    }
    
    @objc(AccessibilityIdentifiers_PinScreen) class PinScreen: NSObject {
        @objc static let pinIndicator0 = "PinScreen.pinIndicator0"
        @objc static let pinIndicator1 = "PinScreen.pinIndicator1"
        @objc static let pinIndicator2 = "PinScreen.pinIndicator2"
        @objc static let pinIndicator3 = "PinScreen.pinIndicator3"
        
        @objc static let enterPINLabel = "PinScreen.enterPINLabel"
        @objc static let versionLabel = "PinScreen.versionLabel"
        @objc static let swipeLabel = "PinScreen.swipeLabel"
    }
    
    @objc(AccessibilityIdentifiers_WalletSetupScreen) class WalletSetupScreen: NSObject {
        @objc static let biometricTitleLabel = "WalletSetupScreen.biometricTitleLabel"
        @objc static let biometricBodyTextView = "WalletSetupScreen.biometricBodyTextView"
        @objc static let biometricEnableButton = "WalletSetupScreen.biometricEnableButton"
        @objc static let biometricDoneButton = "WalletSetupScreen.biometricDoneButton"
        
        @objc static let emailTitleLabel = "WalletSetupScreen.emailTitleLabel"
        @objc static let emailEmailLabel = "WalletSetupScreen.emailEmailLabel"
        @objc static let emailBodyTextView = "WalletSetupScreen.emailBodyTextView"
        @objc static let emailOpenMailButton = "WalletSetupScreen.emailOpenMailButton"
        @objc static let emailDoneButton = "WalletSetupScreen.emailDoneButton"
    }
    
    @objc(AccessibilityIdentifiers_WalletSetupReminderScreen) class WalletSetupReminderScreen: NSObject {
        @objc static let titleLabel = "WalletSetupReminderScreen.titleLabel"
        @objc static let emailLabel = "WalletSetupReminderScreen.emailLabel"
        @objc static let detailLabel = "WalletSetupReminderScreen.detailLabel"
        @objc static let continueButton = "WalletSetupReminderScreen.continueButton"
        @objc static let cancelButton = "WalletSetupReminderScreen.cancelButton"
    }

    class KYCVerifyIdentityScreen: NSObject {
        static let headerText = "KYCVerifyIdentityScreen.headerText"
        static let subheaderText = "KYCVerifyIdentityScreen.subheaderText"
        static let passportText = "KYCVerifyIdentityScreen.passportText"
        static let nationalIDCardText = "KYCVerifyIdentityScreen.nationalIDCardText"
        static let residenceCardText = "KYCVerifyIdentityScreen.residenceCardText"
        static let driversLicenseText = "KYCVerifyIdentityScreen.driversLicenseText"
        static let enableCameraHeaderText = "KYCVerifyIdentityScreen.enableCameraHeaderText"
        static let enableCameraSubheaderText = "KYCVerifyIdentityScreen.enableCameraSubheaderText"
        static let countrySupportedHeaderText = "KYCVerifyIdentityScreen.countrySupportedHeaderText"
        static let countrySupportedSubheaderText = "KYCVerifyIdentityScreen.countrySupportedSubheaderText"
    }

    @objc(AccessibilityIdentifiers_TransactionListItem) class TransactionListItem: NSObject {
        @objc static let date = "TransactionListItem.date"
        @objc static let amount = "TransactionListItem.amount"
        @objc static let info = "TransactionListItem.info"
        @objc static let action = "TransactionListItem.action"
        @objc static let warning = "TransactionListItem.warning"
    }
    
    @objc(AccessibilityIdentifiers_TabViewContainerScreen) class TabViewContainerScreen: NSObject {
        @objc static let activity = "TabViewContainerScreen.activity"
        @objc static let swap = "TabViewContainerScreen.swap"
        @objc static let home = "TabViewContainerScreen.home"
        @objc static let send = "TabViewContainerScreen.send"
        @objc static let request = "TabViewContainerScreen.request"
    }
    
    // MARK: Swap
    
    class ExchangeScreen {
        static let exchangeButton = "ExchangeScreen.exchangeButton"
        static let confirmButton = "ExchangeScreen.confirmButton"
        static let backButton = "ExchangeScreen.backButton"
        static let dismissButton = "ExchangeScreen.dismissButton"
    }
    
    class TradingPairView {
        static let fromLabel = "TradingPairView.from.titleLabel"
        static let toLabel = "TradingPairView.to.titleLabel"
    }
    
    class NumberKeypadView {
        static let numberButton = "NumberKeypadView.numberButton"
        static let decimalButton = "NumberKeypadView.decimalButton"
        static let backspace = "NumberKeypadView.backspace"
    }
}
