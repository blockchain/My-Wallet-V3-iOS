// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
import PlatformKit
import XCTest

class KYCCountrySelectionControllerTests: XCTestCase {

    func testDecodeSampleResponse() {
        let responseData = JSON.sampleResponse.data(using: .utf8)
        let data = try? JSONDecoder().decode([CountryData].self, from: responseData!)
        XCTAssertNoThrow(data, "Expected data not to throw")
        XCTAssertNotNil(data, "Expected data not to be nil")
    }

    func testDecodeBadResponse() {
        let responseData = JSON.badResponse.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode([CountryData].self, from: responseData))
    }

    func testDecodeEmptyResponse() {
        let responseData = JSON.emptyResponse.data(using: .utf8)
        let data = try? JSONDecoder().decode([CountryData].self, from: responseData!)
        XCTAssertNoThrow(data, "Expected data not to throw")
        XCTAssertNotNil(data, "Expected data not to be nil")
        XCTAssertEqual(data?.count, 0, "Expected empty response to result in an empty array")
    }
}

extension KYCCountrySelectionControllerTests {
    enum JSON {
        static let sampleResponse = """
        [{"code":"AD","name":"Andorra","regions":[],"scopes":[],"states":[]},{"code":"AE","name":"United Arab Emirates","regions":[],"scopes":[],"states":[]},{"code":"AF","name":"Afghanistan","regions":[],"scopes":[],"states":[]},{"code":"AG","name":"Antigua and Barbuda","regions":[],"scopes":[],"states":[]},{"code":"AI","name":"Anguilla","regions":[],"scopes":[],"states":[]},{"code":"AL","name":"Albania","regions":[],"scopes":[],"states":[]},{"code":"AM","name":"Armenia","regions":[],"scopes":[],"states":[]},{"code":"AO","name":"Angola","regions":[],"scopes":[],"states":[]},{"code":"AQ","name":"Antarctica","regions":[],"scopes":[],"states":[]},{"code":"AR","name":"Argentina","regions":[],"scopes":[],"states":[]},{"code":"AS","name":"American Samoa","regions":[],"scopes":[],"states":[]},{"code":"AT","name":"Austria","regions":["EEA"],"scopes":["KYC"],"states":[]},{"code":"AU","name":"Australia","regions":[],"scopes":[],"states":[]},{"code":"AW","name":"Aruba","regions":[],"scopes":[],"states":[]},{"code":"AX","name":"Åland Islands","regions":[],"scopes":[],"states":[]}]
        """

        static let badResponse = """
        [{"code":501}]
        """

        static let emptyResponse = "[]"
    }
}
