//
//  PinPresenterTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest
@testable import Blockchain
@testable import RxBlocking
@testable import RxSwift

class PinPresenterTests: XCTestCase {

    var pinView: MockPinView!
    var interactor: MockPinInteractor!
    var presenter: PinPresenter!

    override func setUp() {
        super.setUp()
        pinView = MockPinView()
        interactor = MockPinInteractor()
        presenter = PinPresenter(view: pinView, interactor: interactor)
    }

    func testIncorrectPin() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallErrorExpectation = expectation(description: "Did call error.")
        interactor.mockValidatePinResponse = Single.just(
            GetPinResponse(code: GetPinResponse.StatusCode.incorrect.rawValue, error: "incorrect", pinDecryptionValue: nil)
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }

    func testPinDecryptionEmpty() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallErrorExpectation = expectation(description: "Did call error.")
        interactor.mockValidatePinResponse = Single.just(
            GetPinResponse(code: GetPinResponse.StatusCode.success.rawValue, error: "incorrect", pinDecryptionValue: "")
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }

    func testMaxRetryPin() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallErrorPinRetryLimitExceededExpectation = expectation(description: "Did max retry limit error.")
        interactor.mockValidatePinResponse = Single.just(
            GetPinResponse(code: GetPinResponse.StatusCode.deleted.rawValue, error: "incorrect", pinDecryptionValue: nil)
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }

    func testValidPin() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallSuccessPinValidExpectation = expectation(description: "Valid pin.")
        interactor.mockValidatePinResponse = Single.just(
            GetPinResponse(code: GetPinResponse.StatusCode.success.rawValue, error: nil, pinDecryptionValue: "success")
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }
}
