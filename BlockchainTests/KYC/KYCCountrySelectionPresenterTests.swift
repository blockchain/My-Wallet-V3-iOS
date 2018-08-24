//
//  KYCCountrySelectionPresenterTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class KYCCountrySelectionPresenterTests: XCTestCase {

    private var view: MockKYCCountrySelectionView!
    private var walletService: MockWalletService!
    private var presenter: KYCCountrySelectionPresenter!

    override func setUp() {
        super.setUp()
        view = MockKYCCountrySelectionView()
        walletService = MockWalletService()
        presenter = KYCCountrySelectionPresenter(view: view, walletService: walletService)
    }

    func testSelectedSupportedKycCountry() {
        view.didCallContinueKycFlow = expectation(description: "Continue KYC flow when user selects valid KYC country.")
        let country = KYCCountry(code: "TEST", name: "Test Country", regions: [], scopes: ["KYC"])
        presenter.selected(country: country)
        waitForExpectations(timeout: 0.1)
    }

    func testSelectedPartnerSupportedCountry() {
        view.didCallStartPartnerExchangeFlow = expectation(
            description: "Partner exchange flow starts when user selects country not supported by homebrew."
        )
        walletService.mockWalletOptions = WalletOptions(
            json: [
                "shapeshift": [
                    "countriesBlacklist": ["US"]
                ],
                "ios": [
                    "showShapeshift": true
                ]
            ]
        )
        let country = KYCCountry(code: "TEST", name: "Test Country", regions: [], scopes: [])
        presenter.selected(country: country)
        waitForExpectations(timeout: 0.1)
    }

    func testSelectedUnsupportedCountry() {
        view.didCallShowExchangeNotAvailable = expectation(
            description: "KYC flow stops when user selects blacklisted country"
        )
        walletService.mockWalletOptions = WalletOptions(
            json: [
                "shapeshift": [
                    "countriesBlacklist": ["US"]
                ],
                "ios": [
                    "showShapeshift": true
                ]
            ]
        )
        let country = KYCCountry(code: "US", name: "Test Country", regions: [], scopes: [])
        presenter.selected(country: country)
        waitForExpectations(timeout: 0.1)
    }
}
