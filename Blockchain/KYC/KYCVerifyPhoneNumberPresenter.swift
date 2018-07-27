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

    func showEnterVerificationCodeAlert()

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
    }

    func sendVerificationCode(to number: String) {
        // TODO: replace with actual network call
        NetworkManager.shared.requestJsonOrString(
            "http://www.mocky.io/v2/5b5ba96c3200006500426247",
            method: .post
        ).map {
            guard $0.statusCode == 200 else {
                throw NetworkError.generic(message: nil)
            }
            guard let json = $1 as? JSON else {
                throw NetworkError.jsonParseError
            }
        }
    }
}
