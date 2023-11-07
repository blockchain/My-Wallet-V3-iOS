import BlockchainComponentLibrary
import XCTest

final class LengthTests: XCTestCase {

    func test_codable() throws {

        let pt = try Length(json: ["pt": 5])
        let vw = try Length(json: ["vw": 5])
        let vh = try Length(json: ["vh": 5])
        let vmin = try Length(json: ["vmin": 5])
        let vmax = try Length(json: ["vmax": 5])
        let pw = try Length(json: ["pw": 5])
        let ph = try Length(json: ["ph": 5])
        let pmin = try Length(json: ["pmin": 5])
        let pmax = try Length(json: ["pmax": 5])

        XCTAssertEqual(pt, .pt(5))
        XCTAssertEqual(vw, .vw(5))
        XCTAssertEqual(vh, .vh(5))
        XCTAssertEqual(vmin, .vmin(5))
        XCTAssertEqual(vmax, .vmax(5))
        XCTAssertEqual(pw, .pw(5))
        XCTAssertEqual(ph, .ph(5))
        XCTAssertEqual(pmin, .pmin(5))
        XCTAssertEqual(pmax, .pmax(5))

        try XCTAssertEqual(pt.json() as? [String: CGFloat], ["pt": 5])
        try XCTAssertEqual(vw.json() as? [String: CGFloat], ["vw": 5])
        try XCTAssertEqual(vh.json() as? [String: CGFloat], ["vh": 5])
        try XCTAssertEqual(vmin.json() as? [String: CGFloat], ["vmin": 5])
        try XCTAssertEqual(vmax.json() as? [String: CGFloat], ["vmax": 5])
        try XCTAssertEqual(pw.json() as? [String: CGFloat], ["pw": 5])
        try XCTAssertEqual(ph.json() as? [String: CGFloat], ["ph": 5])
        try XCTAssertEqual(pmin.json() as? [String: CGFloat], ["pmin": 5])
        try XCTAssertEqual(pmax.json() as? [String: CGFloat], ["pmax": 5])
    }

    func test_math() throws {

        let frame = CGRect(x: 0, y: 0, width: 2048, height: 1024)

        XCTAssertEqual(8.vw.in(frame), (2048 / 100) * 8)
        XCTAssertEqual(8.vh.in(frame), (1024 / 100) * 8)
        XCTAssertEqual(8.vmin.in(frame), (1024 / 100) * 8)
        XCTAssertEqual(8.vmax.in(frame), (2048 / 100) * 8)

        XCTAssertEqual(8.pt.in(frame), 8)
    }
}

// JSON mocking helpers from toolkit, potential for shared utilities

extension Decodable {

    init(json any: Any, using decoder: JSONDecoder = .init()) throws {
        let data = try JSONSerialization.data(withJSONObject: any, options: .fragmentsAllowed)
        self = try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {

    func data(using encoder: JSONEncoder = .init()) throws -> Data {
        try encoder.encode(self)
    }

    func json(using encoder: JSONEncoder = .init()) throws -> Any {
        try data(using: encoder).json()
    }
}

extension Data {

    func json() throws -> Any {
        try JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
}

extension Data? {

    func json() throws -> Any {
        switch self {
        case nil:
            NSNull()
        case let wrapped?:
            try wrapped.json()
        }
    }
}
