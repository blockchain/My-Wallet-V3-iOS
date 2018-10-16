//
//  MockKYCStateSelectionView.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class MockKYCStateSelectionView: KYCStateSelectionView {
    var didCallContinueKycFlow: XCTestExpectation?
    var didCallShowExchangeNotAvailable: XCTestExpectation?
    var didCallDisplayStates: XCTestExpectation?

    func continueKycFlow(state: KYCState) {
        didCallContinueKycFlow?.fulfill()
    }

    func showExchangeNotAvailable(state: KYCState) {
        didCallShowExchangeNotAvailable?.fulfill()
    }

    func display(states: [KYCState]) {
        didCallDisplayStates?.fulfill()
    }
}
