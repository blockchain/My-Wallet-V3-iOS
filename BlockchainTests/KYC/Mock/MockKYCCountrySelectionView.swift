//
//  MockKYCCountrySelectionView.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class MockKYCCountrySelectionView: KYCCountrySelectionView {
    var didCallContinueKycFlow: XCTestExpectation?
    var didCallStartPartnerExchangeFlow: XCTestExpectation?
    var didCallShowExchangeNotAvailable: XCTestExpectation?

    func continueKycFlow(country: KYCCountry) {
        didCallContinueKycFlow?.fulfill()
    }

    func startPartnerExchangeFlow(country: KYCCountry) {
        didCallStartPartnerExchangeFlow?.fulfill()
    }

    func showExchangeNotAvailable(country: KYCCountry) {
        didCallShowExchangeNotAvailable?.fulfill()
    }
}
