//
//  KYCVerifyPhoneNumberPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

protocol KYCVerifyPhoneNumberView: class {
    func showLoadingView(with text: String)

    func showEnterVerificationCodeView()

    func showError(message: String)

    func hideLoadingView()
}

class KYCVerifyPhoneNumberPresenter {

    private weak var view: KYCVerifyPhoneNumberView?
    private var disposable: Disposable?

    init(view: KYCVerifyPhoneNumberView) {
        self.view = view
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func verify(number: String, userId: String) {
        view?.showLoadingView(with: LocalizationConstants.loading)
        disposable = sendVerificationCode(to: number, for: userId)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.handleSendVerificationCodeSuccess()
            }, onError: { [weak self] error in
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

    private func sendVerificationCode(to number: String, for userId: String) -> Single<Bool> {
        // TODO: Consolidate with Maurice's networking
        // Note: PATCH /users/{userId} endpoint is still in development
        let endPoint = "https://api.dev.blockchain.info/nabu-app/users/\(userId)"
        let parameters = [
            "mobile": number
        ]
        return NetworkManager.shared.requestJsonOrString(
            endPoint,
            method: .patch,
            parameters: parameters
        ).map { (response, _) in
            guard response.statusCode == 200 else {
                throw NetworkError.generic(message: nil)
            }
            return true
        }
    }
}
