//
//  EtherTransactionTests.swift
//  BlockchainTests
//
//  Created by Jack on 22/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import PlatformKit
@testable import EthereumKit
@testable import Blockchain

class EtherTransactionTests: XCTestCase {
    func test_conversion() {
        let transaction = EthereumHistoricalTransaction(
            identifier: "transactionHash",
            fromAddress: EthereumHistoricalTransaction.Address(publicKey: "fromAddress.publicKey"),
            toAddress: EthereumHistoricalTransaction.Address(publicKey: "toAddress.publicKey"),
            direction: .credit,
            amount: "0.09888244",
            transactionHash: "transactionHash",
            createdAt: Date(),
            fee: CryptoValue.etherFromGwei(string: "231000"),
            memo: "memo",
            confirmations: 12
        )
        
        XCTAssertTrue(transaction.isConfirmed)
        
        let etherTransaction = transaction.legacyTransaction!
        
        XCTAssertEqual(etherTransaction.amount!, "0.09888244")
        XCTAssertEqual(etherTransaction.amountTruncated!, "0.09888244")
        XCTAssertEqual(etherTransaction.fee!, "0.000231")
        XCTAssertEqual(etherTransaction.from!, "fromAddress.publicKey")
        XCTAssertEqual(etherTransaction.to!, "toAddress.publicKey")
        XCTAssertEqual(etherTransaction.myHash!, "transactionHash")
        XCTAssertEqual(etherTransaction.note!, "memo")
        XCTAssertEqual(etherTransaction.txType!, "received")
        XCTAssertEqual(etherTransaction.time, UInt64(transaction.createdAt.timeIntervalSince1970))
        XCTAssertEqual(etherTransaction.confirmations, 12)
        XCTAssertEqual(etherTransaction.fiatAmountsAtTime!.count, 0)
        
        let convertedTransaction = etherTransaction.transaction!
        
        XCTAssertEqual(transaction.identifier, convertedTransaction.identifier)
        XCTAssertEqual(transaction.fromAddress.publicKey, convertedTransaction.fromAddress.publicKey)
        XCTAssertEqual(transaction.toAddress.publicKey, convertedTransaction.toAddress.publicKey)
        XCTAssertEqual(transaction.direction, convertedTransaction.direction)
        XCTAssertEqual(transaction.amount, convertedTransaction.amount)
        XCTAssertEqual(transaction.transactionHash, convertedTransaction.transactionHash)
        XCTAssertEqual(
            transaction.createdAt.timeIntervalSince1970,
            convertedTransaction.createdAt.timeIntervalSince1970,
            accuracy: 1.0
        )
        XCTAssertEqual(transaction.fee, convertedTransaction.fee)
        XCTAssertEqual(transaction.memo, convertedTransaction.memo)
        XCTAssertEqual(transaction.confirmations, convertedTransaction.confirmations)
        XCTAssertEqual(transaction.isConfirmed, convertedTransaction.isConfirmed)
    }
}
