// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
import XCTest

final class BitcoinCashEntryTests: XCTestCase {

    func test_entry_can_be_decoded() throws {
        let data = BitcoinCashEntryJson.json.data(using: .utf8) ?? Data()
        let decoded = try JSONDecoder().decode(type: BitcoinCashEntryPayload.self, from: data).get()

        let expected = BitcoinCashEntryPayload(
            accounts: [
                .init(archived: false, label: "DeFi Wallet"),
                .init(archived: true, label: "DeFi Wallet 1")
            ],
            defaultAccountIndex: 0,
            hasSeen: true,
            txNotes: ["0c{tx_id}4": "test"],
            addresses: [:]
        )
        XCTAssertEqual(decoded, expected)

        let dataMissingFields = BitcoinCashEntryJson.jsonWithUnexpectedMissingFields.data(using: .utf8) ?? Data()
        let decodedMissingFields = try JSONDecoder().decode(BitcoinCashEntryPayload.self, from: dataMissingFields)

        let expectedMissingFields = BitcoinCashEntryPayload(
            accounts: [
                .init(archived: false, label: "DeFi Wallet")
            ],
            defaultAccountIndex: 0,
            hasSeen: nil,
            txNotes: nil,
            addresses: nil
        )
        XCTAssertEqual(decodedMissingFields, expectedMissingFields)
    }
}

enum BitcoinCashEntryJson {
    static let json = """
{
  "default_account_idx": 0,
  "addresses": {},
  "has_seen": true,
  "accounts": [
    {
      "label": "DeFi Wallet",
      "archived": false
    },
    {
      "label": "DeFi Wallet 1",
      "archived": true
    }
  ],
  "tx_notes": {
    "0c{tx_id}4": "test"
  }
}
"""

    static let jsonWithUnexpectedMissingFields = """
{
  "accounts": [
    {
      "label": "DeFi Wallet"
    }
  ]
}
"""
}
