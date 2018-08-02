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

    func startVerificationSuccess()

    func showError(message: String)

    func hideLoadingView()
}

protocol KYCConfirmPhoneNumberView: KYCVerifyPhoneNumberView {
    func confirmCodeSuccess()
}

class KYCVerifyPhoneNumberPresenter {

    private let interactor: KYCVerifyPhoneNumberInteractor
    private weak var view: KYCVerifyPhoneNumberView?

    init(
        view: KYCVerifyPhoneNumberView,
        interactor: KYCVerifyPhoneNumberInteractor = KYCVerifyPhoneNumberInteractor()
    ) {
        self.view = view
        self.interactor = interactor
    }

    // MARK: - Public

    func startVerification(number: String, userId: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        interactor.startVerification(number: number, userId: userId, success: { [weak self] _ in
            self?.handleStartVerificationCodeSuccess()
        }, failure: { [weak self] error in
            Logger.shared.error("Could not complete mobile verification. Error: \(error)")
            self?.handleError(error)
        })
    }

    func verify(number: String, userId: String, code: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        interactor.verify(number: number, userId: userId, code: code, success: { [weak self] _ in
            self?.handleVerifyCodeSuccess()
        }, failure: { [weak self] error in
            self?.handleError(error)
        })
    }

    // MARK: - Private

    private func handleVerifyCodeSuccess() {
        view?.hideLoadingView()
        if let confirmView = view as? KYCConfirmPhoneNumberView {
            confirmView.confirmCodeSuccess()
        }
    }

    private func handleStartVerificationCodeSuccess() {
        view?.hideLoadingView()
        view?.startVerificationSuccess()
    }

    private func handleError(_ error: Error) {
        Logger.shared.error("Could not complete mobile verification. Error: \(error)")
        view?.hideLoadingView()
        view?.showError(message: LocalizationConstants.KYC.failedToConfirmNumber)
    }
}
