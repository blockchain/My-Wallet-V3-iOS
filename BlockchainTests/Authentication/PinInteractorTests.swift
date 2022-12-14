// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
@testable import FeatureAuthenticationData
@testable import FeaturePin
@testable import WalletPayloadDataKit
@testable import WalletPayloadKitMock

import Foundation
import PlatformKit
import RxBlocking
import RxSwift
import ToolKit
import WalletPayloadKit
import XCTest

/// Tests the pin interactor
class PinInteractorTests: XCTestCase {

    enum Operation {
        case creation
        case validation
    }

    var appSettings: MockBlockchainSettingsApp {
        MockBlockchainSettingsApp()
    }

    var mockChangePasswordService: MockChangePasswordService!

    var passwordRepository: PasswordRepository {
        let walletRepo = WalletRepo(initialState: .empty)
        walletRepo.set(keyPath: \.credentials.password, value: "blockchain")
        return PasswordRepository(
            walletRepo: walletRepo,
            changePasswordService: mockChangePasswordService
        )
    }

    override func setUp() {
        super.setUp()
        mockChangePasswordService = MockChangePasswordService()
    }

    // MARK: - Test success cases

    func testCreation() throws {
        try testPin(operation: .creation)
    }

    func testValidation() throws {
        try testPin(operation: .validation)
    }

    /// Tests PIN operation
    private func testPin(operation: Operation) throws {
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: MockPinClient(statusCode: .success),
            appSettings: appSettings
        )
        let payload = PinPayload(
            pinCode: "1234",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: false
        )
        switch operation {
        case .creation:
            _ = try interactor.create(using: payload).toBlocking().first()
        case .validation:
            _ = try interactor.validate(using: payload).toBlocking().first()
        }
    }

    // MARK: - Invalid Numerical Value

    func testInvalidPinValidation() throws {
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: MockPinClient(statusCode: nil, error: "Invalid Numerical Value"),
            appSettings: appSettings
        )
        let payload = PinPayload(
            pinCode: "0000",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: false
        )
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.invalid {
            XCTAssert(true)
        }
    }

    // MARK: - Incorrect PIN validation

    // Incorrect pin returns proper error
    func testIncorrectPinValidation() throws {
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: MockPinClient(
                statusCode: .incorrect,
                remaining: 0
            ),
            appSettings: appSettings
        )
        let payload = PinPayload(
            pinCode: "1234",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: false
        )
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.incorrectPin {
            XCTAssert(true)
        }
    }

    // Too many failed validation attempts
    func testTooManyFailedValidationAttempts() throws {
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: MockPinClient(statusCode: .deleted),
            appSettings: appSettings
        )
        let payload = PinPayload(
            pinCode: "1234",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: false
        )
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.tooManyAttempts {
            XCTAssert(true)
        }
    }

    // MARK: - Backoff Error

    // Backoff error is returned in the relevant case
    func testBackoffError() throws {
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: MockPinClient(
                statusCode: .backoff,
                remaining: 10
            ),
            appSettings: appSettings
        )
        let payload = PinPayload(
            pinCode: "1234",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: false
        )
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.backoff {
            XCTAssert(true)
        }
    }

    // Invalid status code in response should lead to an exception
    func testFailureOnInvalidStatusCode() throws {
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: MockPinClient(statusCode: nil),
            appSettings: appSettings
        )
        let payload = PinPayload(
            pinCode: "1234",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: false
        )
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch {
            XCTAssert(true)
        }
    }

    // Tests the the pin is persisted no app-settings object after validating payload
    func testPersistingPinAfterValidation() throws {
        let settings = MockBlockchainSettingsApp()
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: MockPinClient(statusCode: .success),
            appSettings: settings
        )
        let payload = PinPayload(
            pinCode: "1234",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: true
        )
        _ = try interactor.validate(using: payload).toBlocking().first()
        XCTAssertNotNil(settings.pin)
        XCTAssertNotNil(settings.biometryEnabled)
    }

    // Test that an error is thrown in case the server returns an error
    func testServerErrorWhileCreatingPin() throws {
        struct ServerError: Error {}
        let pinClient = MockPinClient(statusCode: .success, error: "server error")
        let interactor = PinInteractor(
            passwordRepository: passwordRepository,
            pinClient: pinClient,
            appSettings: appSettings
        )
        let payload = PinPayload(
            pinCode: "1234",
            keyPair: try .generateNewKeyPair(),
            persistsLocally: true
        )
        do {
            _ = try interactor.create(using: payload).toBlocking().first()
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }
}
