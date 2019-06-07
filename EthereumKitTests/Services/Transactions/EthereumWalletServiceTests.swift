//
//  EthereumWalletServiceTests.swift
//  EthereumKitTests
//
//  Created by Jack on 10/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import BigInt
import web3swift
import PlatformKit
@testable import EthereumKit

class EthereumWalletServiceTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var bridge: EthereumWalletBridgeMock!
    var ethereumAPIClient: EthereumAPIClientMock!
    var feeService: EthereumFeeServiceMock!
    
    var transactionBuilder: EthereumTransactionBuilder!
    var transactionSigner: EthereumTransactionSignerAPI!
    var transactionEncoder: EthereumTransactionEncoder!
    
    var walletAccountRepository: EthereumWalletAccountRepositoryMock!
    
    var transactionBuildingService: EthereumTransactionBuildingService!
    
    var transactionSendingService: EthereumTransactionSendingService!
    
    var subject: EthereumWalletService!
    
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
        
        walletAccountRepository = EthereumWalletAccountRepositoryMock()
        
        transactionSendingService = EthereumTransactionSendingService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            transactionBuilder: transactionBuilder,
            transactionSigner: transactionSigner,
            transactionEncoder: transactionEncoder
        )

        transactionBuildingService = EthereumTransactionBuildingService(
            with: bridge,
            feeService: feeService
        )
        
        subject = EthereumWalletService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            walletAccountRepository: walletAccountRepository,
            transactionBuildingService: transactionBuildingService,
            transactionSendingService: transactionSendingService
        )
    }
    
    override func tearDown() {
        
        scheduler = nil
        disposeBag = nil
        
        bridge = nil
        ethereumAPIClient = nil
        feeService = nil
        
        transactionBuilder = nil
        transactionSigner = nil
        transactionEncoder = nil
        
        walletAccountRepository = nil
        
        transactionSendingService = nil
        
        subject = nil
        
        super.tearDown()
    }
    
    func test_send_successfully() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder().build()!
        let expectedFinalised = EthereumTransactionFinalisedBuilder()
            .with(candidate: candidate)
            .build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!

        bridge.recordLastTransactionValue = Single.just(expectedPublished)
        ethereumAPIClient.pushTransactionValue = Single.just(EthereumPushTxResponse(txHash: expectedPublished.transactionHash))
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
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
        XCTAssertNotNil(bridge.lastRecordedTransaction)
        guard let lastRecordedTransaction = bridge.lastRecordedTransaction else {
            XCTFail("Failed to record transaction")
            return
        }
        XCTAssertEqual(lastRecordedTransaction, expectedPublished)
        
        XCTAssertNotNil(ethereumAPIClient.lastPushedTransaction)
        guard let lastPushedTransaction = ethereumAPIClient.lastPushedTransaction else {
            XCTFail("Should have successfully pushed the finalised transaction")
            return
        }
        XCTAssertEqual(lastPushedTransaction, expectedFinalised)
    }
    
    func test_send_transaction_pending() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder().build()!
        
        bridge.isWaitingOnEtherTransactionValue = Single.just(true)
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumWalletServiceError.waitingOnPendingTransaction)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_building_amount_over_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.etherFromMajor(decimal: Decimal(1.0))
        let ethereumValue = try EthereumValue(crypto: cryptoValue)
        let toAddress = EthereumAddress(
            rawValue: MockEthereumWalletTestData.Transaction.to
        )!

        bridge.balanceValue = Single.just(CryptoValue.etherFromMajor(decimal: Decimal(0.1)))

        let buildObservable: Observable<EthereumTransactionCandidate> = subject
            .buildTransaction(with: ethereumValue, to: toAddress)
            .asObservable()

        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { buildObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, EthereumTransactionBuilderError.insufficientFunds)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_sending_fees_over_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.etherFromMajor(decimal: Decimal(0.01))
        let ethereumValue = try EthereumValue(crypto: cryptoValue)
        let toAddress = EthereumAddress(
            rawValue: MockEthereumWalletTestData.Transaction.to
        )!
        
        let limits = TransactionFeeLimits(
            min: 100,
            max: 1_100
        )
        let fee = EthereumTransactionFee(
            limits: limits,
            regular: 1_000,
            priority: 1_000,
            gasLimit: Int(MockEthereumWalletTestData.Transaction.gasLimit),
            gasLimitContract: Int(MockEthereumWalletTestData.Transaction.gasLimitContract)
        )
        feeService.feesValue = Single.just(fee)
        bridge.balanceValue = Single.just(CryptoValue.etherFromMajor(decimal: Decimal(0.02)))

        let buildObservable: Observable<EthereumTransactionCandidate> = subject
            .buildTransaction(with: ethereumValue, to: toAddress)
            .asObservable()

        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { buildObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, EthereumTransactionBuilderError.insufficientFunds)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_signing_error() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(value: BigUInt(0.01))
            .build()!
        let expectedCandidateCosted = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate)
            .build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!

        let transactionSignerMock = EthereumTransactionSignerMock()
        transactionSigner = transactionSignerMock
        
        transactionSendingService = EthereumTransactionSendingService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            transactionBuilder: transactionBuilder,
            transactionSigner: transactionSigner,
            transactionEncoder: transactionEncoder
        )
        
        subject = EthereumWalletService(
            with: bridge,
            ethereumAPIClient: ethereumAPIClient,
            feeService: feeService,
            walletAccountRepository: walletAccountRepository,
            transactionBuildingService: transactionBuildingService,
            transactionSendingService: transactionSendingService
        )
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumTransactionSignerError.incorrectChainId)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
        
        XCTAssertNotNil(transactionSignerMock.lastKeyPair)
        XCTAssertNotNil(transactionSignerMock.lastTransactionForSignature)
        
        guard let lastKeyPair = transactionSignerMock.lastKeyPair else {
            XCTFail("Should have attempted to sign using the correct keyPair")
            return
        }
        XCTAssertEqual(lastKeyPair, MockEthereumWalletTestData.keyPair)
        
        guard let lastTransactionForSignature = transactionSignerMock.lastTransactionForSignature else {
            XCTFail("Should have attempted to sign using the correct transaction")
            return
        }
        XCTAssertEqual(lastTransactionForSignature, expectedCandidateCosted)
    }
    
    func test_failed_to_publish_transaction() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(value: 1)
            .build()!
        
        ethereumAPIClient.pushTransactionValue = Single.error(EthereumAPIClientMockError.mockError)
        
        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumAPIClientMockError.mockError)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_failed_to_record_transaction() {
        // Arrange
        let candidate = EthereumTransactionCandidateBuilder()
            .with(value: 1)
            .build()!
        let expectedPublished = EthereumTransactionPublishedBuilder()
            .with(candidate: candidate)
            .build()!
        
        ethereumAPIClient.pushTransactionValue = Single.just(EthereumPushTxResponse(txHash: expectedPublished.transactionHash))
        bridge.recordLastTransactionValue = Single.error(EthereumWalletBridgeMockError.mockError)

        let sendObservable: Observable<EthereumTransactionPublished> = subject
            .send(transaction: candidate)
            .asObservable()

        // Act
        let result: TestableObserver<EthereumTransactionPublished> = scheduler
            .start { sendObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionPublished>>] = Recorded.events(
            .error(200, EthereumWalletBridgeMockError.mockError)
        )

        XCTAssertEqual(result.events, expectedEvents)
        XCTAssertEqual(bridge.lastRecordedTransaction, expectedPublished)
    }
    
    func test_failed_to_fetch_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.etherFromMajor(decimal: Decimal(1.0))
        let ethereumValue = try EthereumValue(crypto: cryptoValue)
        let toAddress = EthereumAddress(
            rawValue: MockEthereumWalletTestData.Transaction.to
        )!
        
        bridge.balanceValue = Single.error(EthereumWalletBridgeMockError.mockError)

        let buildObservable: Observable<EthereumTransactionCandidate> = subject
            .buildTransaction(with: ethereumValue, to: toAddress)
            .asObservable()

        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { buildObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, EthereumWalletBridgeMockError.mockError)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}

extension EthereumTransactionPublished: Equatable {
    public static func == (lhs: EthereumTransactionPublished, rhs: EthereumTransactionPublished) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
    }
}

extension EthereumTransactionFinalised: Equatable {
    public static func == (lhs: EthereumTransactionFinalised, rhs: EthereumTransactionFinalised) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
            && lhs.rawTx == rhs.rawTx
    }
}

extension EthereumTransactionCandidateCosted: Equatable {
    public static func == (lhs: EthereumTransactionCandidateCosted, rhs: EthereumTransactionCandidateCosted) -> Bool {
        return lhs.transaction.gasLimit == rhs.transaction.gasLimit
            && lhs.transaction.gasPrice == rhs.transaction.gasPrice
    }
}

class EthereumTransactionBuildingServiceMock: EthereumTransactionBuildingServiceAPI {
    var lastAmount: EthereumValue?
    var lastTo: EthereumKit.EthereumAddress?
    var buildTransactionValue = Single.just(EthereumTransactionCandidateBuilder().build()!)
    func buildTransaction(with amount: EthereumValue, to: EthereumKit.EthereumAddress) -> Single<EthereumTransactionCandidate> {
        lastAmount = amount
        lastTo = to
        return buildTransactionValue
    }
}
