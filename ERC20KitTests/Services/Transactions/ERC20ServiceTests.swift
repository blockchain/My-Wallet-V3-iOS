//
//  ERC20ServiceTests.swift
//  ERC20KitTests
//
//  Created by Jack on 19/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import BigInt
import web3swift
import PlatformKit
@testable import EthereumKit
@testable import ERC20Kit

enum ERC20ServiceMockError: Error {
    case mockError
}

class ERC20ServiceTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var erc20Bridge: ERC20BridgeMock!
    
    var accountAPIClient: ERC20AccountAPIClientMock!
    var ethereumWalletBridge: ERC20EthereumWalletBridgeMock!
    var assetAccountDetailsService: ERC20AssetAccountDetailsService<PaxToken>!
    var assetAccountRepository: ERC20AssetAccountRepository<PaxToken>!
    
    var ethereumAssetAccountDetailsService: EthereumAssetAccountDetailsService!
    var ethereumAssetAccountRepository: EthereumAssetAccountRepository!
    
    var feeService: EthereumFeeServiceMock!
    var subject: ERC20Service<PaxToken>!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        erc20Bridge = ERC20BridgeMock()
        
        accountAPIClient = ERC20AccountAPIClientMock()
        ethereumWalletBridge = ERC20EthereumWalletBridgeMock()
        assetAccountDetailsService = ERC20AssetAccountDetailsService(
            with: ethereumWalletBridge,
            accountClient: accountAPIClient
        )
        assetAccountRepository = ERC20AssetAccountRepository(
            service: assetAccountDetailsService
        )
        
        ethereumAssetAccountDetailsService = EthereumAssetAccountDetailsService(
            with: ethereumWalletBridge
        )
        ethereumAssetAccountRepository = EthereumAssetAccountRepository(
            service: ethereumAssetAccountDetailsService
        )
        
        feeService = EthereumFeeServiceMock()
        subject = ERC20Service(
            with: erc20Bridge,
            assetAccountRepository: assetAccountRepository,
            ethereumAssetAccountRepository: ethereumAssetAccountRepository,
            feeService: feeService
        )
    }
    
    override func tearDown() {
        erc20Bridge = nil
        accountAPIClient = nil
        ethereumWalletBridge = nil
        assetAccountDetailsService = nil
        assetAccountRepository = nil
        ethereumAssetAccountDetailsService = nil
        ethereumAssetAccountRepository = nil
        feeService = nil
        subject = nil
        
        super.tearDown()
    }
    
    func test_build_transfer() throws {
        // Arrange
        let dataHexString =
            "a9059cbb00000000000000000000000035353535353535353535353535353535353535350000000000000000000000000000000000000000000000000de0b6b3a7640000"
        let expectedTransaction = EthereumTransactionCandidate(
            to: EthereumAddress(rawValue: PaxToken.contractAddress.rawValue)!,
            gasPrice: MockEthereumWalletTestData.Transaction.gasPrice,
            gasLimit: MockEthereumWalletTestData.Transaction.gasLimitContract,
            value: 0,
            data: Data.fromHex(dataHexString)
        )
        
        let to = EthereumAddress(rawValue: MockEthereumWalletTestData.Transaction.to)!
        let amountCrypto = CryptoValue.paxFromMajor(decimal: Decimal(1.0))
        let amount = try ERC20TokenValue<PaxToken>(crypto: amountCrypto)
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .next(
                200,
                expectedTransaction
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_build_transfer_amount_over_token_balance() throws {
        // Arrange
        let balance = CryptoValue.paxFromMajor(decimal: Decimal(0.1)).amount
            .string(unitDecimals: 0)
        let accountResponse = ERC20AccountResponse<PaxToken>(
            accountHash: "",
            tokenHash: "",
            balance: balance,
            decimals: 0
        )
        accountAPIClient.fetchWalletAccountResponse = Single<ERC20AccountResponse<PaxToken>>.just(accountResponse)
        
        let cryptoValue = CryptoValue.paxFromMajor(decimal: Decimal(1.0))
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(
            rawValue: MockEthereumWalletTestData.Transaction.to
        )!
        
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ServiceError.insufficientTokenBalance)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_build_transfer_ethereum_fees_over_ethereum_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.paxFromMajor(decimal: Decimal(1.00))
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(
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
        ethereumWalletBridge.balanceValue = Single.just(CryptoValue.etherFromMajor(decimal: Decimal(0.01)))
        
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ServiceError.insufficientEthereumBalance)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_failed_to_fetch_ether_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.paxFromMajor(decimal: Decimal(1.00))
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(
            rawValue: MockEthereumWalletTestData.Transaction.to
        )!

        ethereumWalletBridge.balanceValue = Single.error(ERC20ServiceMockError.mockError)

        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }


        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ServiceMockError.mockError)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_failed_to_fetch_token_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.paxFromMajor(decimal: Decimal(1.00))
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(
            rawValue: MockEthereumWalletTestData.Transaction.to
        )!
        
        accountAPIClient.fetchWalletAccountResponse = Single.error(ERC20ServiceMockError.mockError)
        
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }

        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ServiceMockError.mockError)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_get_memo_for_transaction_hash() throws {
        // Arrange
        let expectedMemo = "expectedMemo"
        let transactionHash = "transactionHash"
        let tokenContractAddress = "0x8E870D67F660D95d5be530380D0eC0bd388289E1"
        
        erc20Bridge.memoForTransactionHashValue = Single.just(expectedMemo)
        
        let memoObservable = subject.memo(for: transactionHash).asObservable()
        
        // Act
        let result: TestableObserver<String?> = scheduler
            .start { memoObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<String?>>] = Recorded.events(
            .next(
                200,
                expectedMemo
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
        XCTAssertEqual(erc20Bridge.lastTransactionHashFetched, transactionHash)
        XCTAssertEqual(erc20Bridge.lastTokenContractAddressFetched, tokenContractAddress)
    }
    
    func test_save_memo_for_transaction_hash() throws {
        // Arrange
        let transactionHash = "transactionHash"
        let transactionMemo = "transactionMemo"
        let tokenContractAddress = "0x8E870D67F660D95d5be530380D0eC0bd388289E1"
        
        let saveMemoObservable = subject
            .save(transactionMemo: transactionMemo, for: transactionHash)
            .asObservable()
        
        // Act
        let result: TestableObserver<Never> = scheduler
            .start { saveMemoObservable }
        
        // Assert
        guard result.events.count == 1, let value = result.events.first?.value, value.isCompleted else {
            XCTFail("Saving should complete successfully")
            return
        }
        
        XCTAssertEqual(erc20Bridge.lastTransactionMemoSaved, transactionMemo)
        XCTAssertEqual(erc20Bridge.lastTransactionHashSaved, transactionHash)
        XCTAssertEqual(erc20Bridge.lastTokenContractAddressSaved, tokenContractAddress)
    }
    
}
