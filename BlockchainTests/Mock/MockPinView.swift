//
//  MockPinView.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest

class MockPinView: PinView {

    var didCallShowLoadingViewExpectation: XCTestExpectation?
    var didCallHideLoadingViewExpectation: XCTestExpectation?
    var didCallAlertCommonPinExpectation: XCTestExpectation?
    var didCallErrorExpectation: XCTestExpectation?
    var didCallErrorPinRetryExceededExpectation: XCTestExpectation?
    var didCallErrorPinsDontMatch: XCTestExpectation?
    var didCallSuccessPinValidExpectation: XCTestExpectation?
    var didCallSuccessFirstEntryForChangePin: XCTestExpectation?

    init() {
    }

    func showLoadingView(withText text: String) {
        didCallShowLoadingViewExpectation?.fulfill()
    }

    func hideLoadingView() {
        didCallHideLoadingViewExpectation?.fulfill()
    }

    func alertCommonPin(continueHandler: @escaping (() -> Void)) {
        didCallAlertCommonPinExpectation?.fulfill()
    }

    func error(message: String) {
        didCallErrorExpectation?.fulfill()
    }

    func errorPinRetryLimitExceeded() {
        didCallErrorPinRetryExceededExpectation?.fulfill()
    }

    func errorPinsDontMatch() {
        didCallErrorPinsDontMatch?.fulfill()
    }

    func successPinValid(pinPassword: String) {
        didCallSuccessPinValidExpectation?.fulfill()
    }

    func successFirstEntryForChangePin(pin: Pin) {
        didCallSuccessFirstEntryForChangePin?.fulfill()
    }
}
