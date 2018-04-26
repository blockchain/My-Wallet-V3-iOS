//
//  CheckForUnusedAddressTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class CheckForUnusedAddressTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCheckForUnusedAddressWithUnusedAddress() {
        let testBundle = Bundle(for: type(of: self))
        if let path = testBundle.url(forResource: "sample-unused-address", withExtension: "json") {
            do {
                let data = try Data(contentsOf: path, options: .mappedIfSafe)
                let json  = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
                if let txs = json!["txs"] as? [NSDictionary] {
                    let isUnused = txs.count == 0
                    XCTAssertTrue(isUnused, "Expected to get true, but got \(isUnused)")
                }
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        } else {
            XCTFail("Unable to load mock json file.")
        }
    }
}
