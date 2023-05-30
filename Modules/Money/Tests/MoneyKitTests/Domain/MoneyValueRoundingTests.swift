// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import XCTest

class MoneyValueRoundingTests: XCTestCase {

    func testDisplayableRounding() throws {
        // 0.121414197936925024 ETH
        let sut = CryptoValue.create(minor: 121414197936925024, currency: .ethereum).moneyValue
        let up = sut.displayableRounding(roundingMode: .up)
        // 0.1214142 ETH
        XCTAssertEqual(up.minorAmount, 121414200000000000)
        let down = sut.displayableRounding(roundingMode: .down)
        // 0.12141419 ETH
        XCTAssertEqual(down.minorAmount, 121414190000000000)
    }
}
