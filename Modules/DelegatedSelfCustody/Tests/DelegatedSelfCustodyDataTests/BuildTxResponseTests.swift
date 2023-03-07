// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import DelegatedSelfCustodyData
import ToolKit
import XCTest

final class BuildTxResponseTests: XCTestCase {

    func testDecodes() throws {

        guard let jsonData = json.data(using: .utf8) else {
            XCTFail("Failed to read data.")
            return
        }
        let response = try JSONDecoder().decode(BuildTxResponse.self, from: jsonData)

        XCTAssertEqual(response.summary.relativeFee, "1")
        XCTAssertEqual(response.summary.absoluteFeeMaximum, "2")
        XCTAssertEqual(response.summary.absoluteFeeEstimate, "3")
        XCTAssertEqual(response.summary.amount, "4")
        XCTAssertEqual(response.summary.balance, "5")

        XCTAssertEqual(response.preImages.count, 1)

        let preImage = response.preImages[0]
        XCTAssertEqual(preImage.preImage, "1")
        XCTAssertEqual(preImage.signingKey, "2")
        XCTAssertEqual(preImage.signatureAlgorithm, .secp256k1)
        XCTAssertNil(preImage.descriptor)

        let payloadJsonValue: JSONValue = .dictionary([
            "version": .number(0),
            "auth": .dictionary([
                "authType": .number(4),
                "spendingCondition": .dictionary([
                    "hashMode": .number(0),
                    "signer": .string("71cb17c2d7f5e2ba71fab0aa6172f02d7265ff14"),
                    "nonce": .string("0"),
                    "fee": .string("600"),
                    "keyEncoding": .number(0),
                    "signature": .dictionary([
                        "type": .number(9),
                        "data": .string("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
                    ])
                ])
            ]),
            "payload": .dictionary([
                "type": .number(8),
                "payloadType": .number(0),
                "recipient": .dictionary([
                    "type": .number(5),
                    "address": .dictionary([
                        "type": .number(0),
                        "version": .number(22),
                        "hash160": .string("afc896bb4b998cd40dd885b31d7446ef86b04eb0")
                    ])
                ]),
                "amount": .string("1"),
                "memo": .dictionary([
                    "type": .number(3),
                    "content": .string("")
                ])
            ]),
            "chainId": .number(1),
            "postConditionMode": .number(2),
            "postConditions": .dictionary([
                "type": .number(7),
                "lengthPrefixBytes": .number(4),
                "values": .array([])
            ]),
            "anchorMode": .number(3)
        ])
        let rawTxJsonValue: JSONValue = .dictionary(
            [
                "version": .number(1),
                "payload": payloadJsonValue
            ]
        )
        XCTAssertEqual(response.rawTx, rawTxJsonValue)
    }
}

private let json = """
{
    "summary": {
        "relativeFee": "1",
        "absoluteFeeMaximum": "2",
        "absoluteFeeEstimate": "3",
        "amount": "4",
        "balance": "5"
    },
    "rawTx": {
        "version": 1,
        "payload": {
            "version": 0,
            "auth": {
                "authType": 4,
                "spendingCondition": {
                    "hashMode": 0,
                    "signer": "71cb17c2d7f5e2ba71fab0aa6172f02d7265ff14",
                    "nonce": "0",
                    "fee": "600",
                    "keyEncoding": 0,
                    "signature": {
                        "type": 9,
                        "data": "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                    }
                }
            },
            "payload": {
                "type": 8,
                "payloadType": 0,
                "recipient": {
                    "type": 5,
                    "address": {
                        "type": 0,
                        "version": 22,
                        "hash160": "afc896bb4b998cd40dd885b31d7446ef86b04eb0"
                    }
                },
                "amount": "1",
                "memo": {
                    "type": 3,
                    "content": ""
                }
            },
            "chainId": 1,
            "postConditionMode": 2,
            "postConditions": {
                "type": 7,
                "lengthPrefixBytes": 4,
                "values": []
            },
            "anchorMode": 3
        }
    },
    "preImages": [
        {
            "preImage": "1",
            "signingKey": "2",
            "descriptor": null,
            "signatureAlgorithm": "secp256k1"
        }
    ]
}
"""
