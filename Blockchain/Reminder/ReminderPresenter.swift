//
//  ReminderCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

/// Presenter for displaying various security-related reminders to the user.
@objc class ReminderPresenter: NSObject {
    static let shared = ReminderPresenter()

    @objc class func sharedInstance() -> ReminderPresenter { return shared }

    // MARK: - Properties

    /// Optional ReminderType to show after the wallet's account info has been retrieved
    var reminderTypeToShow: ReminderType?

    var disposable: Disposable?

    private let walletManager: WalletManager
    internal let authenticationService: NabuAuthenticationService

    /// This `completionHandler` is called when any of the modals
    /// are dismissed. Upon dismissal we need to potentially route the
    /// user through the KYC flow if they arrived to the app via a deep link.
    /// It's preferable to use a closure given that this is a singleton. 
    private var completionHandler: (() -> Void)?

    // MARK: - Initializers

    private init(
        walletManager: WalletManager = WalletManager.shared,
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared
    ) {
        self.walletManager = walletManager
        self.authenticationService = authenticationService
        super.init()
        self.walletManager.accountInfoDelegate = self
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: - Public Methods

    func showSecurityReminder(onCompletion: @escaping (() -> Void)) {
        completionHandler = onCompletion
        BlockchainSettings.App.shared.dateOfLastSecurityReminder = NSDate()

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
        let onboardingSettings = BlockchainSettings.Onboarding.shared

        appSettings.hasSeenEmailReminder = true

        let setupViewController = WalletSetupViewController(setupDelegate: AuthenticationCoordinator.shared)!
        setupViewController.emailOnly = !onboardingSettings.shouldShowBiometrySetup
        setupViewController.modalTransitionStyle = .crossDissolve

        onboardingSettings.shouldShowBiometrySetup = false
        onboardingSettings.didFailBiometrySetup = false

        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(setupViewController, animated: true)
    }

    func checkIfSettingsLoadedAndShowEmailReminder(onCompletion: @escaping (() -> Void)) {
        completionHandler = onCompletion
        guard walletManager.wallet.hasLoadedAccountInfo else {
            reminderTypeToShow = .email
            return
        }

        if !walletManager.wallet.hasVerifiedEmail() {
            showEmailVerificationReminder()
        } else {
            showSecurityReminder(onCompletion: onCompletion)
        }
    }

    func checkIfSettingsLoadedAndShowTwoFactorReminder() {
        guard !walletManager.wallet.hasEnabledTwoStep() else {
            Logger.shared.info("Two factor already enabled, no need to show a reminder.")
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

        disposable = syncNabuWithWallet(successHandler: nil, errorHandler: nil)
    }
}

extension ReminderPresenter: ReminderModalDelegate {
    func dismissTapped(_ reminderViewController: ReminderModalViewController!) {
        reminderViewController.dismiss(animated: true) { [weak self] in
            guard let this = self else { return }
            this.completionHandler?()
            this.completionHandler = nil
        }
    }
    
    func showBackup() {
        AppCoordinator.shared.showBackupView()
    }

    func showTwoStep() {
        AppCoordinator.shared.showSettingsView { settingsViewController in
            settingsViewController.showTwoStep()
        }
    }
}
