@testable import BlockchainNamespace
import XCTest

class ComputeTestCase: XCTestCase {

    struct A: Decodable, Equatable {
        let int: Int?, bool: Bool?
    }

    var app: AppProtocol!
    var bindings: Bindings.ToObject<ComputeTestCase>!

    var int: Int?
    var string: String?
    var tag: Tag?
    var bool: Bool?
    var number: Double?

    override func setUp() {
        super.setUp()
        app = App.test
        bindings = app.binding(self)
    }

    func assert<T: Decodable & Equatable>(_ json: Any, equals value: T, file: StaticString = #filePath, line: UInt = #line) async throws {
        try await app.set(blockchain.db.type.any, to: json)
        let result = try await app.computed(blockchain.db.type.any, as: T.self).next()
        let actual = try result.get()
        XCTAssertEqual(actual, value, file: file, line: line)
    }

    func assert<T: Decodable & Equatable>(_ json: Any, as type: T.Type, throws: Bool, file: StaticString = #filePath, line: UInt = #line) async throws {
        let expectation = expectation(description: "\(`throws` ? "throws" : "does not throw") an error")
        do {
            try await app.set(blockchain.db.type.any, to: json)
            _ = try await app.computed(blockchain.db.type.any, as: T.self).next().get()
            if !`throws` { expectation.fulfill() }
        } catch where `throws` {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation])
    }

    func assert<T: Decodable & Equatable, E: Error & Equatable>(_ json: Any, as type: T.Type, throws specific: E, file: StaticString = #filePath, line: UInt = #line) async throws {
        let caught = expectation(description: "throws \(specific)")
        do {
            try await app.set(blockchain.db.type.any, to: json)
            _ = try await app.computed(blockchain.db.type.any, as: T.self).next().get()
        } catch let error as E {
            if error == specific {
                caught.fulfill()
            } else {
                throw error
            }
        }
        await fulfillment(of: [caught])
    }
}
