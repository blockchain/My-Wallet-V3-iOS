//
//  PEPinEntryController+PinView.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

extension PEViewController {
    var pinValue: Pin? { return Pin(string: pin) }
}

extension PEPinEntryController {
    @objc func didEnterFirstPinForChangePinFlow(from controller: PEViewController, previousPin: Pin) {
        guard let pin = controller.pinValue else { return }
        self.pinPresenter.validateFirstEntryForChangePin(pin: pin, previousPin: previousPin)
    }

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

                let payload = PinPayload(
                    pinCode: pin.toString,
                    pinKey: pinKey,
                    persistLocally: strongSelf.verifyOptional
                )
                _ = strongSelf.pinPresenter.validatePin(payload)
            }, onError: { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.hideLoadingView()
                    strongSelf.error(message: LocalizationConstants.Errors.invalidServerResponse)
            })
    }
}

extension PEPinEntryController: PinView {
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

    func alertCommonPin(continueHandler: @escaping (() -> Void)) {
        let actions = [
            UIAlertAction(title: LocalizationConstants.continueString, style: .default, handler: { _ in
                continueHandler()
            }),
            UIAlertAction(title: LocalizationConstants.tryAgain, style: .default, handler: { [unowned self] _ in
                self.reset()
            })
        ]
        AlertViewPresenter.shared.standardNotify(
            message: LocalizationConstants.Pin.pinCodeCommonMessage,
            title: LocalizationConstants.Errors.warning,
            actions: actions,
            in: self
        )
    }

    func successFirstEntryForChangePin(pin: Pin) {
        self.go(toEnter2Pin: pin)
    }
}
