// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
@testable import PlatformKit
import XCTest

class SecureChannelMessageServiceTests: XCTestCase {
    var sut: SecureChannelMessageService!

    override func setUp() {
        super.setUp()
        sut = SecureChannelMessageService()
    }

    enum TestData {
        static let channelID = "ee92bd77-6c3b-4ad2-82e2-61b90f764273"
        static let deviceKey = Data(hex: "fd4041852e9fbe31cc0a81fbb5750e33eba20e7a25058274c7b57a28daeba84a")
        static let publicKey = Data(hex: "0204a157928751500c12388d8995b7914b32901979be499602638e6133b64746f9")
    }

    func testBuildingMessage() throws {
        let messageData = Data(hex: "7b227368617265644b6579223a2262653234343236352d323161662d343231392d623532352d316464666563383837373562222c2270617373776f7264223a227365637572656368616e6e656c222c2272656d656d626572223a747275652c2274797065223a226c6f67696e5f77616c6c6574222c2267756964223a2232343764623633642d323365622d346133332d393736642d613861626139643837333238227d")
        let result = sut.buildMessage(
            data: messageData,
            channelId: TestData.channelID,
            success: true,
            publicKey: TestData.publicKey,
            deviceKey: TestData.deviceKey
        )
        let response = try result.get()
        XCTAssertEqual(response.channelId, TestData.channelID)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.pubkey, "03acd773753c791ec5823f66e4a08fa34c530f26f24650d1ebda5b4c27d3d6e760")

        let channelKey = try ECDH.derive(priv: TestData.deviceKey, pub: TestData.publicKey).get()
        let decrypted = try ECDH.decrypt(priv: channelKey, payload: Data(hex: response.message)).get()
        XCTAssertEqual(messageData, decrypted)
    }

    func testMessageDecryption() throws {
        let message = "2c9dfbc775ec1c7417f2748708123bf815f8a15ea1e5f93b60df14c97b6684f37c009640c6b24ad2692c2308314e2dcd40c5bf2d2182a2cd7d2c9bbbe92446f20abe3ce80c23a12316c8805b189a1fa6eca03ed7515e0b4ac6686a7a877c0bc9436b3d4c9820f3f9dbb5e2c852dd348c76f5848e3d73b559f166502d605f45d5"

        let response = try sut.decryptMessage(message, publicKey: TestData.publicKey, deviceKey: TestData.deviceKey).get()
        XCTAssertEqual(response.type, "login_wallet")
        XCTAssertEqual(response.channelId, "ee92bd77-6c3b-4ad2-82e2-61b90f764273")
        XCTAssertEqual(response.timestamp, 1621515696636)
    }
}
