//
//  MarketsServiceTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 9/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class MarketsServiceTests: XCTestCase {

    private var socketManager: MockSocketManager!

    override func setUp() {
        super.setUp()
        socketManager = MockSocketManager()
    }

    /// Tests that the websocket is disconnected when MarketsService is dealloc'd
    func testWebsocketDisconnectOnDeinit() {
        var marketsService: MarketsService? = MarketsService(socketManager: socketManager)

        socketManager.didCallSetup = expectation(description: "Set up called.")
        marketsService?.setup()

        socketManager.didCallDisconnect = expectation(description: "WS disconnected.")
        marketsService = nil

        waitForExpectations(timeout: 0.1)
    }

}
