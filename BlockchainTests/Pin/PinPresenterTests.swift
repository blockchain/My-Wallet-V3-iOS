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

    private var wallet: MockWallet!
    private var pinView: MockPinView!
    private var interactor: MockPinInteractor!
    private var walletService: MockWalletService!
    private var presenter: PinPresenter!

    override func setUp() {
        super.setUp()
        wallet = MockWallet()
        pinView = MockPinView()
        walletService = MockWalletService()
        interactor = MockPinInteractor(walletService: walletService, wallet: wallet)
        presenter = PinPresenter(view: pinView, interactor: interactor, walletService: walletService)
    }

    // MARK: - Pin Change Flows

    /// Tests that an error is encountered when the user tries to change their pin but the pins don't match
    func testPinsDontMatch() {
        pinView.didCallErrorPinsDontMatch = expectation(
            description: "Error is called when pins don't match"
        )
        _ = presenter.validateConfirmPinForChangePin(pin: Pin(code: 5555), firstPin: Pin(code: 5552))
        waitForExpectations(timeout: 0.1)
    }

    /// Tests that entering a common pin during the change pin flow will show an error
    func testFirstEntryPinIsCommonError() {
        pinView.didCallAlertCommonPinExpectation = expectation(
            description: "Alert is presented to the user that the pin is too common."
        )
        presenter.validateFirstEntryForChangePin(pin: Pin(code: 1111), previousPin: Pin(code: 3456))
        waitForExpectations(timeout: 0.1)
    }

    /// Tests that entering a pin that is the same as the previous pin for the change pin flow will show an error
    func testFirstEntryPinSameAsPreviousError() {
        pinView.didCallErrorExpectation = expectation(
            description: "Error is called alerting the user that they need to pick a pin different from their previous one."
        )
        presenter.validateFirstEntryForChangePin(pin: Pin(code: 3456), previousPin: Pin(code: 3456))
        waitForExpectations(timeout: 0.1)
    }

    /// Tests that entering a valid pin for the change pin flow will succeeded
    func testFirstEntryPinValid() {
        pinView.didCallSuccessFirstEntryForChangePin = expectation(
            description: "A valid pin should succeed during the change pin flow"
        )
        presenter.validateFirstEntryForChangePin(pin: Pin(code: 5555), previousPin: Pin(code: 5554))
        waitForExpectations(timeout: 0.1)
    }

    /// Tests that an error from the server during the pin creation flow will present an error to the user
    func testInvalidServerResponse() {
        wallet.password = "password"
        walletService.mockCreatePinResponse = Single.just(
            PinStoreResponse(
                code: PinStoreResponse.StatusCode.success.rawValue,
                error: "Error",
                pinDecryptionValue: "decrypt",
                key: "key",
                value: "value"
            )
        )
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallHideLoadingViewExpectation = expectation(description: "Hide load view called.")
        pinView.didCallErrorExpectation = expectation(description: "Did call error.")
        _ = presenter.validateConfirmPinForChangePin(pin: Pin(code: 2222), firstPin: Pin(code: 2222))
        waitForExpectations(timeout: 1)
    }

    /// Tests that a valid response from the pin store flow will succeed
    func testCreatePinSuccess() {
        wallet.password = "password"
        walletService.mockCreatePinResponse = Single.just(
            PinStoreResponse(
                code: PinStoreResponse.StatusCode.success.rawValue,
                error: nil,
                pinDecryptionValue: "decrypt",
                key: "key",
                value: "value"
            )
        )
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallHideLoadingViewExpectation = expectation(description: "Hide load view called.")
        pinView.didCallSuccessPinCreatedOrChanged = expectation(description: "Did call success.")
        _ = presenter.validateConfirmPinForChangePin(pin: Pin(code: 2222), firstPin: Pin(code: 2222))
        waitForExpectations(timeout: 1)
    }

    // MARK: - Pin Validation Flows

    func testMaintenance() {
        let maintenanceMessage = "Site is down."
        walletService.mockWalletOptions = WalletOptions(json: [
            "maintenance": true,
            "mobileInfo": [
                "en": maintenanceMessage
            ]
        ])
        interactor.mockValidatePinResponse = Single.just(
            PinStoreResponse(
                code: PinStoreResponse.StatusCode.success.rawValue,
                error: nil,
                pinDecryptionValue: "success",
                key: nil,
                value: nil
            )
        )
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallErrorExpectation = expectation(description: "Did call error.")
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }

    func testIncorrectPin() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallErrorExpectation = expectation(description: "Did call error.")
        interactor.mockValidatePinResponse = Single.just(
            PinStoreResponse(
                code: PinStoreResponse.StatusCode.incorrect.rawValue,
                error: "incorrect",
                pinDecryptionValue: nil,
                key: nil,
                value: nil
            )
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }

    func testPinDecryptionEmpty() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallErrorExpectation = expectation(description: "Did call error.")
        interactor.mockValidatePinResponse = Single.just(
            PinStoreResponse(
                code: PinStoreResponse.StatusCode.success.rawValue,
                error: "incorrect",
                pinDecryptionValue: "",
                key: nil,
                value: nil
            )
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }

    func testMaxRetryPin() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallErrorPinRetryExceededExpectation = expectation(description: "Did max retry limit error.")
        interactor.mockValidatePinResponse = Single.just(
            PinStoreResponse(
                code: PinStoreResponse.StatusCode.deleted.rawValue,
                error: "incorrect",
                pinDecryptionValue: nil,
                key: nil,
                value: nil
            )
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }

    func testValidPin() {
        pinView.didCallShowLoadingViewExpectation = expectation(description: "Show loading view called.")
        pinView.didCallSuccessPinValidExpectation = expectation(description: "Valid pin.")
        interactor.mockValidatePinResponse = Single.just(
            PinStoreResponse(
                code: PinStoreResponse.StatusCode.success.rawValue,
                error: nil,
                pinDecryptionValue: "success",
                key: nil,
                value: nil
            )
        )
        _ = presenter.validatePin(PinPayload(pinCode: "1111", pinKey: "asdf"))
        waitForExpectations(timeout: 1)
    }
}
