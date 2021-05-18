//
//  EthereumAssetAccountDetailsServiceTests.swift
//  EthereumKitTests
//
//  Created by Jack on 28/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import EthereumKit
@testable import PlatformKit
import RxSwift
import RxTest
import XCTest

class EthereumAssetAccountDetailsServiceTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var bridge: EthereumWalletBridgeMock!
    var client: EthereumAPIClientMock!
    var subject: EthereumAssetAccountDetailsService!
    
    override func setUp() {
        super.setUp()
        
        client = EthereumAPIClientMock()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()

        bridge = EthereumWalletBridgeMock()
        subject = EthereumAssetAccountDetailsService(
            with: bridge,
            client: client
        )
    }

    override func tearDown() {
        
        client = nil
        scheduler = nil
        disposeBag = nil
        bridge = nil
        subject = nil
        
        super.tearDown()
    }

    func test_get_account_details() {
        // Arrange
        let accountID = ""
        let account = EthereumAssetAccountDetails.Account(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: CryptoCurrency.ethereum.defaultWalletName
        )
        let balanceDetails = BalanceDetailsResponse(balance: "2.0", nonce: 1)
        client.balanceDetailsValue = .just(balanceDetails)
        let expectedAccountDetails = EthereumAssetAccountDetails(
            account: account,
            balance: balanceDetails.cryptoValue,
            nonce: balanceDetails.nonce
        )

        let sendObservable: Observable<EthereumAssetAccountDetails> = subject
            .accountDetails(for: accountID)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumAssetAccountDetails> = scheduler
            .start { sendObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumAssetAccountDetails>>] = Recorded.events(
            .next(
                200,
                expectedAccountDetails
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
}
