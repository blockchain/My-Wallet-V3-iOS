//
//  WalletServiceTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain
@testable import RxBlocking

class WalletServiceTests: XCTestCase {

    private var mockNetworkManager: MockNetworkManager!
    private var walletService: WalletService!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        walletService = WalletService(networkManager: mockNetworkManager)
    }

    func testPinMaintenanceModeResponse() {
        mockNetworkManager.mockRequestJsonOrStringResponse(
            (mockNetworkManager.mockHTTPURLResponse(statusCode: 200), "Site is in Maintenance mode")
        )
        XCTAssertThrowsError(
            try walletService.validatePin(PinPayload(pinCode: "1111", pinKey: "pinKey")
        ).toBlocking().first()) { error in
            XCTAssertTrue(error is WalletServiceError)
        }
    }

    func testPinTimeoutRequestResponse() {
        mockNetworkManager.mockRequestJsonOrStringResponse(
            (mockNetworkManager.mockHTTPURLResponse(statusCode: 504), "timeout request")
        )
        XCTAssertThrowsError(
            try walletService.validatePin(PinPayload(pinCode: "1111", pinKey: "pinKey"))
                .toBlocking()
                .first()
        ) { error in
            XCTAssertTrue(error is WalletServiceError)
        }
    }

    func testPinValid() {
        let mockResult: [String: Any] = [
            "success": "asdfasdf",
            "code": 0
        ]
        mockNetworkManager.mockRequestJsonOrStringResponse(
            (mockNetworkManager.mockHTTPURLResponse(statusCode: 200), mockResult)
        )
        let response = try? walletService.validatePin(PinPayload(pinCode: "4444", pinKey: "pinKey")).toBlocking().first()!
        XCTAssertEqual(0, response!.code!)
        XCTAssertEqual(mockResult["success"] as! String, response!.pinDecryptionValue!)
    }

    func testPinInvalid() {
        let mockResult: [String: Any] = [
            "code": 2,
            "error": "Incorrect PIN. 3 Attempts Left"
        ]
        mockNetworkManager.mockRequestJsonOrStringResponse(
            (mockNetworkManager.mockHTTPURLResponse(statusCode: 200), mockResult)
        )
        let response = try? walletService.validatePin(PinPayload(pinCode: "4433", pinKey: "pinKey")).toBlocking().first()!
        XCTAssertEqual(mockResult["code"] as! Int, response!.code!)
        XCTAssertEqual(mockResult["error"] as! String, response!.error!)
    }
}
