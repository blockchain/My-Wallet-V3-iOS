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

    func error(message: String)

    func errorPinRetryLimitExceeded()

    func successPinValid(pinPassword: String)
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

                guard let statusCode = response.statusCode else {
                    strongSelf.view.hideLoadingView()
                    strongSelf.view.error(message: LocalizationConstants.Pin.incorrect)
                    return
                }

                switch statusCode {
                case .deleted:
                    strongSelf.view.hideLoadingView()
                    strongSelf.view.errorPinRetryLimitExceeded()
                case .incorrect:
                    strongSelf.view.hideLoadingView()
                    let errorMessage = response.error ?? LocalizationConstants.Pin.incorrectUnknownError
                    strongSelf.view.error(message: errorMessage)
                case .success:
                    guard let pinPassword = response.pinDecryptionValue, pinPassword.count != 0 else {
                        strongSelf.view.hideLoadingView()
                        strongSelf.view.error(message: LocalizationConstants.Pin.responseSuccessLengthZero)
                        return
                    }
                    strongSelf.view.successPinValid(pinPassword: pinPassword)
                }
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
}
