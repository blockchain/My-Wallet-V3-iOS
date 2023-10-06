// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import MoneyKit
import XCTest

final class EthereumTransactionFeeTests: XCTestCase {

    func testAbsoluteFeeInitGwei() {
        let subject = EVMTransactionFee(
            regularGwei: 5,
            priorityGwei: 7,
            gasLimit: 11,
            gasLimitContract: 13,
            network: .ethereum
        )
        XCTAssertEqual(
            subject.absoluteFee(with: .regular, extraGasLimit: 3, isContract: false),
            CryptoValue.create(minor: "70000000000", currency: .ethereum)
        )
        XCTAssertEqual(
            subject.absoluteFee(with: .regular, extraGasLimit: 3, isContract: true),
            CryptoValue.create(minor: "80000000000", currency: .ethereum)
        )
        XCTAssertEqual(
            subject.absoluteFee(with: .priority, extraGasLimit: 3, isContract: false),
            CryptoValue.create(minor: "98000000000", currency: .ethereum)
        )
        XCTAssertEqual(
            subject.absoluteFee(with: .priority, extraGasLimit: 3, isContract: true),
            CryptoValue.create(minor: "112000000000", currency: .ethereum)
        )
    }
}
