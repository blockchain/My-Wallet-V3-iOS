@testable import BlockchainNamespace
import XCTest

final class ComputeCountTests: ComputeTestCase {

    func test_count_of_array() async throws {
        try await assert(["{returns}": ["count": ["of": [1, 2, 3]]]], equals: 3)
    }

    func test_count_of_null() async throws {
        try await assert(["{returns}": ["count": ["of": NSNull()]]], equals: 0)
    }

    func test_count_of_dictionary() async throws {
        try await assert(["{returns}": ["count": ["of": ["a": 1, "b": 2]]]], equals: 2)
    }

    func test_count_of_string() async throws {
        try await assert(["{returns}": ["count": ["of": "Hello World!"]]], equals: 12)
    }

    func test_count_of_reference() async throws {
        try await app.set(blockchain.db.type.string, to: "Hello World!")
        try await assert(["{returns}": ["count": ["of": ["{returns}": ["from": ["reference": "blockchain.db.type.string"]]]]]], equals: 12)
    }

    func test_count_of_missing_reference() async throws {
        try await assert(["{returns}": ["count": ["of": ["{returns}": ["from": ["reference": "blockchain.db.type.string"]]]]]], equals: 0)
    }
}
