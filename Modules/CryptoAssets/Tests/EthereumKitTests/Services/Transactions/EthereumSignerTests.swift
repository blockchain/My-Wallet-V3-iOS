// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
@testable import EthereumKitMock
import MoneyKit
@testable import PlatformKit
import XCTest

final class EthereumSignerTests: XCTestCase {

    private struct TestCase {
        let rawTransaction: String
        let to: EthereumAddress
        let gasPrice: BigUInt
        let gasLimit: BigUInt
        let value: BigUInt
        let nonce: BigUInt
    }

    var subject: EthereumSigner!
    private var signTransactionTestCases: [TestCase] {
        [
            TestCase(
                rawTransaction: "0xf86c0985028fa6ae0082520894353535353535353535353535353535353535353588016345785d8a00008026a0521f82fef48c80ca3245cc1d2be289f42f5119613fc1eea8c8e9e673d48c7b8ba017cfd25094a4f81e2c5f766e76686bc9270f22d24e8998fa1549d0c9a3d5f786",
                to: EthereumAddress(address: MockEthereumWalletTestData.Transaction.to, network: .ethereum)!,
                gasPrice: MockEthereumWalletTestData.Transaction.gasPrice,
                gasLimit: MockEthereumWalletTestData.Transaction.gasLimit,
                value: BigUInt(1e17),
                nonce: 9
            ),
            TestCase(
                rawTransaction: "0xf867091782520894353535353535353535353535353535353535353588016345785d8a00008026a0b51971506a39c26b1c584df3c9ccc15fb1f890b023c5a5861b01d0d8e61b9249a00d29b3a0a38119ca1fe971d270b32a31bec2037466c2d506c194b7924996a3e1",
                to: EthereumAddress(address: MockEthereumWalletTestData.Transaction.to, network: .ethereum)!,
                gasPrice: 23,
                gasLimit: MockEthereumWalletTestData.Transaction.gasLimit,
                value: BigUInt(1e17),
                nonce: 9
            )
        ]
    }

    override func setUp() {
        super.setUp()
        subject = EthereumSigner()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_sign_transaction() throws {
        for testCase in signTransactionTestCases {
            let candidate = EthereumTransactionCandidate(
                to: testCase.to,
                gasPrice: testCase.gasPrice,
                gasLimit: testCase.gasLimit,
                value: testCase.value,
                nonce: 9,
                chainID: 1,
                transferType: .transfer()
            )
            guard case .success(let costed) = EthereumTransactionCandidateCosted.create(
                transaction: candidate
            ) else {
                XCTFail("EthereumTransactionCandidateCosted failed: \(testCase.rawTransaction)")
                break
            }
            guard case .success(let signed) = subject.sign(transaction: costed, keyPair: MockEthereumWalletTestData.keyPair) else {
                XCTFail("EthereumSigner failed: \(testCase.rawTransaction)")
                break
            }
            XCTAssertEqual(signed.encodedTransaction, Data(hexString: testCase.rawTransaction))
            XCTAssertEqual(signed.rawTransaction, testCase.rawTransaction.lowercased())
        }
    }

    func test_personal_sign() throws {
        let message = "This is a test message!"
        let messageData = message.data(using: .ascii)!
        let keyPair = MockEthereumWalletTestData.keyPair
        guard case .success(let result) = subject.sign(messageData: messageData, keyPair: keyPair) else {
            XCTFail("Transaction signing failed")
            return
        }
        XCTAssertEqual(
            result.hexString.withHex,
            "0xcbe90263d29bc2e607f911a73bb9fea4faca12d664504592100992dcd2b444c352bdc10d6ba8b1e2c015842c2961c4697d4057edc3489bcac0c3155059ae969c01"
        )
    }
}
