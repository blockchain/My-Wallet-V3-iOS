//
//  ReminderCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Presenter for displaying various security-related reminders to the user.
@objc class ReminderPresenter: NSObject {
    static let shared = ReminderPresenter()

    @objc class func sharedInstance() -> ReminderPresenter { return shared }

    // MARK: - Properties

    /// Optional ReminderType to show after the wallet's account info has been retrieved
    var reminderTypeToShow: ReminderType?

    private let walletManager: WalletManager

    // MARK: - Initializers

    private init(walletManager: WalletManager = WalletManager.shared) {
        self.walletManager = walletManager
        super.init()
        self.walletManager.accountInfoDelegate = self
    }

    // MARK: - Public Methods

    func showSecurityReminder() {
        BlockchainSettings.App.shared.reminderModalDate = NSDate()

        let wallet = walletManager.wallet

        guard wallet.getTotalActiveBalance() > 0 else {
            checkIfSettingsLoadedAndShowTwoFactorReminder()
            return
        }

        if !wallet.isRecoveryPhraseVerified() {
            showBackupReminder(firstReceive: false)
        } else {
            checkIfSettingsLoadedAndShowTwoFactorReminder()
        }
    }

    /// Displays a reminder to the user that two-factor should be enabled
    func showTwoFactorReminder() {
        let twoFactorController = ReminderModalViewController(reminderType: ReminderTypeTwoFactor)!
        twoFactorController.delegate = self
        presentInNavigationController(twoFactorController)
    }

    /// Displays a reminder to the user that they should store the backup phrase for their wallet
    @objc func showBackupReminder(firstReceive: Bool) {
        let reminderType = firstReceive ? ReminderTypeBackupJustReceivedBitcoin : ReminderTypeBackupHasBitcoin
        let backupController = ReminderModalViewController(reminderType: reminderType)!
        backupController.delegate = self
        presentInNavigationController(backupController)
    }

    /// Displays a reminder to the user that they still need to verify their email
    func showEmailVerificationReminder() {
        let appSettings = BlockchainSettings.App.shared
        let onboardingSettings = OnboardingSettings.shared

        appSettings.hasSeenEmailReminder = true

        let setupViewController = WalletSetupViewController(setupDelegate: AuthenticationCoordinator.shared)!
        setupViewController.emailOnly = !onboardingSettings.shouldShowBiometrySetup
        setupViewController.modalTransitionStyle = .crossDissolve

        onboardingSettings.shouldShowBiometrySetup = false
        onboardingSettings.didFailBiometrySetup = false

        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(setupViewController, animated: true)
    }

    func checkIfSettingsLoadedAndShowEmailReminder() {
        guard walletManager.wallet.hasLoadedAccountInfo else {
            reminderTypeToShow = .email
            return
        }

        if !walletManager.wallet.hasVerifiedEmail() {
            showEmailVerificationReminder()
        } else {
            showSecurityReminder()
        }
    }

    func checkIfSettingsLoadedAndShowTwoFactorReminder() {
        guard !walletManager.wallet.hasEnabledTwoStep() else {
            print("Two factor already enabled, no need to show a reminder.")
            return
        }

        guard walletManager.wallet.hasLoadedAccountInfo else {
            reminderTypeToShow = .twoFactor
            return
        }

        showTwoFactorReminder()
    }

    // MARK: - Private Methods

    private func presentInNavigationController(_ viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(navigationController, animated: true)
    }
}

extension ReminderPresenter: WalletAccountInfoDelegate {
    func didGetAccountInfo() {
        if let reminderTypeToShow = reminderTypeToShow {
            switch reminderTypeToShow {
            case .twoFactor:
                if !walletManager.wallet.hasEnabledTwoStep() {
                    showTwoFactorReminder()
                }
            case .email:
                if !walletManager.wallet.hasVerifiedEmail() {
                    showEmailVerificationReminder()
                }
            }

            self.reminderTypeToShow = nil
        }
    }
}

extension ReminderPresenter: ReminderModalDelegate {
    func showBackup() {
        AppCoordinator.shared.showBackupView()
    }

    func showTwoStep() {
        AppCoordinator.shared.showSettingsView { settingsViewController in
            settingsViewController.showTwoStep()
        }
    }
}
