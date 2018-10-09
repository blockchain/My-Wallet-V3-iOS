//
//  KYCStateSelectionPresenterTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest
@testable import Blockchain

class KYCStateSelectionPresenterTests: XCTestCase {

    private var view: MockKYCStateSelectionView!
    private var presenter: KYCStateSelectionPresenter!

    override func setUp() {
        super.setUp()
        view = MockKYCStateSelectionView()
        presenter = KYCStateSelectionPresenter(view: view)
    }

    func testSelectedSupportedKycState() {
        view.didCallContinueKycFlow = expectation(description: "Continue KYC flow when user selects valid KYC state.")
        let state = KYCState(code: "CA", countryCode: "US", name: "California", scopes: ["KYC"])
        presenter.selected(state: state)
        waitForExpectations(timeout: 0.1)
    }

    func testSelectedUnsupportedState() {
        view.didCallShowExchangeNotAvailable = expectation(
            description: "KYC flow stops when user selects unsupported state."
        )
        let state = KYCState(code: "NY", countryCode: "US", name: "New York", scopes: [])
        presenter.selected(state: state)
        waitForExpectations(timeout: 0.1)
    }
}
