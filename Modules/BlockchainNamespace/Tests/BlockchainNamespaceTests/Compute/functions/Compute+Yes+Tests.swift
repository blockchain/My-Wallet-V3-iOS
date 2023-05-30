@testable import BlockchainNamespace
import XCTest

final class ComputeYesTests: ComputeTestCase {

    func test_yes() async throws {
        let json = [
            "{returns}": [
                "yes": [
                    "if": [true, true],
                    "unless": [false, false]
                ]
            ]
        ]
        try await assert(json, equals: true)
    }

    func test_yes_this() async throws {
        let json = [
            "{returns}": [
                "yes": [
                    "if": [true, true],
                    "unless": [
                        "{returns}": [
                            "this": [
                                "value": [false, false]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        try await assert(json, equals: true)
    }

    func test_yes_this_unless() async throws {
        let json = [
            "{returns}": [
                "yes": [
                    "if": [true, true],
                    "unless": [
                        [
                            "{returns}": [
                                "yes": [
                                    "unless": [true]
                                ]
                            ]
                        ],
                        false
                    ]
                ]
            ]
        ]

        try await assert(json, equals: true)
    }

    func test_yes_this_unless_nested() async throws {
        let json = [
            "{returns}": [
                "yes": [
                    "if": [true, true],
                    "unless": [
                        "{returns}": [
                            "this": [
                                "value": [
                                    [
                                        "{returns}": [
                                            "yes": [
                                                "unless": [true]
                                            ]
                                        ]
                                    ],
                                    false
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        try await assert(json, equals: true)
    }
}
