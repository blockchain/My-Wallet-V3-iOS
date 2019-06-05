//
//  EthereumTransactionEncoderTests.swift
//  EthereumKitTests
//
//  Created by Jack on 03/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import web3swift
import BigInt
import PlatformKit
@testable import EthereumKit

class EthereumTransactionEncoderTests: XCTestCase {
    
    var subject: EthereumTransactionEncoder!

    override func setUp() {
        super.setUp()
        
        subject = EthereumTransactionEncoder()
    }

    override func tearDown() {
        subject = nil
        
        super.tearDown()
    }

    func test_encode() throws {
        let password = MockEthereumWalletTestData.password
        let mnemonicsString = MockEthereumWalletTestData.mnemonic
        let expectedAccountString = MockEthereumWalletTestData.account
        let expectedRawTx = "0xf867091782520894353535353535353535353535353535353535353588016345785d8a0000801ca0b8f014137ec096f9c6500d018e55a5963c2af244e4248d2bf5f4b7e303865a72a04d7d0235e909b89f3efcd67f6687b1953e1f0ca564b55b2fee57d3c80e1e9e35"
        
        let keyPair = EthereumKeyPair(
            accountID: expectedAccountString,
            privateKey: EthereumPrivateKey(
                mnemonic: mnemonicsString,
                password: password,
                data: MockEthereumWalletTestData.privateKeyData
            )
        )
        
        let account = web3swift.Address(expectedAccountString)
        let mnemonics = try Mnemonics(keyPair.privateKey.mnemonic)
        let keystore = try BIP32Keystore(
            mnemonics: mnemonics,
            password: keyPair.privateKey.password,
            prefixPath: HDNode.defaultPathMetamaskPrefix
        )
        
        var transaction =  web3swift.EthereumTransaction(
            nonce: BigUInt(9),
            gasPrice: BigUInt(23),
            gasLimit: BigUInt(21000),
            to: Address("0x3535353535353535353535353535353535353535"),
            value: BigUInt("0.1", decimals: CryptoCurrency.ethereum.maxDecimalPlaces)!,
            data: Data()
        )
        
        try Web3Signer.signTX(transaction: &transaction, keystore: keystore, account: account, password: password)
        
        let signedTransaction = try EthereumTransactionCandidateSigned(transaction: transaction)

        guard case .success(let finalisedTransaction) = subject.encode(signed: signedTransaction) else {
            XCTFail("Transaction encoding failed")
            return
        }
        
        XCTAssertEqual(finalisedTransaction.rawTx, expectedRawTx)
        
        let transactionData = Data.fromHex(finalisedTransaction.rawTx)!
        let rawTransaction = EthereumTransaction.fromRaw(transactionData)
        XCTAssertNotNil(rawTransaction)
    }
}
