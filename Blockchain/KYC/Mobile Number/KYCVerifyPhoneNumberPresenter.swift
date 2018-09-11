//
//  KYCVerifyPhoneNumberPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PhoneNumberKit
import RxSwift

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
    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
    }

    init(
        view: KYCVerifyPhoneNumberView,
        interactor: KYCVerifyPhoneNumberInteractor = KYCVerifyPhoneNumberInteractor()
    ) {
        self.view = view
        self.interactor = interactor
    }

    // MARK: - Public

    func startVerification(number: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        disposable = interactor.startVerification(number: number)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [unowned self] in
                self.handleStartVerificationCodeSuccess()
            }, onError: { [unowned self] error in
                self.handleStartVerificationError(error)
            })
    }

    func verifyNumber(with code: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        disposable = interactor.verifyNumber(with: code)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [unowned self] in
                self.handleVerifyCodeSuccess()
            }, onError: { [unowned self] error in
                self.handleVerifyNumberError(error)
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

    private func handleStartVerificationError(_ error: Error) {
        Logger.shared.error("Could not start mobile verification process. Error: \(error)")
        view?.hideLoadingView()
        if let phoneNumberError = error as? PhoneNumberError {
            view?.showError(message: phoneNumberError.errorDescription ?? LocalizationConstants.KYC.invalidPhoneNumber)
        } else {
            view?.showError(message: LocalizationConstants.KYC.invalidPhoneNumber)
        }
    }

    private func handleVerifyNumberError(_ error: Error) {
        Logger.shared.error("Could not complete mobile verification. Error: \(error)")
        view?.hideLoadingView()
        view?.showError(message: LocalizationConstants.KYC.failedToConfirmNumber)
    }
}
