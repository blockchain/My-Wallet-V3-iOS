//
//  AuthenticationManagerTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class AuthenticationManagerTests: XCTestCase {

    private var mockWallet: MockWallet!
    private var authenticationManager: AuthenticationManager!

    override func setUp() {
        super.setUp()
        mockWallet = MockWallet()!
        let walletManager = WalletManager(wallet: mockWallet)
        authenticationManager = AuthenticationManager(walletManager: walletManager)
    }

    /// Tests that authenticating with an empty password will invoke an error in the provided handler
    func testAuthWithEmptyPasswordFails() {
        let payload = PasscodePayload(guid: "", password: "", sharedKey: "")

        let authResultExpectation = expectation(
            description: "Authentication should fail on invalid password."
        )

        testAuthFails(
            withPasscodePayload: payload,
            expectedErrorCode: AuthenticationError.ErrorCode.noPassword.rawValue,
            authResultExpectation: authResultExpectation
        )
    }

    /// Tests that authenticating with an invalid guid fails
    func testAuthFailsWithInvalidGuid() {
        let payload = PasscodePayload(
            guid: "invalid",
            password: "sometValidPassword123!",
            sharedKey: ""
        )

        let authResultExpectation = expectation(
            description: "Authentication should fail on invalid GUID."
        )

        testAuthFails(
            withPasscodePayload: payload,
            expectedErrorCode: AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue,
            authResultExpectation: authResultExpectation
        )
    }

    /// Tests that authenticating with an invalid sharedKey fails
    func testAuthFailsWithInvalidSharedKey() {
        let payload = PasscodePayload(
            guid: "asdfadsfasdfadsfasdfadsfasdfadsfasdf",
            password: "sometValidPassword123!",
            sharedKey: "invalid"
        )

        let authResultExpectation = expectation(
            description: "Authentication should fail on invalid sharedKey."
        )

        testAuthFails(
            withPasscodePayload: payload,
            expectedErrorCode: AuthenticationError.ErrorCode.invalidSharedKey.rawValue,
            authResultExpectation: authResultExpectation
        )
    }

    /// Tests that authenticating with a valid password suceeds
    func testAuthWithValidPasswordSucceeds() {
        let payload = PasscodePayload(
            guid: "asdfadsfasdfadsfasdfadsfasdfadsfasdf",
            password: "sometValidPassword123!",
            sharedKey: "asdfadsfasdfadsfasdfadsfasdfadsfasdf"
        )

        mockWallet.guid = payload.guid
        mockWallet.password = payload.password
        mockWallet.sharedKey = payload.guid

        let authResultExpectation = expectation(
            description: "Authentication should suceed."
        )

        authenticationManager.authenticate(using: payload) { isAuthenticated, _, error in
            XCTAssertTrue(isAuthenticated)
            XCTAssertNil(error)
            authResultExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations fail: \(error.localizedDescription)")
            }
        }
    }

    private func testAuthFails(
        withPasscodePayload passcodePayload: PasscodePayload,
        expectedErrorCode: Int,
        authResultExpectation: XCTestExpectation
    ) {
        mockWallet.guid = passcodePayload.guid
        mockWallet.password = passcodePayload.password
        mockWallet.sharedKey = passcodePayload.sharedKey

        authenticationManager.authenticate(using: passcodePayload) { isAuthenticated, _, error in
            XCTAssertFalse(isAuthenticated)
            XCTAssertNotNil(error)
            XCTAssertEqual(expectedErrorCode, error!.code)
            authResultExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations fail: \(error.localizedDescription)")
            }
        }
    }
}
