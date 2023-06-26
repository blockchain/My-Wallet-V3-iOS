// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardPaymentDomain
import PlatformKitMock
import RxBlocking
import RxSwift
import ToolKitMock
import XCTest

@testable import PlatformKit
@testable import PlatformUIKit

final class CardTypeValidationTests: XCTestCase {

    private var validator: CardNumberValidator!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        validator = CardNumberValidator(
            supportedCardTypes: [.mastercard, .visa, .diners, .discover, .jcb, .amex],
            cardSuccessRateService: CardSuccessRateServiceAPIMock()
        )
    }

    func testDinersCard() throws {
        let numbers = [
            "36006666333344",
            "36070500001020"
        ]
        try assert(numbers: numbers, to: .diners, expectedIsValid: true)
    }

    func testAmexCard() throws {
        let numbers = [
            "370000000000002",
            "370000000100018"
        ]
        try assert(numbers: numbers, to: .amex, expectedIsValid: true)
    }

    func testDiscoverCard() throws {
        let numbers = [
            "6011601160116611",
            "6011000400000000"
        ]
        try assert(numbers: numbers, to: .discover, expectedIsValid: true)
    }

    func testJCBCard() throws {
        let numbers = [
            "3569990010095841",
            "3530111333300000",
            "3566002020360505"
        ]
        try assert(numbers: numbers, to: .jcb, expectedIsValid: true)
    }

    func testVisaCard() throws {
        let numbers = [
            "4561526275710785",
            "4641938485711442",
            "4051071810245333",
            "4535893314665161",
            "4506252264120211",
            "4171957535400853",
            "4378970127184224"
        ]

        try assert(numbers: numbers, to: .visa, expectedIsValid: true)
    }

    func testMastercard() throws {
        let numbers = [
            "5585558555855583",
            "5555555555554444",
            "5105105105105100",
            "5101180000000007"
        ]

        try assert(numbers: numbers, to: .mastercard, expectedIsValid: true)
    }

    func testInvalidTypeCard() throws {
        let numbers = [
            "0083",
            "d33d555555555554444",
            "05105105-105100",
            "aa5101180000000007"
        ]

        try assert(numbers: numbers, to: .unknown, expectedIsValid: false)
    }

    func testInvalidMastercardType() throws {
        let numbers = [
            "555555555555444",
            "510510510510510"
        ]

        try assert(numbers: numbers, to: .mastercard, expectedIsValid: false)
    }

    private func assert(numbers: [String], to expectedCardType: CardType, expectedIsValid: Bool) throws {
        try numbers.forEach {
            validator.valueRelay.accept($0)

            let cardType = try validator.cardType.toBlocking().first()
            XCTAssertEqual(cardType, expectedCardType)

            let isValid = try validator.isValid.toBlocking().first()!
            XCTAssertEqual(isValid, expectedIsValid)
        }
    }
}
