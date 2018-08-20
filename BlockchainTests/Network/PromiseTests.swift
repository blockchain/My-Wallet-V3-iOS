//
//  PromiseTests.swift
//  BlockchainTests
//
//  Created by Justin on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import XCTest

class CompletableFutureTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSingleBlockResponse() {
        let testValue = NSNumber(value: 42)
        let testFuture = CompletableFuture<NSNumber>()
        let triggerPeriod = TimeInterval(0.1)
        
        let completeExpectation = expectation(description: "Completion triggered")
        testFuture.then { (givenValue : NSNumber) in
            XCTAssertEqual(testValue, givenValue, "Given Value does not equal test value")
            completeExpectation.fulfill()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + triggerPeriod) {
            testFuture.complete(value: testValue)
        }
        waitForExpectations(timeout: triggerPeriod * 2, handler: nil)
    }
    
    func testTwoBlockResponse() {
        let testValue = NSNumber(value: 42)
        let testFuture = CompletableFuture<NSNumber>()
        let triggerPeriod = TimeInterval(0.1)
        
        let completeExpectation1 = expectation(description: "Completion 1 triggered")
        testFuture.then { (givenValue : NSNumber) in
            XCTAssertEqual(testValue, givenValue, "Given Value does not equal test value")
            completeExpectation1.fulfill()
        }
        
        let completeExpectation2 = expectation(description: "Completion 2 triggered")
        testFuture.then { (givenValue: NSNumber) in
            XCTAssertEqual(testValue, givenValue, "Given Value does not equal test value")
            completeExpectation2.fulfill()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + triggerPeriod) {
            testFuture.complete(value: testValue)
        }
        waitForExpectations(timeout: triggerPeriod * 2, handler: nil)
    }
    
    func testCancel() {
        let testFuture = CompletableFuture<NSNumber>()
        let triggerPeriod = TimeInterval(0.1)
        
        let cancelCheckDone = expectation(description: "Cancellation check done")
        
        testFuture.then { (givenValue: NSNumber) in
            XCTFail("Completion shouldn't get called. givenValue: \(givenValue)")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + triggerPeriod) {
            testFuture.cancel()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + triggerPeriod * 2) {
            XCTAssertTrue(testFuture.canceled, "Cancellation failed")
            cancelCheckDone.fulfill()
        }
        
        waitForExpectations(timeout: triggerPeriod * 3, handler: nil)
    }
    
}
