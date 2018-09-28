//
//  MockSocketManager.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 9/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class MockSocketManager: SocketManager {

    var didCallSetup: XCTestExpectation?
    var didCallDisconnect: XCTestExpectation?

    override func setupSocket(socketType: SocketType, url: URL) {
        didCallSetup?.fulfill()
    }

    override func disconnect(socketType: SocketType) {
        didCallDisconnect?.fulfill()
    }

}
