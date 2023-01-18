// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
import XCTest

final class StellarEntryTests: XCTestCase {

    func test_entry_can_be_decoded() throws {
        let data = StellarEntryJson.json.data(using: .utf8) ?? Data()
        let decoded = try JSONDecoder().decode(type: StellarEntryPayload.self, from: data).get()

        let expected = StellarEntryPayload(
            accounts: [
                .init(archived: false, label: "DeFi Wallet", publicKey: "GDUR{address}2AIE")
            ],
            defaultAccountIndex: 0,
            txNotes: [:]
        )
        XCTAssertEqual(decoded, expected)

        let dataMissingFields = StellarEntryJson.jsonWithUnexpectedMissingFields.data(using: .utf8) ?? Data()
        let decodedMissingFields = try JSONDecoder().decode(StellarEntryPayload.self, from: dataMissingFields)

        let expectedMissingFields = StellarEntryPayload(
            accounts: [
                .init(archived: false, label: "DeFi Wallet", publicKey: "GDUR{address}2AIE")
            ],
            defaultAccountIndex: 0,
            txNotes: nil
        )
        XCTAssertEqual(decodedMissingFields, expectedMissingFields)
    }
}

enum StellarEntryJson {
    static let json = """
{
  "default_account_idx": 0,
  "accounts": [
    {
      "publicKey": "GDUR{address}2AIE",
      "label": "DeFi Wallet",
      "archived": false
    }
  ],
  "tx_notes": {}
}
"""

    static let jsonWithUnexpectedMissingFields = """
{
  "accounts": [
    {
      "publicKey": "GDUR{address}2AIE",
      "label": "DeFi Wallet",
    }
  ]
}
"""
}
