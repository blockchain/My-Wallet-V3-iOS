//
//  BlockchainAPI+PayloadTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 5/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class BlockchainAPIPayloadTests: XCTestCase {

    let guid = "123-abc-456-def-789-ghi"
    let sharedKey = "0123456789"
    let deviceToken = "f16ff773-0cad-4788-a453-bd4b2bd33e17"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRegisterDeviceForPushNotificationsPayloadWithEmptyArguments() {
        let payload = BlockchainAPI.registerDeviceForPushNotificationsPayload("", "", "")
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(payload!)")
    }

    func testRegisterDeviceForPushNotificationsPayloadWithEmptyGuid() {
        let payload = BlockchainAPI.registerDeviceForPushNotificationsPayload("", sharedKey, deviceToken)
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(payload!)")
    }

    func testRegisterDeviceForPushNotificationsPayloadWithEmptySharedKey() {
        let payload = BlockchainAPI.registerDeviceForPushNotificationsPayload(guid, "", deviceToken)
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(payload!)")
    }

    func testRegisterDeviceForPushNotificationsPayloadWithEmptyDeviceToken() {
        let payload = BlockchainAPI.registerDeviceForPushNotificationsPayload(guid, sharedKey, "")
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(payload!)")
    }

    func testRegisterDeviceForPushNotificationsPayload() {
        let payload = BlockchainAPI.registerDeviceForPushNotificationsPayload(guid, sharedKey, deviceToken)
        XCTAssertNotNil(payload, "Expected payload to have a value, but instead got nil.")
    }
}
