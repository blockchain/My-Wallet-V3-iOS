@testable import BlockchainNamespace
import XCTest

final class ComputeComparisonTests: ComputeTestCase {

    func test_comparison_not() async throws {
        try await assert(["{returns}": ["not": false]], equals: true)
        try await assert(["{returns}": ["not": true]], equals: false)
        try await assert(["{returns}": ["not": ["{returns}": ["comparison": ["equal": ["lhs": 1, "rhs": 1]]]]]], equals: false)
        try await assert(["{returns}": ["not": ["{returns}": ["comparison": ["equal": ["lhs": 1, "rhs": 2]]]]]], equals: true)
    }

    func test_comparison_equal() async throws {
        try await assert(["{returns}": ["comparison": ["equal": ["lhs": 1, "rhs": 1]]]], equals: true)
        try await assert(["{returns}": ["not": ["{returns}": ["comparison": ["equal": ["lhs": 1, "rhs": 2]]]]]], equals: true)
        try await assert(["{returns}": ["comparison": ["equal": ["lhs": "42", "rhs": "42"]]]], equals: true)
        try await assert(["{returns}": ["comparison": ["equal": ["lhs": 42, "rhs": "42"]]]], equals: true)
        try await assert(["{returns}": ["comparison": ["equal": ["lhs": (1...9).array, "rhs": (1...9).array]]]], equals: true)
        try await assert(["{returns}": ["comparison": ["equal": ["lhs": blockchain.db.type.string[], "rhs": "blockchain.db.type.string"]]]], equals: true)
    }

    func test_comparison_match() async throws {
        try await assert(["{returns}": ["comparison": ["match": ["lhs": "Hello World", "rhs": "Hel{2}o\\sWorld"]]]], equals: true)
        try await assert(["{returns}": ["comparison": ["match": ["lhs": "Bye World", "rhs": "Hel{2}o\\sWorld"]]]], equals: false)
    }

    func test_comparison_less() async throws {
        try await assert(["{returns}": ["comparison": ["less": ["lhs": 1, "rhs": 2]]]], equals: true)
        try await assert(["{returns}": ["comparison": ["less": ["lhs": 1, "rhs": 1]]]], equals: false)
        try await assert(["{returns}": ["comparison": ["less": ["lhs": 1, "rhs": 0]]]], equals: false)
    }

    func test_comparison_greater() async throws {
        try await assert(["{returns}": ["comparison": ["greater": ["lhs": 1, "rhs": 2]]]], equals: false)
        try await assert(["{returns}": ["comparison": ["greater": ["lhs": 1, "rhs": 1]]]], equals: false)
        try await assert(["{returns}": ["comparison": ["greater": ["lhs": 1, "rhs": 0]]]], equals: true)
    }

    func test_comparison() async throws {
        let json = [
            "{returns}": [
                "comparison": [
                    "equal": [
                        "lhs": "Oliver",
                        "rhs": ["{returns}": ["from": ["reference": blockchain.db.type.string(\.id)]]]
                    ]
                ]
            ]
        ]
        try await app.set(blockchain.db.type.string, to: "Oliver")
        try await assert(json, equals: true)
        try await app.set(blockchain.db.type.string, to: "Augustin")
        try await assert(json, equals: false)
    }
}
