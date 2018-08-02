//
//  MockKYCVerifyPhoneNumberView.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest

class MockKYCVerifyPhoneNumberView: KYCVerifyPhoneNumberView {
    var didCallShowLoadingViewExpectation: XCTestExpectation?
    var didCallShowVerifCodeViewExpectation: XCTestExpectation?
    var didCallShowErrorExpectation: XCTestExpectation?
    var didCallHideLoadingViewExpectation: XCTestExpectation?

    func showLoadingView(with text: String) {
        didCallShowLoadingViewExpectation?.fulfill()
    }

    func showEnterVerificationCodeView() {
        didCallShowVerifCodeViewExpectation?.fulfill()
    }

    func showError(message: String) {
        didCallShowErrorExpectation?.fulfill()
    }

    func hideLoadingView() {
        didCallHideLoadingViewExpectation?.fulfill()
    }
}
