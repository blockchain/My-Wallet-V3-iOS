// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAuthenticationMock
@testable import FeatureKYCUI
import PlatformKit
@testable import PlatformKitMock
import XCTest

class KYCCountrySelectionPresenterTests: XCTestCase {

    private var view: MockKYCCountrySelectionView!
    private var presenter: KYCCountrySelectionPresenter!

    override func setUp() {
        super.setUp()
        view = MockKYCCountrySelectionView()
        let jwtService = JWTServiceMock()
        jwtService.expectedResult = .success("jwt-token")
        let kycClient = KYCClientMock()
        kycClient.expectedSelectCountry = .empty()
        let interactor = KYCCountrySelectionInteractor(jwtService: jwtService, kycClient: kycClient)
        presenter = KYCCountrySelectionPresenter(view: view, interactor: interactor)
    }

    func testSelectedSupportedKycCountry() {
        view.didCallContinueKycFlow = expectation(description: "Continue KYC flow when user selects valid KYC country.")
        let country = CountryData(code: "TEST", name: "Test Country", scopes: ["KYC"], states: [])
        presenter.selected(country: country)
        waitForExpectations(timeout: 0.1)
    }

    func testSelectedCountryWithStates() {
        view.didCallContinueKycFlow = expectation(
            description: """
            KYC flow continues when user selects a country with states even if the country is not available for KYC
            """
        )
        let country = CountryData(code: "TEST", name: "Test Country", scopes: [], states: ["CA"])
        presenter.selected(country: country)
        waitForExpectations(timeout: 0.1)
    }
}
