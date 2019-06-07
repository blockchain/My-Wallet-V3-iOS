//
//  EthereumTransactionSendingServiceTests.swift
//  EthereumKitTests
//
//  Created by Jack on 30/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import BigInt
import PlatformKit
@testable import EthereumKit

class EthereumTransactionSendingServiceTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var bridge: EthereumWalletBridgeMock!
    var ethereumAPIClient: EthereumAPIClientMock!
    var feeService: EthereumFeeServiceMock!
    
    var transactionBuilder: EthereumTransactionBuilder!
    var transactionSigner: EthereumTransactionSigner!
    var transactionEncoder: EthereumTransactionEncoder!
    
    var subject: EthereumTransactionSendingService!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()

        bridge = EthereumWalletBridgeMock()
        ethereumAPIClient = EthereumAPIClientMock()
        feeService = EthereumFeeServiceMock()
        
        transactionBuilder = EthereumTransactionBuilder.shared
        transactionSigner = EthereumTransactionSigner.shared
        transactionEncoder = EthereumTransactionEncoder.shared
        
        subject = EthereumTransactionSendingService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            transactionBuilder: transactionBuilder,
            transactionSigner: transactionSigner,
            transactionEncoder: transactionEncoder
        )
    }
    
    override func tearDown() {
        
        subject = nil
        
        super.tearDown()
    }
    
    func test_send() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder().build()!
        
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!
        
        ethereumAPIClient.pushTransactionValue = Single.just(
            EthereumPushTxResponse(txHash: expectedPublished.transactionHash)
        )
        
        let keyPair = MockEthereumWalletTestData.keyPair
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate, keyPair: keyPair)
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
