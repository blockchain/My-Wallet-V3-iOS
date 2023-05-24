@testable import BlockchainNamespace
import XCTest

final class ComputeEvalTests: ComputeTestCase {

    func test_eval() async throws {
        let json = [
            "{returns}": [
                "eval": ["expression": "1 + 2 + 3 * 2"]
            ]
        ]
        try await assert(json, equals: 9)
    }

    func test_eval_with_context() async throws {
        let json = [
            "{returns}": [
                "eval": [
                    "expression": "1 + number * (2 - 3)",
                    "context": ["number": 2]
                ]
            ]
        ]
        try await assert(json, equals: -1)
    }

    func test_eval_error() async throws {
        let json = [
            "{returns}": [
                "eval": [
                    "expression": "1 + number * (2 - 3)",
                    "context": ["string": "n/a"]
                ]
            ]
        ]
        try await assert(json, as: Int.self, throws: AnyJSON.Error("ReferenceError: Can't find variable: number"))
    }

    func test_eval_from_reference() async throws {
        let json = [
            "{returns}": [
                "eval": [
                    "expression": "1 + number * (2 - 3)",
                    "context": ["number": ["{returns}": ["from": ["reference": "blockchain.db.type.number"]]]]
                ]
            ]
        ]
        try await app.set(blockchain.db.type.number, to: 2)
        try await assert(json, equals: -1)
    }
}
