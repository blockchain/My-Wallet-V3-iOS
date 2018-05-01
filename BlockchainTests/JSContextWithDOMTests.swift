//
//  JSContextWithDOMTests.swift
//  BlockchainTests
//
//  Created by kevinwu on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class JSContextWithDOMTests: XCTestCase {

    lazy var delay = 1500 // 1.5 seconds
    lazy var setTimeoutScript = "setTimeout(callback, \(delay))"
    lazy var setIntervalScript = "setInterval(callback, \(delay))"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func getClearTimeoutScript(identifier: String) -> String {
        return "clearTimeout('\(identifier)')"
    }

    func getClearIntervalScript(identifier: String) -> String {
        return "clearInterval('\(identifier)')"
    }

    func testSetTimeout() {
        let context = JSContextWithDOM()
        var called = false
        let block: @convention(block) () -> Void = { called = true }
        context.setObject(block, forKeyedSubscript: "callback" as NSString)
        context.evaluateScript(setTimeoutScript)

        // First check that a delay exists when calling setTimeout
        let delayExpectation = XCTestExpectation(description: "delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(called == false, "Callback should be delayed")
            delayExpectation.fulfill()
        }

        // Then check that the callback is invoked after 1.5 seconds
        let firstCallExpectation = XCTestExpectation(description: "firstCall")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(called == true, "Callback should have been invoked after delay")
            firstCallExpectation.fulfill()
            called = false
        }

        // Then check that the callback is not invoked again
        let noRepeatExpectation = XCTestExpectation(description: "noRepeat")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            XCTAssert(called == false, "Callback should not repeat")
            noRepeatExpectation.fulfill()
        }
        self.wait(for: [firstCallExpectation, noRepeatExpectation], timeout: 5)
    }

    func testSetInterval() {
        let context = JSContextWithDOM()
        var called = false
        let block: @convention(block) () -> Void = { called = true }
        context.setObject(block, forKeyedSubscript: "callback" as NSString)
        context.evaluateScript(setIntervalScript)

        // First check that a delay exists when calling setInterval
        let delayExpectation = XCTestExpectation(description: "delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(called == false, "Callback should be delayed")
            delayExpectation.fulfill()
        }

        // Then check that the callback is invoked after 1.5 seconds
        let firstCallExpectation = XCTestExpectation(description: "firstCall")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssert(called == true, "Callback should have been invoked after delay")
            firstCallExpectation.fulfill()
            called = false
        }

        // Then check that the callback is invoked again
        let repeatedCallExpectation = XCTestExpectation(description: "repeatedCall")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            XCTAssert(called == true, "Callback should repeat")
            repeatedCallExpectation.fulfill()
            called = false
        }
        self.wait(for: [firstCallExpectation, repeatedCallExpectation], timeout: 5)
    }

    func testClearTimeout() {
        let context = JSContextWithDOM()
        var called = false
        let block: @convention(block) () -> Void = { called = true }
        context.setObject(block, forKeyedSubscript: "callback" as NSString)
        guard let identifier = context.evaluateScript(setTimeoutScript).toString() else {
            XCTFail("Could not get timeout identifier")
            return
        }

        // Cancel timeout before it executes
        context.evaluateScript(self.getClearTimeoutScript(identifier: identifier))
        let cancelledTimeoutExpectation = XCTestExpectation(description: "cancelledTimeout")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(called == false, "Callback should have been cancelled")
            cancelledTimeoutExpectation.fulfill()
        }
        self.wait(for: [cancelledTimeoutExpectation], timeout: 5)
    }

    func testClearInterval() {
        let context = JSContextWithDOM()
        var called = false
        let block: @convention(block) () -> Void = { called = true }
        context.setObject(block, forKeyedSubscript: "callback" as NSString)
        guard let identifier = context.evaluateScript(setIntervalScript).toString() else {
            XCTFail("Could not get interval identifier")
            return
        }

        // Cancel interval before it executes
        context.evaluateScript(getClearIntervalScript(identifier: identifier))
        let cancelledIntervalExpectation = XCTestExpectation(description: "cancelledInterval")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssert(called == false, "Callback should have been cancelled")
            cancelledIntervalExpectation.fulfill()
        }
        self.wait(for: [cancelledIntervalExpectation], timeout: 5)
    }
}
