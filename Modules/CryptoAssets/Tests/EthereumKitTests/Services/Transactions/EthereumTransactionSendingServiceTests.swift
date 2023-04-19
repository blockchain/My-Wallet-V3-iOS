// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
@testable import EthereumKit
@testable import EthereumKitMock
@testable import PlatformKit
import TestKit
import XCTest

// swiftlint:disable all
final class EthereumTransactionSendingServiceTests: XCTestCase {

    var client: TransactionPushClientAPIMock!
    var subject: EthereumTransactionSendingService!

    override func setUp() {
        super.setUp()
        client = TransactionPushClientAPIMock()
        let pushService = EthereumTransactionPushService(client: client)
        let transactionSigner = EthereumTransactionSigningService(
            transactionSigner: EthereumSigner()
        )
        subject = EthereumTransactionSendingService(
            pushService: pushService,
            transactionSigner: transactionSigner
        )
    }

    override func tearDown() {
        client = nil
        subject = nil
        super.tearDown()
    }

    func test_send() throws {
        let rawTransaction = "0xf8640985028fa6ae00825208943535353535353535353535353535353535353535018026a059cd94b103938e5a072957427a72536a255bb48f5a5d2928631793e616d13823a024538cf2a58f0e3b54436a59b001e87a54f98a9dbfc2483a311762fc6bc4ea9d"
        let transactionHash = "0x3a69218edf483724d398223eab78fa4de66df7aa737f137f2914fc371506af90"

        let finalised = EthereumTransactionEncoded(encodedTransaction: Data(hex: rawTransaction))

        XCTAssertEqual(finalised.transactionHash, transactionHash)
        XCTAssertEqual(finalised.rawTransaction, rawTransaction)

        let expectedPublished = EthereumTransactionPublished(transactionHash: finalised.transactionHash)

        client.pushTransactionResult = .just(
            EthereumPushTxResponse(txHash: expectedPublished.transactionHash)
        )

        let result = try subject
            .signAndSend(
                transaction: .defaultMock,
                keyPair: MockEthereumWalletTestData.keyPair,
                network: .ethereum
            )
            .wait()

        XCTAssertEqual(result, expectedPublished)
    }
}
