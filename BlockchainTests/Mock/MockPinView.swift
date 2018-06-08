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
    var didCallErrorExpectation: XCTestExpectation?
    var didCallErrorPinRetryLimitExceededExpectation: XCTestExpectation?
    var didCallSuccessPinValidExpectation: XCTestExpectation?

    init() {
    }

    func showLoadingView(withText text: String) {
        didCallShowLoadingViewExpectation?.fulfill()
    }

    func hideLoadingView() {
        didCallHideLoadingViewExpectation?.fulfill()
    }

    func error(message: String) {
        didCallErrorExpectation?.fulfill()
    }

    func errorPinRetryLimitExceeded() {
        didCallErrorPinRetryLimitExceededExpectation?.fulfill()
    }

    func successPinValid() {
        didCallSuccessPinValidExpectation?.fulfill()
    }
}
