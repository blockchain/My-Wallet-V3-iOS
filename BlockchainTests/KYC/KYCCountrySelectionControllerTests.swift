//
//  KYCCountrySelectionControllerTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 7/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import Blockchain

class KYCCountrySelectionControllerTests: XCTestCase {

    let sampleResponse = """
        [
            {
                "code": "ASC",
                "name": "Ascension Island",
                "regions": []
            },
            {
                "code": "AND",
                "name": "Andorra",
                "regions": []
            }
        ]
    """

    let badResponse = """
        [
            {
                "code": ❌
            }
        ]
    """

    let emptyResponse = "[]"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDecodeSampleResponse() {
        let responseData = sampleResponse.data(using: .utf8)
        let data = try? JSONDecoder().decode([KYCCountry].self, from: responseData!)
        XCTAssertNoThrow(data, "Expected data not to throw")
        XCTAssertNotNil(data, "Expected data not to be nil")
    }

    func testDecodeJSONFileFromDisk() {
        guard let jsonFile = Bundle.main.url(forResource: "countries", withExtension: "json"),
            let jsonData = try? Data(contentsOf: jsonFile) else {
                XCTFail("Failed to load the JSON file containing the sample countries")
                return
        }
        let data = try? JSONDecoder().decode([KYCCountry].self, from: jsonData)
        XCTAssertNoThrow(data, "Expected data not to throw")
        XCTAssertNotNil(data, "Expected data not to be nil")
    }

    func testDecodeBadResponse() {
        let responseData = badResponse.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode([KYCCountry].self, from: responseData))
    }

    func testDecodeEmptyResponse() {
        let responseData = emptyResponse.data(using: .utf8)
        let data = try? JSONDecoder().decode([KYCCountry].self, from: responseData!)
        XCTAssertNoThrow(data, "Expected data not to throw")
        XCTAssertNotNil(data, "Expected data not to be nil")
        XCTAssertEqual(data?.count, 0, "Expected empty response to result in an empty array")
    }
}
