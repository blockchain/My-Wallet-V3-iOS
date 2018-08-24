//
//  KYCVerifyPhoneNumberPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

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
                self.handleError(error)
            })
    }

    func verify(number: String, code: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        disposable = interactor.verify(number: number, code: code)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [unowned self] in
                self.handleVerifyCodeSuccess()
            }, onError: { [unowned self] error in
                self.handleError(error)
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
