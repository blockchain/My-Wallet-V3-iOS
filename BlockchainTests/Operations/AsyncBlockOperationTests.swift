//
//  AsyncBlockOperationTests.swift
//  BlockchainTests
//
//  Created by Alex McGregor on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class AsyncBlockOperationTests: XCTestCase {
    
    func testCompletionBlockFulfillment() {
        let exp = expectation(description: String(describing: self))
        let operation = AsyncBlockOperation { done in
            done()
        }
        operation.addCompletionBlock {
            exp.fulfill()
        }
        operation.start()
        waitForExpectations(timeout: 5)
    }
    
    func testMarkingAsComplete() {
        let exp = expectation(description: String(describing: self))
        var results: [String] = ["begin"]
        let asyncOperation = AsyncBlockOperation { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                results.append("async_complete")
                done()
            }
        }
        let blockOperation = BlockOperation {
            results.append("sync_complete")
            XCTAssertEqual(["begin", "async_complete", "sync_complete"], results)
            exp.fulfill()
        }
        blockOperation.addDependency(asyncOperation)
        let queue = OperationQueue()
        queue.addOperations([asyncOperation, blockOperation], waitUntilFinished: false)
        waitForExpectations(timeout: 5)
    }
    
}
