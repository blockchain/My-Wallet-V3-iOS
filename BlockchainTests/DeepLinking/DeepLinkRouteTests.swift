//
//  DeepLinkRouteTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import XCTest

class DeepLinkRouteTests: XCTestCase {

    func testAirdropUrl() {
        let url = URL(string: "https://login.blockchain.com/#/open/referral?campaign=sunriver")!
        let route = DeepLinkRoute.route(from: url)
        XCTAssertNotNil(route)
        XCTAssertEqual(DeepLinkRoute.xlmAirdop, route)
    }

    func testAirdropUrlWithExtraParams() {
        let url = URL(string: "https://login.blockchain.com/#/open/referral?campaign=sunriver&something=else")!
        let route = DeepLinkRoute.route(from: url)
        XCTAssertNotNil(route)
        XCTAssertEqual(DeepLinkRoute.xlmAirdop, route)
    }

    func testInvalidPath() {
        let url = URL(string: "https://login.blockchain.com/#/open/notasupportedurl")!
        let route = DeepLinkRoute.route(from: url)
        XCTAssertNil(route)
    }
}
