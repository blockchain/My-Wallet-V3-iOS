//
//  KYCEnterPhoneNumberPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol KYCEnterPhoneNumberView: class {
    func showLoadingView(with text: String)

    func showEnterVerificationCodeView()

    func showError(message: String)

    func hideLoadingView()
}

class KYCEnterPhoneNumberPresenter {

    private let interactor: KYCEnterPhoneNumberInteractor
    private weak var view: KYCEnterPhoneNumberView?

    init(
        view: KYCEnterPhoneNumberView,
        interactor: KYCEnterPhoneNumberInteractor = KYCEnterPhoneNumberInteractor()
    ) {
        self.view = view
        self.interactor = interactor
    }

    func verify(number: String, userId: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        interactor.verify(number: number, userId: userId, success: { [weak self] _ in
            self?.handleSendVerificationCodeSuccess()
        }, failure: { [weak self] error in
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
