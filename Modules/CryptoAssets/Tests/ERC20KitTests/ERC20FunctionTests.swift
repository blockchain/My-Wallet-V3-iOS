// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20Kit
import XCTest

final class ERC20FunctionTests: XCTestCase {

    func testValidTransfer() {
        let options: [String] = [
            "a9059cbb00000000000000000000000057acd55de89194f7141756b7766d34400a6ea54500000000000000000000000000000000000000000000000001b141fceef338310000000000000000000000005fe82304359fd1a5e443e292d50d0e47e564ceff",
            "a9059cbb00000000000000000000000057acd55de89194f7141756b7766d34400a6ea54500000000000000000000000000000000000000000000000001b141fceef33831",
            "0xa9059cbb00000000000000000000000057acd55de89194f7141756b7766d34400a6ea54500000000000000000000000000000000000000000000000001b141fceef33831"
        ]
        let proof = ERC20Function.transfer(
            to: "57acd55de89194f7141756b7766d34400a6ea545",
            amount: "00000000000000000000000000000000000000000000000001b141fceef33831"
        )
        for option in options {
            XCTAssertEqual(ERC20Function(data: option), proof)
        }
    }

    func testIncompleteTransfer() {
        let options: [String] = [
            "a9059cbb",
            "a9059cbb1",
            "0xa9059cbb",
            "0xa9059cbb1"
        ]
        let proof = ERC20Function.transfer(
            to: "",
            amount: ""
        )
        for option in options {
            XCTAssertEqual(ERC20Function(data: option), proof)
        }
    }

    func testInvalid() {
        let options: [String?] = [
            nil,
            "",
            "1",
            "12",
            "1234567",
            "12345678",
            "123456789",
            "0x",
            "0x1",
            "0x12",
            "0x123456",
            "0x1234567",
            "0x12345678",
            "0x123456789"
        ]
        for option in options {
            XCTAssertNil(ERC20Function(data: option))
        }
    }
}
