//
//  EthereumKeyPairDeriverTests.swift
//  EthereumKitTests
//
//  Created by Jack on 09/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import web3swift
@testable import EthereumKit

class EthereumKeyPairDeriverTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var subject: AnyEthereumKeyPairDeriver!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        subject = AnyEthereumKeyPairDeriver()
    }

    override func tearDown() {
        subject = nil
        scheduler = nil
        disposeBag = nil
        
        super.tearDown()
    }
    
    func test_expected_privateKey() throws {
        let password = MockEthereumWalletTestData.password
        let mnemonicString = MockEthereumWalletTestData.mnemonic
        let prefixPath = "m/44'/60'/0'/0"
        
        let expectedPrivateKeyHex: String = MockEthereumWalletTestData.privateKeyHex
        let expectedPrivateKeyBase64: String = MockEthereumWalletTestData.privateKeyBase64
        let expectedAccountString: String = MockEthereumWalletTestData.account
        let expectedAccount = web3swift.Address(expectedAccountString)
        
        let mnemonics = try Mnemonics(mnemonicString)
        let keyStore = try BIP32Keystore(mnemonics: mnemonics, password: password, prefixPath: prefixPath)
        let account = keyStore.addresses[0]
        XCTAssertEqual(account, expectedAccount)
        
        let key = try keyStore.UNSAFE_getPrivateKeyData(password: password, account: account)
        let keyHex = key.hex
        let keyBase64 = key.base64EncodedString()
        print("   keyHex: \(keyHex)")
        print("keyBase64: \(keyBase64)")
        XCTAssertEqual(key.hex, expectedPrivateKeyHex)
        XCTAssertEqual(key.base64EncodedString(), expectedPrivateKeyBase64)
    }
    
    func test_derive() {
        // Arrange
        let password = MockEthereumWalletTestData.password
        let mnemonic =  MockEthereumWalletTestData.mnemonic
        let expectedAccount =  MockEthereumWalletTestData.account
        let expectedKeyPair = EthereumKeyPair(
            accountID: expectedAccount,
            privateKey: EthereumPrivateKey(
                mnemonic: mnemonic,
                password: password,
                data: MockEthereumWalletTestData.privateKeyData
            )
        )
        let keyDerivationInput = EthereumKeyDerivationInput(
            mnemonic: mnemonic,
            password: password
        )
        
        let deriveObservable = subject
            .derive(input: keyDerivationInput)
            .asObservable()
        
        // Act
        let result: TestableObserver<EthereumKeyPair> = scheduler
            .start { deriveObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumKeyPair>>] = Recorded.events(
            .next(
                200,
                expectedKeyPair
            ),
            .completed(200)
        )
        XCTAssertEqual(result.events, expectedEvents)
    }
}


