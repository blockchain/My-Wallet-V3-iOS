// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKitMock
import RxBlocking
import RxSwift
import XCTest

@testable import PlatformUIKit
@testable import ToolKitMock

final class CardTextFieldViewModelTests: XCTestCase {

    private var validator: CardNumberValidator!
    private var viewModel: CardTextFieldViewModel!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        validator = CardNumberValidator(
            supportedCardTypes: [.mastercard, .visa, .diners, .jcb, .amex],
            cardSuccessRateService: CardSuccessRateServiceAPIMock()
        )
        viewModel = CardTextFieldViewModel(
            validator: validator,
            messageRecorder: MockMessageRecorder()
        )
    }

    func testValidMastercardNumbers() throws {
        let numbers = [
            "5555555555554444",
            "5105105105105100",
            "5101180000000007",
            "5100 2900 2900 2909",
            "5555 3412 4444 1115",
            "5577 0000 5577 0004",
            "5136 3333 3333 3335",
            "5585558555855583",
            "5555 4444 3333 1111",
            "5100 0600 00000002",
            "5424 0000 0000 0015"
        ]

        try numbers.forEach {
            _ = viewModel.editIfNecessary($0, operation: .addition)
            let state = try viewModel.state.toBlocking().first()!
            if validator.supports(cardType: .mastercard) {
                XCTAssertTrue(state.isValid)
            } else {
                XCTAssertFalse(state.isValid)
            }
        }
    }

    func testValidDiscoverCardNumbers() throws {
        let numbers = [
            "6011 6011 6011 6611",
            "6445 6445 6445 6445"
        ]

        try numbers.forEach {
            _ = viewModel.editIfNecessary($0, operation: .addition)
            let state = try viewModel.state.toBlocking().first()!
            if validator.supports(cardType: .discover) {
                XCTAssertTrue(state.isValid)
            } else {
                XCTAssertFalse(state.isValid)
            }
        }
    }

    func testValidJCBCardNumbers() throws {
        let numbers = [
            "3569 9900 1009 5841",
            "3530111333300000",
            "3566002020360505"
        ]

        try numbers.forEach {
            _ = viewModel.editIfNecessary($0, operation: .addition)
            let state = try viewModel.state.toBlocking().first()!
            if validator.supports(cardType: .jcb) {
                XCTAssertTrue(state.isValid)
            } else {
                XCTAssertFalse(state.isValid)
            }
        }
    }

    func testValidDinersCardNumbers() throws {
        let numbers = [
            "3600 6666 3333 44",
            "3607 0500 0010 20"
        ]

        try numbers.forEach {
            _ = viewModel.editIfNecessary($0, operation: .addition)
            let state = try viewModel.state.toBlocking().first()!
            if validator.supports(cardType: .diners) {
                XCTAssertTrue(state.isValid)
            } else {
                XCTAssertFalse(state.isValid)
            }
        }
    }

    func testValidAmexCardNumbers() throws {
        let numbers = [
            "3700 0000 0000 002",
            "3700 0000 0100 018"
        ]

        try numbers.forEach {
            _ = viewModel.editIfNecessary($0, operation: .addition)
            let state = try viewModel.state.toBlocking().first()!
            if validator.supports(cardType: .amex) {
                XCTAssertTrue(state.isValid)
            } else {
                XCTAssertFalse(state.isValid)
            }
        }
    }

    func testValidVisaCardNumbers() throws {
        let numbers = [
            "4850 6526 8106 5604",
            "4505 0520 3738 6227",
            "41 635 424 707 67 670",
            "4561526275710785",
            "4641938485711442",
            "4051071810245333",
            "4535893314665161",
            "4506252264120211",
            "4171957535400853",
            "4378970127184224",
            "4598978856545725",
            "4065700263458233",
            "4547755341068618",
            "4544876317716122"
        ]

        try numbers.forEach {
            _ = viewModel.editIfNecessary($0, operation: .addition)
            let state = try viewModel.state.toBlocking().first()!
            if validator.supports(cardType: .visa) {
                XCTAssertTrue(state.isValid)
            } else {
                XCTAssertFalse(state.isValid)
            }
        }
    }

    func testInvalidCardNumbers() throws {
        let numbers = [
            "850652681065604",
            "8505052037386227",
            "9163542470767222670",
            "2561526275710785",
            "1641938485711442",
            "3051071810245333",
            "6535893314665161",
            "50625264120211",
            "1717535400853",
            "970127184224",
            "8978856545725",
            "065700263458233",
            "947755341068618",
            "14544876317716122"
        ]

        try numbers.forEach {
            _ = viewModel.editIfNecessary($0, operation: .addition)
            let state = try viewModel.state.toBlocking().first()!
            XCTAssertFalse(state.isValid)
        }
    }
}
