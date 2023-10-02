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

    func test_default_with_compute() async throws {
        try await app.set(blockchain.db.type.string, to: "b")

        let json = [
            "{returns}": [
                "this": [
                    "value": "a",
                    "condition": false
                ]
            ],
            "default": [
                "{returns}": [
                    "from": [
                        "reference": "blockchain.db.type.string"
                    ]
                ]
            ]
        ]

        try await assert(json, equals: "b")
    }

    func test_skata() async throws {

        try await app.set(blockchain.db.type.array.of.strings, to: [String]())

        let reference = [
            "{returns}": [
                "from": [
                    "reference": "blockchain.db.type.array.of.strings"
                ]
            ]
        ]

        try await assert(reference, equals: [String]())

        let count = [
            "{returns}": [
                "count": [
                    "of": [
                        "{returns}": [
                            "from": [
                                "reference": "blockchain.db.type.array.of.strings"
                            ]
                        ]
                    ]
                ]
            ]
        ]

        try await assert(count, equals: 0)

        let comparison = [
            "{returns}": [
                "comparison": [
                    "equal": [
                        "lhs": [
                            "{returns}": [
                                "count": [
                                    "of": [
                                        "{returns}": [
                                            "from": [
                                                "reference": "blockchain.db.type.array.of.strings"
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        "rhs": 0
                    ]
                ]
            ]
        ]

        try await assert(comparison, equals: true)

        let json = [
            "{returns}": [
                "this": [
                    "value": ["a"],
                    "condition": [
                        "{returns}": [
                            "comparison": [
                                "equal": [
                                    "lhs": [
                                        "{returns}": [
                                            "count": [
                                                "of": [
                                                    "{returns}": [
                                                        "from": [
                                                            "reference": "blockchain.db.type.array.of.strings"
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ],
                                    "rhs": 0
                                ]
                            ]
                        ]
                    ]
                ]
            ],
            "default": ["b"]
        ] as [String: Any]

        try await assert(json, equals: ["a"])
    }

    func test_this_recursive_false() async throws {
        let json = ["{returns}": ["this": ["value": ["{returns}": ["this": ["value": 42, "condition": false]]], "condition": true]]]
        try await assert(json, as: Int.self, throws: true)
    }
}
