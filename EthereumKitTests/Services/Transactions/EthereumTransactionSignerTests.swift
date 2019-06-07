//
//  EthereumTransactionSignerTests.swift
//  EthereumKitTests
//
//  Created by Jack on 23/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import web3swift
import BigInt
import PlatformKit
@testable import EthereumKit

class EthereumTransactionSignerTests: XCTestCase {
    
    var subject: EthereumTransactionSigner!

    override func setUp() {
        super.setUp()
        
        subject = EthereumTransactionSigner()
    }

    override func tearDown() {
        subject = nil
        
        super.tearDown()
    }

    func test_sign_transaction() throws {
        let keyPair = MockEthereumWalletTestData.keyPair
        let account = MockEthereumWalletTestData.account
        let toAddress = EthereumHistoricalTransaction.Address(publicKey: "0x3535353535353535353535353535353535353535")
        let amount: String = "0.1"
        let nonce: BigUInt = 9
        var web3transaction: web3swift.EthereumTransaction = EthereumTransaction(
            nonce: nonce,
            gasPrice: BigUInt(23),
            gasLimit: BigUInt(21000),
            to: Address(toAddress.publicKey),
            value: BigUInt(amount, decimals: CryptoCurrency.ethereum.maxDecimalPlaces)!,
            data: Data()
        )
        web3transaction.UNSAFE_setChainID(NetworkId.mainnet)
        
        // swiftlint:disable force_try
        let costedTransaction = try! EthereumTransactionCandidateCosted(
            transaction: web3transaction
        )
        // swiftlint:enable force_try
        
        let result = subject
            .sign(
                transaction: costedTransaction,
                nonce: nonce,
                keyPair: keyPair
            )
        
        XCTAssertNoThrow(try result.get())
        
        guard case .success(let signedTransaction) = result else {
            XCTFail("Tx signing should succeed")
            return
        }
        
        XCTAssertEqual(signedTransaction.transaction.v, 38)
        XCTAssertEqual(signedTransaction.transaction.sender, web3swift.Address(account))
        XCTAssertEqual(signedTransaction.transaction.intrinsicChainID, NetworkId.mainnet.rawValue)
    }
}
