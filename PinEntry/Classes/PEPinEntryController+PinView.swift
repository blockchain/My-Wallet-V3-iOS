//
//  PEPinEntryController+PinView.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

extension PEPinEntryController: PinView {
    @objc func validate(pin: Pin) {
        guard Reachability.hasInternetConnection() else {
            AlertViewPresenter.shared.showNoInternetConnectionAlert()
            return
        }

        guard let pinKey = BlockchainSettings.App.shared.pinKey else {
            print("Cannot validate pin. Pin key is nil")
            return
        }

        // Check for maintenance first, followed by validating the user's pin
        showLoadingView(withText: LocalizationConstants.verifying)

        _ = WalletService.shared.walletOptions
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] walletOptions in
                guard let strongSelf = self else { return }
                guard !walletOptions.downForMaintenance else {
                    strongSelf.hideLoadingView()

                    let errorMessage = walletOptions.mobileInfo?.message ?? LocalizationConstants.Errors.siteMaintenanceError
                    strongSelf.error(message: errorMessage)

                    return
                }

                let payload = PinPayload(pinCode: pin.toString, pinKey: pinKey)
                _ = strongSelf.pinPresenter.validatePin(payload)
            }, onError: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.hideLoadingView()
                strongSelf.error(message: LocalizationConstants.Errors.invalidServerResponse)
            })
    }

    func showLoadingView(withText text: String) {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: text)
    }

    func hideLoadingView() {
        LoadingViewPresenter.shared.hideBusyView()
    }

    func error(message: String) {
        self.reset()
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func errorPinRetryLimitExceeded() {
        AuthenticationCoordinator.shared.logout(showPasswordView: true)
        error(message: LocalizationConstants.Pin.validationCannotBeCompleted)
    }

    func successPinValid(pinPassword: String) {
        // !verifyOnly indicates that the user wants to change their pin
        if !self.verifyOnly && !self.verifyOptional {
            hideLoadingView()
            self.goToEnter1Pin()
            return
        }

        self.pinDelegate.pinEntryControllerDidObtainPasswordDecryptionKey(pinPassword)
    }
}
