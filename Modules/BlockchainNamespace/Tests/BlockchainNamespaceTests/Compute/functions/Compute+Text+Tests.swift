@testable import BlockchainNamespace
import XCTest

final class ComputeTextTests: ComputeTestCase {

    func test_joining_default() async throws {
        let json = [
            "{returns}": [
                "text": [
                    "by": ["joining": ["array": ["Hello", "World!"]]]
                ]
            ]
        ]
        try await assert(json, equals: "Hello World!")
    }

    func test_joining_separator() async throws {
        let json = [
            "{returns}": [
                "text": [
                    "by": ["joining": ["array": ["Hello", "World!"], "separator": "_"]]
                ]
            ]
        ]
        try await assert(json, equals: "Hello_World!")
    }

    func test_joining_terminator() async throws {
        let json = [
            "{returns}": [
                "text": [
                    "by": ["joining": ["array": ["Hello", "World!"], "terminator": "!"]]
                ]
            ]
        ]
        try await assert(json, equals: "Hello World!!")
    }

    func test_joining_with_reference() async throws {
        let json = [
            "{returns}": [
                "text": [
                    "by": [
                        "joining": [
                            "array": [
                                "Good Morning",
                                ["{returns}": ["from": ["reference": blockchain.user.name.first(\.id)]]]
                            ],
                            "terminator": "!"
                        ]
                    ]
                ]
            ]
        ]
        app.signIn(userId: "mock-user-id")
        try await app.set(blockchain.user.name.first, to: "FirstName")
        try await app.set(blockchain.user.name.last, to: "LastName")
        try await assert(json, equals: "Good Morning FirstName!")
    }
}
