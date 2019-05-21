//
//  EthereumTransactionBuilderTests.swift
//  EthereumKitTests
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import web3swift
import BigInt
import PlatformKit
@testable import EthereumKit

class EthereumTransactionBuilderTests: XCTestCase {

    var subject: EthereumTransactionBuilder!
    
    override func setUp() {
        super.setUp()
        
        subject = EthereumTransactionBuilder()
    }
    
    override func tearDown() {
        
        subject = nil
        
        super.tearDown()
    }
    
    func test_build_transaction() {
        let toAddress: EthereumKit.EthereumAssetAddress = EthereumKit.EthereumAssetAddress(
            publicKey: "0x3535353535353535353535353535353535353535"
        )
        let value: BigUInt = BigUInt(0.01658472)
        let nonce = MockEthereumWalletTestData.Transaction.nonce
        let gasPrice = MockEthereumWalletTestData.Transaction.gasPrice
        let gasLimit = MockEthereumWalletTestData.Transaction.gasLimit
        
        let transaction = EthereumKit.EthereumTransactionCandidate(
            to: EthereumAddress(rawValue: toAddress.publicKey)!,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            data: nil
        )
        
        var expectedTransaction = web3swift.EthereumTransaction(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: Address(toAddress.publicKey),
            value: transaction.value,
            data: Data()
        )
        expectedTransaction.UNSAFE_setChainID(NetworkId.mainnet)
        
        let result = subject.build(
            transaction: transaction
        )
        
        guard case .success(let costedTransaction) = result else {
            XCTFail("The transaction should be built successfully")
            return
        }
        
        XCTAssertEqual(costedTransaction.transaction.gasLimit, expectedTransaction.gasLimit)
        XCTAssertEqual(costedTransaction.transaction.gasPrice, expectedTransaction.gasPrice)
        XCTAssertEqual(costedTransaction.transaction.value, expectedTransaction.value)
        XCTAssertEqual(costedTransaction.transaction.txhash, expectedTransaction.txhash)
        XCTAssertEqual(costedTransaction.transaction.intrinsicChainID!, expectedTransaction.intrinsicChainID!)
        XCTAssertEqual(costedTransaction.transaction.intrinsicChainID!, web3swift.NetworkId.mainnet.rawValue)
    }
    
}
