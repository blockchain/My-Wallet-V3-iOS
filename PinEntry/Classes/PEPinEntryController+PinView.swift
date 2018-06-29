//
//  PEPinEntryController+PinView.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

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

        let payload = PinPayload(pinCode: pin.toString, pinKey: pinKey)
        _ = self.pinPresenter.validatePin(payload)
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
