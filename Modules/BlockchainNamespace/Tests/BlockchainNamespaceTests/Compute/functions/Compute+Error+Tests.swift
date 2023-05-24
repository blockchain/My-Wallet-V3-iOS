@testable import BlockchainNamespace
import XCTest

final class ComputeErrorTests: ComputeTestCase {

    func test_error() async throws {
        try await assert(["{returns}": ["error": ["message": "this is an error"]]], as: Int.self, throws: AnyJSON.Error("this is an error"))
    }

    func test_error_no_default() async throws {
        try await assert(["{returns}": ["string": "five"]], as: String.self, throws: true)
    }

    func test_error_with_default() async throws {
        try await assert(["{returns}": ["string": "five"], "default": 5], equals: 5)
    }

    func test_error_missing_compute_keyword() async throws {
        try await assert(["{returns}": ["missing": []]], as: Int.self, throws: AnyJSON.Error("Expected {returns} keyword, but got missing"))
    }
}
