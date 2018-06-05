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
protocol PinView {
    func showLoadingView(withText text: String)

    func hideLoadingView()

    func error(message: String)

    func errorPinRetryLimitExceeded()

    func successPinValid()
}

/// Presenter for the pin flow.
class PinPresenter {

    let view: PinView
    let interactor: PinInteractor

    init(view: PinView, interactor: PinInteractor) {
        self.view = view
        self.interactor = interactor
    }

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    /// Calling this method will also invoked the necessary methods to the PinView.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: a Disposable
    func validatePin(_ pinPayload: PinPayload) -> Disposable {
        self.view.showLoadingView(withText: LocalizationConstants.verifying)

        return interactor.validatePin(pinPayload)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.view.hideLoadingView()

                guard let statusCode = response.statusCode else {
                    strongSelf.view.error(message: LocalizationConstants.Pin.incorrect)
                    return
                }

                switch statusCode {
                case .deleted:
                    strongSelf.view.errorPinRetryLimitExceeded()
                case .incorrect:
                    let errorMessage = response.error ?? LocalizationConstants.Pin.incorrectUnknownError
                    strongSelf.view.error(message: errorMessage)
                case .success:
                    if response.pinDecryptionValue?.count == 0 {
                        // Will this ever happen?
                        strongSelf.view.error(message: LocalizationConstants.Pin.responseSuccessLengthZero)
                        return
                    }
                    strongSelf.view.successPinValid()
                }

            }, onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.view.hideLoadingView()
                strongSelf.view.error(message: LocalizationConstants.Errors.invalidServerResponse)
            })
    }
}
