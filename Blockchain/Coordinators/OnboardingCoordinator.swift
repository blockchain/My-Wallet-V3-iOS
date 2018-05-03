//
//  OnboardingCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Coordinator for the onboarding flow.
class OnboardingCoordinator: Coordinator {
    static let shared = OnboardingCoordinator()

    private init() {}

    // MARK: Public Methods

    func start() {
        NetworkManager.shared.checkForMaintenance(withCompletion: { [unowned self] response in
            if let message = response {
                print("Error checking for maintenance in wallet options: %@", message)
                AlertViewPresenter.shared.standardNotify(message: message, title: LocalizationConstants.Errors.error, handler: nil)
            }
        })
        self.showWelcomeScreen()
        AlertViewPresenter.shared.checkAndWarnOnJailbrokenPhones()
    }

    // MARK: Private Methods

    private func showWelcomeScreen() {
        let welcomeView = BCWelcomeView()
        welcomeView.delegate = self
        ModalPresenter.shared.showModal(withContent: welcomeView, closeType: ModalCloseTypeNone, showHeader: false, headerText: "")

        UIApplication.shared.statusBarStyle = .default
    }
}

extension OnboardingCoordinator: BCWelcomeViewDelegate {
    func showCreateWallet() {
        _showCreateWallet()
    }

    private func _showCreateWallet(isRecoveringWallet: Bool = false, title: String = LocalizationConstants.Onboarding.createNewWallet) {
        let createWallet = BCCreateWalletView.instanceFromNib()
        createWallet.isRecoveringWallet = isRecoveringWallet
        AuthenticationManager.shared.setHandlerForWalletCreation(handler: AuthenticationCoordinator.shared.authHandler)
        ModalPresenter.shared.showModal(
            withContent: createWallet,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.Onboarding.createNewWallet
        )
    }

    func showPairWallet() {
        let pairingInstructionsView = PairingInstructionsView.instanceFromNib()
        pairingInstructionsView.delegate = self
        ModalPresenter.shared.showModal(
            withContent: pairingInstructionsView,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.Onboarding.automaticPairing
        )
    }

    func showRecoverWallet() {
        let recoveryWarningAlert = UIAlertController(
            title: LocalizationConstants.Onboarding.recoverFunds,
            message: LocalizationConstants.Onboarding.recoverFundsOnlyIfForgotCredentials,
            preferredStyle: .alert
        )
        recoveryWarningAlert.addAction(
            UIAlertAction(
                title: LocalizationConstants.continueString,
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf._showCreateWallet(
                        isRecoveringWallet: true,
                        title: LocalizationConstants.Onboarding.recoverFunds
                    )
            })
        )
        recoveryWarningAlert.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(recoveryWarningAlert, animated: true)
    }
}

extension OnboardingCoordinator: PairingInstructionsViewDelegate {
    func onScanQRCodeClicked() {
        AuthenticationCoordinator.shared.startQRCodePairing()
    }

    func onManualPairClicked() {
        WalletManager.shared.wallet.twoFactorInput = nil
        AuthenticationCoordinator.shared.startManualPairing()
    }
}
