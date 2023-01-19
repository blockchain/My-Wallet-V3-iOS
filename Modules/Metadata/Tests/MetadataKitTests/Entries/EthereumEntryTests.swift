// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
import XCTest

final class EthereumEntryTests: XCTestCase {

    func test_entry_can_be_decoded() throws {
        let data = EthEntryJson.json.data(using: .utf8) ?? Data()
        let decoded = try JSONDecoder().decode(type: EthereumEntryPayload.self, from: data).get()

        let expected = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [.init(address: "0x{address}", archived: false, correct: true, label: "DeFi Wallet")],
                defaultAccountIndex: 0,
                erc20: ["pax": .init(contract: "0x{address}", hasSeen: false, label: "DeFi Wallet", txNotes: [:])],
                hasSeen: false,
                lastTxTimestamp: 1655993817322,
                transactionNotes: [:]
            )
        )
        XCTAssertEqual(decoded, expected)

        let dataMissingFields = EthEntryJson.jsonWithUnexpectedMissingFields.data(using: .utf8) ?? Data()
        let decodedMissingFields = try JSONDecoder().decode(EthereumEntryPayload.self, from: dataMissingFields)

        let expectedMissingFields = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [.init(address: "0x{address}", archived: false, correct: true, label: "DeFi Wallet")],
                defaultAccountIndex: 0,
                erc20: ["pax": .init(contract: "0x{address}", hasSeen: false, label: "DeFi Wallet", txNotes: [:])],
                hasSeen: false,
                lastTxTimestamp: 1655993817322,
                transactionNotes: [:]
            )
        )
        XCTAssertEqual(decodedMissingFields, expectedMissingFields)

        let dataExpectedMissingFields = EthEntryJson.jsonWithExpectedMissingFields.data(using: .utf8) ?? Data()
        let decodedExpectedMissingFields = try JSONDecoder().decode(EthereumEntryPayload.self, from: dataExpectedMissingFields)

        let expectedNormalMissingFields = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [.init(address: "0x{address}", archived: false, correct: true, label: "DeFi Wallet")],
                defaultAccountIndex: 0,
                erc20: [:],
                hasSeen: false,
                lastTxTimestamp: nil,
                transactionNotes: [:]
            )
        )
        XCTAssertEqual(decodedExpectedMissingFields, expectedNormalMissingFields)
    }
}

enum EthEntryJson {
    static let json = """
{
  "ethereum": {
    "has_seen": false,
    "default_account_idx": 0,
    "accounts": [
      {
        "label": "DeFi Wallet",
        "archived": false,
        "correct": true,
        "addr": "0x{address}"
      }
    ],
    "tx_notes": {},
    "tx_meta": {},
    "last_tx_timestamp": 1655993817322,
    "erc20": {
      "pax": {
        "contract": "0x{address}",
        "has_seen": false,
        "label": "DeFi Wallet",
        "tx_notes": {}
      }
    }
  }
}
"""
    static let jsonWithUnexpectedMissingFields = """
{
  "ethereum": {
    "has_seen": false,
    "accounts": [
      {
        "label": "DeFi Wallet",
        "correct": true,
        "addr": "0x{address}"
      }
    ],
    "tx_notes": {},
    "tx_meta": {},
    "last_tx_timestamp": 1655993817322,
    "erc20": {
      "pax": {
        "contract": "0x{address}",
        "has_seen": false,
        "label": "DeFi Wallet",
        "tx_notes": {}
      }
    }
  }
}
"""
    static let jsonWithExpectedMissingFields = """
{
  "ethereum": {
    "has_seen": false,
    "default_account_idx": 0,
    "accounts": [
      {
        "label": "DeFi Wallet",
        "archived": false,
        "correct": true,
        "addr": "0x{address}"
      }
    ],
    "tx_notes": {},
    "tx_meta": {}
  }
}
"""
}
