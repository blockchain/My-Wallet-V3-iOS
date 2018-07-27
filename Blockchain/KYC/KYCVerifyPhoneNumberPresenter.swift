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
        // TODO
    }
}
