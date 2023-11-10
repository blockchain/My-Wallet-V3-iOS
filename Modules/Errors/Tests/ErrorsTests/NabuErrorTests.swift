import AnyCoding
@testable import Errors
import Extensions
import XCTest

final class NabuErrorTests: XCTestCase {

    let json: Any = [
        "id": "error-id",
        "code": 2,
        "type": "NOT_FOUND",
        "description": "Not Found: Missing rate for pair USDC-USD; Not Found: Missing rate for pair USDC-USD",
        "ux": [
            "title": "Unable to quote USDC-USD",
            "message": "We are having problems fetching a quote for USDC-USD, don't worry - we're on it",
            "icon": [
                "url": "https://blockchain.com/asset/warning.svg",
                "accessibility": [
                    "description": "Icon, warning symbol"
                ]
            ],
            "actions": [
                [
                    "title": "Contact Support",
                    "url": "https://blockchain.com/support"
                ]
            ]
        ]
    ]

    let oops: Any = [
        "id": "oops-id",
        "code": 2,
        "type": "OOPS_ERROR",
        "description": "Oops!",
        "ux": [
            "title": "Oops! Something went wrong!",
            "message": "We're on it",
            "actions": [
                [
                    "title": "Oops! OK"
                ]
            ]
        ]
    ]

    func test_error_from_json() throws {
        let value = try AnyDecoder().decode(Nabu.Error.self, from: json)
        let output = try XCTUnwrap(AnyEncoder().encode(value))
        let re_decoded = try AnyDecoder().decode(Nabu.Error.self, from: output)
        XCTAssertEqual(value, re_decoded)
    }

    func test_optional_decode() throws {

        struct Test: Decodable {
            @Optional.Codable var url: URL?
        }

        do {
            let value = try AnyDecoder().decode(Test.self, from: ["url": ""])
            XCTAssertNil(value.url)
        }

        do {
            let value = try AnyDecoder().decode(Test.self, from: ["url": "https://blockchain.com/support"])
            XCTAssertNotNil(value.url)
        }
    }

    func test_ux_from_nabu() throws {

        var request = URLRequest(url: "https://blockchain.com/ux")
        request.allHTTPHeaderFields = [
            "X-Request-ID": "request-id"
        ]

        let error = try AnyDecoder(
            userInfo: [.networkURLRequest: request]
        ).decode(Nabu.Error.self, from: json)
        let ux = UX.Error(nabu: error)

        XCTAssertEqual(ux.title, "Unable to quote USDC-USD")
        XCTAssertEqual(ux.message, "We are having problems fetching a quote for USDC-USD, don't worry - we're on it")
        XCTAssertEqual(ux.icon?.url, "https://blockchain.com/asset/warning.svg")
        XCTAssertEqual(ux.icon?.accessibility?.description, "Icon, warning symbol")
        XCTAssertEqual(ux.actions.count, 1)
        if let action = ux.actions.first {
            XCTAssertEqual(action.title, "Contact Support")
            XCTAssertEqual(action.url, "https://blockchain.com/support")
        }
        XCTAssertEqual(ux.metadata, ["Request": "request-id", "GET": "/ux"])
    }

    func test_oops_from_json() throws {
        let value = try AnyDecoder().decode(Nabu.Error.self, from: oops)
        let output = try XCTUnwrap(AnyEncoder().encode(value))
        let re_decoded = try AnyDecoder().decode(Nabu.Error.self, from: output)
        XCTAssertEqual(value, re_decoded)
    }

    func test_oops_ux_from_nabu() throws {

        let error = try AnyDecoder(
            userInfo: [.networkURLRequest: URLRequest(url: "https://blockchain.com/oops")]
        ).decode(Nabu.Error.self, from: oops)
        let ux = UX.Error(nabu: error)

        XCTAssertEqual(ux.title, "Oops! Something went wrong!")
        XCTAssertEqual(ux.message, "We're on it")
        XCTAssertNil(ux.icon)
        XCTAssertEqual(ux.actions.count, 1)
        if let action = ux.actions.first {
            XCTAssertEqual(action.title, "Oops! OK")
            XCTAssertNil(action.url)
        }
        XCTAssertEqual(ux.metadata, ["GET": "/oops"])
    }
}
