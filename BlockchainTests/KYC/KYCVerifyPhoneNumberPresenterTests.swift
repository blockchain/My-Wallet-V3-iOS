//
//  KYCVerifyPhoneNumberPresenterTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class KYCVerifyPhoneNumberPresenterTests: XCTestCase {

    private var view: MockKYCVerifyPhoneNumberView!
    private var interactor: MockKYCVerifyPhoneNumberInteractor!
    private var presenter: KYCVerifyPhoneNumberPresenter!

    override func setUp() {
        super.setUp()
        view = MockKYCVerifyPhoneNumberView()
        interactor = MockKYCVerifyPhoneNumberInteractor()
        presenter = KYCVerifyPhoneNumberPresenter(view: view, interactor: interactor)
    }

    func testSuccessfulVerification() {
        interactor.shouldSucceed = true
        view.didCallShowLoadingViewExpectation = expectation(description: "Loading view shown")
        view.didCallHideLoadingViewExpectation = expectation(description: "Loading view hidden")
        view.didCallShowVerifCodeViewExpectation = expectation(
            description: "Show verification code view shown when 1st step of verification succeeds"
        )
        presenter.verify(number: "1234567890", userId: "aUserId")
        waitForExpectations(timeout: 0.1)
    }

    func testFailedVerification() {
        interactor.shouldSucceed = false
        view.didCallShowLoadingViewExpectation = expectation(description: "Loading view shown")
        view.didCallHideLoadingViewExpectation = expectation(description: "Loading view hidden")
        view.didCallShowErrorExpectation = expectation(description: "Error displayed when verification fails")
        presenter.verify(number: "1234567890", userId: "aUserId")
        waitForExpectations(timeout: 0.1)
    }
}
