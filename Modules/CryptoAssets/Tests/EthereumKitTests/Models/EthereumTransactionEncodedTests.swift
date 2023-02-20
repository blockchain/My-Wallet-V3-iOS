// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import XCTest

final class EthereumTransactionEncodedTests: XCTestCase {

    func testTransactionHashIsInTheRightFormat() {
        let rawTransaction = "0xf86c258502540be40083035b609482e041e84074fc5f5947d4d27e3c44f824b7a1a187b1a2bc2ec500008078a04a7db627266fa9a4116e3f6b33f5d245db40983234eb356261f36808909d2848a0166fa098a2ce3bda87af6000ed0083e3bf7cc31c6686b670bd85cbc6da2d6e85"
        let transactionHash = "0x58e5a0fc7fbc849eddc100d44e86276168a8c7baaa5604e44ba6f5eb8ba1b7eb"
        let data = Data(hexString: rawTransaction)!
        let signed = EthereumTransactionEncoded(encodedTransaction: data)
        XCTAssertEqual(signed.transactionHash, transactionHash)
        XCTAssertEqual(signed.rawTransaction, rawTransaction)
    }
}
