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
        let payload = PushNotificationAuthPayload(guid: "", sharedKey: "", deviceToken: "")
        let result = BlockchainAPI.registerDeviceForPushNotifications(using: payload)
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(result!)")
    }

    func testRegisterDeviceForPushNotificationsPayloadWithEmptyGuid() {
        let payload = PushNotificationAuthPayload(guid: "", sharedKey: sharedKey, deviceToken: deviceToken)
        let result = BlockchainAPI.registerDeviceForPushNotifications(using: payload)
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(result!)")
    }

    func testRegisterDeviceForPushNotificationsPayloadWithEmptySharedKey() {
        let payload = PushNotificationAuthPayload(guid: guid, sharedKey: "", deviceToken: deviceToken)
        let result = BlockchainAPI.registerDeviceForPushNotifications(using: payload)
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(result!)")
    }

    func testRegisterDeviceForPushNotificationsPayloadWithEmptyDeviceToken() {
        let payload = PushNotificationAuthPayload(guid: guid, sharedKey: sharedKey, deviceToken: "")
        let result = BlockchainAPI.registerDeviceForPushNotifications(using: payload)
        XCTAssertNil(payload, "Expected the payload to be nil, but got \(result!)")
    }

    func testRegisterDeviceForPushNotificationsPayload() {
        let payload = PushNotificationAuthPayload(guid: guid, sharedKey: sharedKey, deviceToken: deviceToken)
        let result = BlockchainAPI.registerDeviceForPushNotifications(using: payload)
        XCTAssertNotNil(payload, "Expected payload to have a value, but instead got \(result!).")
    }
}
