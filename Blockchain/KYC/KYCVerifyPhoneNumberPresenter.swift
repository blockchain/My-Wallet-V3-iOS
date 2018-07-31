//
//  KYCVerifyPhoneNumberPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol KYCVerifyPhoneNumberView: class {
    func showLoadingView(with text: String)

    func showEnterVerificationCodeView()

    func showError(message: String)

    func hideLoadingView()
}

class KYCVerifyPhoneNumberPresenter {

    private weak var view: KYCVerifyPhoneNumberView?

    init(view: KYCVerifyPhoneNumberView) {
        self.view = view
    }

    func verify(number: String, userId: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)

        let paramaters = ["mobile": number]
        let request = KYCNetworkRequest(put: .updateMobileNumber(userId: userId), parameters: paramaters)
        request.send(taskSuccess: { [weak self] _ in
            self?.handleSendVerificationCodeSuccess()
        }, taskFailure: { [weak self] error in
            self?.handleSendVerificationCodeError(error)
        })
    }

    // MARK: - Private

    private func handleSendVerificationCodeSuccess() {
        view?.hideLoadingView()
        view?.showEnterVerificationCodeView()
    }

    private func handleSendVerificationCodeError(_ error: Error) {
        Logger.shared.error("Could not complete mobile verification. Error: \(error)")
        view?.hideLoadingView()
        view?.showError(message: LocalizationConstants.KYC.failedToConfirmNumber)
    }
}
