// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
import PlatformKit
@testable import PlatformKitMock
import RxSwift
import XCTest

class KYCVerifyPhoneNumberPresenterTests: XCTestCase {

    private var view: MockKYCConfirmPhoneNumberView!
    private var interactor: MockKYCVerifyPhoneNumberInteractor!
    private var presenter: KYCVerifyPhoneNumberPresenter!

    override func setUp() {
        super.setUp()
        view = MockKYCConfirmPhoneNumberView()
        interactor = MockKYCVerifyPhoneNumberInteractor(
            mobileService: MobileSettingsServiceAPIMock(),
            walletSync: WalletNabuSynchronizerServiceAPIMock()
        )
        presenter = KYCVerifyPhoneNumberPresenter(
            subscriptionScheduler: MainScheduler.instance,
            view: view,
            interactor: interactor
        )
    }

    // TODO: Fix broken test
    func testSuccessfulVerification() throws {
        throw XCTSkip("disabled")
        // interactor.shouldSucceed = true
        // view.didCallShowLoadingViewExpectation = expectation(description: "Loading view shown")
        // view.didCallHideLoadingViewExpectation = expectation(description: "Loading view hidden")
        // view.didCallConfirmCodeExpectation = expectation(description: "Verification succeeds")
        // presenter.verifyNumber(with: "12345")
        // waitForExpectations(timeout: 0.1)
    }

    // TODO: Fix broken test
    func testFailedVerification() throws {
        throw XCTSkip("disabled")
        // interactor.shouldSucceed = false
        // view.didCallShowLoadingViewExpectation = expectation(description: "Loading view shown")
        // view.didCallHideLoadingViewExpectation = expectation(description: "Loading view hidden")
        // view.didCallShowErrorExpectation = expectation(description: "Error displayed when verification fails")
        // presenter.verifyNumber(with: "12345")
        // waitForExpectations(timeout: 0.1)
    }

    func testSuccessfulStartVerification() throws {
        throw XCTSkip("disabled")
        // interactor.shouldSucceed = true
        // view.didCallShowLoadingViewExpectation = expectation(description: "Loading view shown")
        // view.didCallHideLoadingViewExpectation = expectation(description: "Loading view hidden")
        // view.didCallStartVerifSuccessExpectation = expectation(
        //     description: "Show verification code view shown when 1st step of verification succeeds"
        // )
        // presenter.startVerification(number: "1234567890")
        // waitForExpectations(timeout: 0.1)
    }

    func testFailedStartVerification() throws {
        throw XCTSkip("disabled")
        // interactor.shouldSucceed = false
        // view.didCallShowLoadingViewExpectation = expectation(description: "Loading view shown")
        // view.didCallHideLoadingViewExpectation = expectation(description: "Loading view hidden")
        // view.didCallShowErrorExpectation = expectation(description: "Error displayed when verification fails")
        // presenter.startVerification(number: "1234567890")
        // waitForExpectations(timeout: 0.1)
    }
}
