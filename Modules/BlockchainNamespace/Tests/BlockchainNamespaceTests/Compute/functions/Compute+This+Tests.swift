@testable import BlockchainNamespace
import XCTest

final class ComputeThisTests: ComputeTestCase {

    func test_this_value() async throws {
        try await assert(["{returns}": ["this": ["value": "five"]]], equals: "five")
    }

    func test_this_value_with_condition() async throws {
        try await assert(["{returns}": ["this": ["value": 42, "condition": true]]], equals: 42)
    }

    func test_this_value_with_false_condition() async throws {
        try await assert(["{returns}": ["this": ["value": 42, "condition": false]], "default": "forty_two"], equals: "forty_two")
    }

    func test_this_recursive() async throws {

        let json = [
            "{returns}": [
                "this": [
                    "value": ["{returns}": ["this": ["value": 42, "condition": true]]],
                    "condition": ["{returns}": ["this": ["value": true]]]
                ]
            ]
        ]

        try await assert(json, equals: 42)
    }

    func test_this_recursive_false() async throws {
        let json = ["{returns}": ["this": ["value": ["{returns}": ["this": ["value": 42, "condition": false]]], "condition": true]]]
        try await assert(json, as: Int.self, throws: true)
    }
}
