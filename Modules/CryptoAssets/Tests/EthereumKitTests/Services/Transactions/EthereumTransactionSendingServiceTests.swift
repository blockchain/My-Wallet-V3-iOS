// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
@testable import EthereumKitMock
@testable import PlatformKit
import RxSwift
import RxTest
import XCTest

// swiftlint:disable all
class EthereumTransactionSendingServiceTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    var client: TransactionPushClientAPIMock!
    var subject: EthereumTransactionSendingService!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
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
        scheduler = nil
        disposeBag = nil
        client = nil
        subject = nil
        super.tearDown()
    }

    func test_send() {
        let rawTransaction = "0xf8640985028fa6ae00825208943535353535353535353535353535353535353535018026a059cd94b103938e5a072957427a72536a255bb48f5a5d2928631793e616d13823a024538cf2a58f0e3b54436a59b001e87a54f98a9dbfc2483a311762fc6bc4ea9d"
        let transactionHash = "0x3a69218edf483724d398223eab78fa4de66df7aa737f137f2914fc371506af90"

        let finalised = EthereumTransactionEncoded(encodedTransaction: Data(hex: rawTransaction))

        XCTAssertEqual(finalised.transactionHash, transactionHash)
        XCTAssertEqual(finalised.rawTransaction, rawTransaction)

        let expectedPublished = EthereumTransactionPublished(transactionHash: finalised.transactionHash)

        client.pushTransactionResult = .just(
            EthereumPushTxResponse(txHash: expectedPublished.transactionHash)
        )

        let keyPair = MockEthereumWalletTestData.keyPair

        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .signAndSend(
                transaction: .defaultMock,
                keyPair: keyPair,
                network: .ethereum
            )
            .asObservable()

        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .next(
                200,
                expectedPublished
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
