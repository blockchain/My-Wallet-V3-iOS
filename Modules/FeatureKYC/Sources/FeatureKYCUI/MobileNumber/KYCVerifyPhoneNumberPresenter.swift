// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PhoneNumberKit
import PlatformKit
import RxSwift
import ToolKit

protocol KYCVerifyPhoneNumberView: AnyObject {
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

    private let subscriptionScheduler: SerialDispatchQueueScheduler

    deinit {
        disposable?.dispose()
    }

    init(
        subscriptionScheduler: SerialDispatchQueueScheduler = MainScheduler.asyncInstance,
        view: KYCVerifyPhoneNumberView,
        interactor: KYCVerifyPhoneNumberInteractor = KYCVerifyPhoneNumberInteractor()
    ) {
        self.subscriptionScheduler = subscriptionScheduler
        self.view = view
        self.interactor = interactor
    }

    // MARK: - Public

    func startVerification(number: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        disposable = interactor.startVerification(number: number)
            .subscribe(on: subscriptionScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [unowned self] in
                handleStartVerificationCodeSuccess()
            }, onError: { [unowned self] error in
                handleStartVerificationError(error)
            })
    }

    func verifyNumber(with code: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        disposable = interactor.verifyNumber(with: code)
            .subscribe(on: subscriptionScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [unowned self] in
                handleVerifyCodeSuccess()
            }, onError: { [unowned self] error in
                handleVerifyNumberError(error)
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
