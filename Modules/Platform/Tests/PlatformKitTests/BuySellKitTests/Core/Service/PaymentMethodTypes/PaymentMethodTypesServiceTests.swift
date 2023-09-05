// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import ToolKit
import XCTest

final class PaymentMethodTypesServiceTests: XCTestCase {

    func test_filter_OpenBanking_buy_payment_methods_YAPILY() throws {

        let yapily = try LinkedBankData(
            response: LinkedBankResponse(
                json: """
                {
                    "id": "b2db6185-2614-41e0-8514-00ad3dab57ae",
                    "name": "",
                    "isWhitelisted": false,
                    "partner": "YAPILY",
                    "state": "ACTIVE",
                    "currency": "GBP",
                    "agentRef": "1bfe2c35-1056-4f0b-8bbf-d90e0f1637c8",
                    "isBankAccount": false,
                    "isBankTransferAccount": true,
                    "attributes": {
                        "entity": "Safeconnect(UK)"
                    },
                    "addedAt": "2021-09-17T14:21:36.288Z"
                }
                """.data(using: .utf8).json()
            )
        )

        let paymentMethods: [PaymentMethodType] = try [
            .linkedBank(XCTUnwrap(yapily))
        ]

        let filtered = paymentMethods
            .filterValidForBuy(
                currentWalletCurrency: .GBP,
                accountForEligibility: false,
                isOpenBankingEnabled: false,
                isExternalBrokerage: false
            )

        XCTAssertEqual(filtered.count, 0)
    }

    func test_filter_OpenBanking_buy_payment_methods_YAPILY_enabled() throws {

        let yapily = try LinkedBankData(
            response: LinkedBankResponse(
                json: """
                {
                    "id": "b2db6185-2614-41e0-8514-00ad3dab57ae",
                    "name": "",
                    "isWhitelisted": false,
                    "partner": "YAPILY",
                    "state": "ACTIVE",
                    "currency": "GBP",
                    "agentRef": "1bfe2c35-1056-4f0b-8bbf-d90e0f1637c8",
                    "isBankAccount": false,
                    "isBankTransferAccount": true,
                    "attributes": {
                        "entity": "Safeconnect(UK)"
                    },
                    "addedAt": "2021-09-17T14:21:36.288Z"
                }
                """.data(using: .utf8).json()
            )
        )

        let paymentMethods: [PaymentMethodType] = try [
            .linkedBank(XCTUnwrap(yapily))
        ]

        let filtered = paymentMethods
            .filterValidForBuy(
                currentWalletCurrency: .GBP,
                accountForEligibility: false,
                isOpenBankingEnabled: true,
                isExternalBrokerage: false
            )

        XCTAssertEqual(filtered.count, 1)
    }

    func test_filter_OpenBanking_buy_payment_methods_YODLEE() throws {

        let yodlee = try LinkedBankData(
            response: LinkedBankResponse(
                json: """
                {
                    "id": "710eb1fc-1519-4b74-bfba-6841ab222f3e",
                    "name": "",
                    "isWhitelisted": false,
                    "partner": "YODLEE",
                    "state": "ACTIVE",
                    "currency": "USD",
                    "agentRef": "39046d28-9606-4436-a4d5-659aa4e3a1e0",
                    "isBankAccount": false,
                    "isBankTransferAccount": true,
                    "addedAt": "2021-09-17T14:30:38.696Z"
                }
                """.data(using: .utf8).json()
            )
        )

        let paymentMethods: [PaymentMethodType] = try [
            .linkedBank(XCTUnwrap(yodlee))
        ]

        let filtered = paymentMethods
            .filterValidForBuy(
                currentWalletCurrency: .USD,
                accountForEligibility: false,
                isOpenBankingEnabled: false,
                isExternalBrokerage: false
            )

        XCTAssertEqual(filtered.count, 1)

        if let method = filtered.first {
            switch method {
            case .linkedBank(let data):
                XCTAssertEqual(data.partner, .yodlee)
            default:
                XCTFail("Expected 1 yodlee, got \(method)")
            }
        }
    }
}
