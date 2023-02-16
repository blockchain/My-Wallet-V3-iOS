// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import NetworkKit
import ToolKit
import XCTest

class ConfigTests: XCTestCase {

    private var configInfoDictionary: [String: Any]?

    override func setUp() {
        super.setUp()
        configInfoDictionary = MainBundleProvider.mainBundle.infoDictionary
    }

    func testAllKeysPresentAndNotEmpty() {
        let keys: [String] = [
            "API_URL",
            "WEBSOCKET_SERVER",
            "EXCHANGE_URL",
            "EXPLORER_SERVER",
            "RETAIL_CORE_URL",
            "WALLET_SERVER"
        ]
        for key in keys {
            let value = getValue(for: key)
            XCTAssertNotNil(value)
            XCTAssertEqual(value?.isEmpty, false)
        }
    }

    func testBlockchainAPIBundleIsCorrect() {
        let value = BlockchainAPI.shared.apiHost
        XCTAssertFalse(value.isEmpty)
    }

    private func getValue(for key: String) -> String? {
        configInfoDictionary?["RETAIL_CORE_URL"] as? String
    }
}
