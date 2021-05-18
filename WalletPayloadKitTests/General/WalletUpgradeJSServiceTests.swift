//
//  WalletUpgradeJSServiceTests.swift
//  WalletPayloadKitTests
//
//  Created by Paulo on 18/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import WalletPayloadKit
import JavaScriptCore
import RxSwift
import RxTest
import ToolKit
import XCTest

class WalletUpgradeJSServiceTests: XCTestCase {

    var scheduler: TestScheduler!
    var contextProvider: MockContextProvider!
    var sut: WalletUpgradeJSServicing!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        contextProvider = MockContextProvider()
        sut = WalletUpgradeJSService(contextProvider: contextProvider)
    }

    override func tearDown() {
        scheduler = nil
        sut = nil
        contextProvider = nil
        super.tearDown()
    }

    private func newContext(script: String) -> JSContext {
        let context = JSContext()
        context?.evaluateScript(script)
        return context!
    }

    private var successScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_success();
        };
        """
    }
    private var multipleSuccessScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_success();
            objc_upgrade_V3_success();
        };
        """
    }
    private var successErrorScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_success();
            objc_upgrade_V3_error();
        };
        """
    }
    private var failureScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_error();
        };
        """
    }

    func testSuccess() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: successScript)
        let expectedString = "V3"
        let upgradeObservable = sut.upgradeToV3().asObservable()

        // Act
        let result: TestableObserver<String> = scheduler
            .start { upgradeObservable }

        // Assert
        let expectedEvents: [Recorded<Event<String>>] = Recorded.events(
            .next(
                200,
                expectedString
            ),
            .completed(200)
        )
        XCTAssertEqual(result.events, expectedEvents)
    }

    func testSuccessIsInvokedOnlyOnce() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: multipleSuccessScript)
        let expectedString = "V3"
        let upgradeObservable = sut.upgradeToV3().asObservable()

        // Act
        let result: TestableObserver<String> = scheduler
            .start { upgradeObservable }

        // Assert
        let expectedEvents: [Recorded<Event<String>>] = Recorded.events(
            .next(
                200,
                expectedString
            ),
            .completed(200)
        )
        XCTAssertEqual(result.events, expectedEvents)
    }

    func testCompletesAfterFirstSuccess() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: successErrorScript)
        let expectedString = "V3"
        let upgradeObservable = sut.upgradeToV3().asObservable()

        // Act
        let result: TestableObserver<String> = scheduler
            .start { upgradeObservable }

        // Assert
        let expectedEvents: [Recorded<Event<String>>] = Recorded.events(
            .next(
                200,
                expectedString
            ),
            .completed(200)
        )
        XCTAssertEqual(result.events, expectedEvents)
    }

    func testError() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: failureScript)
        let upgradeObservable = sut.upgradeToV3().asObservable()

        // Act
        let result: TestableObserver<String> = scheduler
            .start { upgradeObservable }

        // Assert
        let expectedEvents: [Recorded<Event<String>>] = Recorded.events(
            .error(
                200,
                   WalletUpgradeJSError.failedV3Upgrade
            )
        )
        XCTAssertEqual(result.events, expectedEvents)
    }
}
