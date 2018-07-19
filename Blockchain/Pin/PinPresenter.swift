//
//  PinPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// The View that the PinPresenter displays to.
@objc protocol PinView {
    func showLoadingView(withText text: String)

    func hideLoadingView()

    func alertCommonPin(continueHandler: @escaping (() -> Void))

    func error(message: String)

    func errorPinRetryLimitExceeded()

    func errorPinsDontMatch()

    func successPinValid(pinPassword: String)

    func successFirstEntryForChangePin(pin: Pin)
}

/// Presenter for the pin flow.
@objc class PinPresenter: NSObject {

    private let view: PinView
    private let interactor: PinInteractor
    private let walletService: WalletService

    @objc init(
        view: PinView,
        interactor: PinInteractor = PinInteractor.shared,
        walletService: WalletService = WalletService.shared
    ) {
        self.view = view
        self.interactor = interactor
        self.walletService = walletService
    }

    // MARK: - Changing/First-time Setting Pin

    /// Validates that the 1st pin entered by the user during the change pin flow,
    /// or the first time the user is setting a pin, is valid.
    ///
    /// - Parameter pin: the entered pin
    func validateFirstEntryForChangePin(pin: Pin, previousPin: Pin) {
        guard pin.isValid else {
            self.view.error(message: LocalizationConstants.Pin.chooseAnotherPin)
            return
        }

        guard pin != previousPin else {
            self.view.error(message: LocalizationConstants.Pin.newPinMustBeDifferent)
            return
        }

        guard !pin.isCommon else {
            self.view.alertCommonPin { [unowned self] in
                self.view.successFirstEntryForChangePin(pin: pin)
            }
            return
        }

        self.view.successFirstEntryForChangePin(pin: pin)
    }

    /// Validates that the 2nd pin entered during the change pin flow matches the
    /// 1st pin entered, and if so, it will proceed to change the user's pin.
    ///
    /// - Parameters:
    ///   - pin: the pin to confirm
    ///   - firstPin: the 1st pin entered during the change pin flow
    func validateConfirmPinForChangePin(pin: Pin, firstPin: Pin) {
        guard pin == firstPin else {
            self.view.errorPinsDontMatch()
            return
        }

//        guard WalletManager.shared.wallet.isInitialized() || WalletManager.shared.wallet.password != nil else {
//            self.view.error(message: LocalizationConstants.Pin.cannotSaveInvalidWalletState)
//            return
//        }

        // TODO update/change this
//        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.verifying)

//        try? pin.save()
    }

    // MARK: - Pin Validation

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    /// Calling this method will also fetch the WalletOptions to see if the server is under maintenance.
    /// If the site is under maintenance, the pin will not be validated to the pin-store.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: a Disposable
    func validatePin(_ pinPayload: PinPayload) -> Disposable {
        self.view.showLoadingView(withText: LocalizationConstants.verifying)

        return Observable.combineLatest(
            walletService.walletOptions.asObservable(),
            interactor.validatePin(pinPayload).asObservable()
        ) { (walletOptions, pinResponse) -> (WalletOptions, GetPinResponse) in
            return (walletOptions, pinResponse)
        }.subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (walletOptions, response) in
                guard let strongSelf = self else {
                    return
                }

                guard !walletOptions.downForMaintenance else {
                    strongSelf.view.hideLoadingView()
                    let errorMessage = walletOptions.mobileInfo?.message ?? LocalizationConstants.Errors.siteMaintenanceError
                    strongSelf.view.error(message: errorMessage)
                    return
                }

                strongSelf.handle(getPinResponse: response)
            }, onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view.hideLoadingView()

                // Display error message from server, if any
                if let walletServiceError = error as? WalletServiceError {
                    if case let WalletServiceError.generic(message) = walletServiceError {
                        let errorMessage = message ?? LocalizationConstants.Errors.invalidServerResponse
                        strongSelf.view.error(message: errorMessage)
                        return
                    }
                }

                strongSelf.view.error(message: LocalizationConstants.Errors.invalidServerResponse)
            })
    }

    private func handle(getPinResponse response: GetPinResponse) {
        guard let statusCode = response.statusCode else {
            view.hideLoadingView()
            view.error(message: LocalizationConstants.Pin.incorrect)
            return
        }

        switch statusCode {
        case .deleted:
            view.hideLoadingView()
            view.errorPinRetryLimitExceeded()
        case .incorrect:
            view.hideLoadingView()
            let errorMessage = response.error ?? LocalizationConstants.Pin.incorrectUnknownError
            view.error(message: errorMessage)
        case .success:
            guard let pinPassword = response.pinDecryptionValue, pinPassword.count != 0 else {
                view.hideLoadingView()
                view.error(message: LocalizationConstants.Pin.responseSuccessLengthZero)
                return
            }
            view.successPinValid(pinPassword: pinPassword)
        }
    }
}
