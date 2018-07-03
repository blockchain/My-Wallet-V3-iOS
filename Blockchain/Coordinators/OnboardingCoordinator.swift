//
//  OnboardingCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Coordinator for the onboarding flow.
class OnboardingCoordinator: Coordinator {
    static let shared = OnboardingCoordinator()

    private var createWallet: BCCreateWalletView?

    private let walletService: WalletService

    private var disposable: Disposable?

    init(walletService: WalletService = WalletService.shared) {
        self.walletService = walletService
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: Public Methods

    func start() {
        disposable = walletService.walletOptions
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { walletOptions in
                guard !walletOptions.downForMaintenance else {
                    AlertViewPresenter.shared.showMaintenanceError(from: walletOptions)
                    return
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
        createWallet = BCCreateWalletView.instanceFromNib()
        createWallet!.createBlankWallet()
        createWallet!.isRecoveringWallet = isRecoveringWallet
        AuthenticationManager.shared.setHandlerForWalletCreation(handler: AuthenticationCoordinator.shared.authHandler)
        ModalPresenter.shared.showModal(
            withContent: createWallet!,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: title
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

extension OnboardingCoordinator: WalletRecoveryDelegate {
    func didRecoverWallet() {
        createWallet?.didRecoverWallet()
    }

    func didFailRecovery() {
        createWallet?.showPassphraseTextField()
    }
}
