@testable import BlockchainNamespace
import XCTest

final class ComputeMapTests: ComputeTestCase {

    func test_map_identity() async throws {
        try await assert(["{returns}": ["map": ["src": 1]]], equals: 1)
    }

    func test_map_declared_identity() async throws {
        let json = [
            "{returns}": [
                "map": [
                    "src": 1,
                    "copy": [
                        ["value": ["{returns}": ["item": []]], "to": []]
                    ]
                ]
            ]
        ]
        try await assert(json, equals: 1)
    }

    func test_map_nesting_identity() async throws {
        let json = [
            "{returns}": [
                "map": [
                    "src": 1,
                    "dst": [:],
                    "copy": [
                        ["value": ["{returns}": ["item": []]], "to": ["int"]]
                    ]
                ]
            ]
        ]
        try await assert(json, equals: ["int": 1])
    }

    func test_map_nested_identity() async throws {
        let json = [
            "{returns}": [
                "map": [
                    "src": ["way": ["to": ["my": ["heart": 42]]]],
                    "dst": [:],
                    "copy": [
                        ["value": ["{returns}": ["item": ["way", "to", "my", "heart"]]], "to": ["int"]]
                    ]
                ]
            ]
        ]
        try await assert(json, equals: ["int": 42])
    }

    func test_map() async throws {
        let json = [
            "{returns}": [
                "map": [
                    "src": ["rectangle": [1, 2, 3, 4]],
                    "dst": [:],
                    "copy": [
                        ["value": ["{returns}": ["item": ["rectangle", 0]]], "to": ["origin", "x"]],
                        ["value": ["{returns}": ["item": ["rectangle", 1]]], "to": ["origin", "y"]],
                        ["value": ["{returns}": ["item": ["rectangle", 2]]], "to": ["size", "width"]],
                        ["value": ["{returns}": ["item": ["rectangle", 3]]], "to": ["size", "height"]]
                    ]
                ]
            ]
        ]

        struct Rectangle: Equatable, Decodable {
            let origin: Point; struct Point: Equatable, Decodable {
                let x, y: Int
            }

            let size: Size; struct Size: Equatable, Decodable {
                let width, height: Int
            }
        }

        try await assert(json, equals: Rectangle(origin: .init(x: 1, y: 2), size: .init(width: 3, height: 4)))
    }
}
