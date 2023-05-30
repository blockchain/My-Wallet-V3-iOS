@testable import BlockchainNamespace
import XCTest

final class ComputeExistsTests: ComputeTestCase {

    func test_exists() async throws {
        let json = [
            "{returns}": [
                "exists": [
                    "value": ["{returns}": ["from": ["reference": blockchain.db.type.string(\.id)]]]
                ]
            ]
        ]
        try await app.set(blockchain.db.type.string, to: "Hello World!")
        try await assert(json, equals: true)
    }

    func test_exists_toggle() async throws {

        let json = [
            "{returns}": [
                "exists": [
                    "value": ["{returns}": ["from": ["reference": blockchain.db.type.string(\.id)]]]
                ]
            ]
        ]

        try await app.set(blockchain.db.type.any, to: json)

        var expected = false
        for try await value in app.computed(blockchain.db.type.any, as: Bool.self) {
            try XCTAssertEqual(value.get(), expected)
            if expected { break }
            expected.toggle()
            try await app.set(blockchain.db.type.string, to: "Hello World!")
        }
    }
}
