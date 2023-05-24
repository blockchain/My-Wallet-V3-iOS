@testable import BlockchainNamespace
import XCTest

final class ComputeTests: ComputeTestCase {

    func test_item() async throws {
        let json = [
            "{returns}": [
                "item": ["the", "meaning", "of", "life"] as [Any]
            ]
        ]

        try await assert(json, as: String.self, throws: true)
        try await Compute.withContext { context in
            context.element = ["the": ["meaning": ["of": ["life": "forty_two"]]]]
        } operation: {
            try await assert(json, equals: "forty_two")
        }
        try await assert(json, as: String.self, throws: true)
    }

    func test_item_with_context() async throws {
        try await Compute.withContext { context in
            context.element = "context-through-bindings"
        } operation: {
            try await assert(["{returns}": ["item": []]], equals: "context-through-bindings")
        }
    }

    func test_item_with_context_direct_encoding() throws {
        let string = try Compute.withContext { context in
            context.element = "context-through-decoding"
        } operation: {
            try Compute.Item.from([] as [Any]).compute()
        }

        XCTAssertEqual(string as? String, "context-through-decoding")
    }

    func test_item_with_no_context_direct_encoding() throws {
        XCTAssertThrowsError(try Compute.Item.from([] as [Any]).compute())
    }
}
