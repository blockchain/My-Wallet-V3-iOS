@testable import BlockchainNamespace
import XCTest

final class ComputeEitherTests: ComputeTestCase {

    func test_either() async throws {

        let json = [
            "{returns}": [
                "either": [
                    ["condition": false, "value": 1],
                    ["condition": true, "value": 2]
                ]
            ]
        ]

        try await assert(json, equals: 2)
    }

    func test_either_composed() async throws {
        let json = [
            "{returns}": [
                "either": [
                    "{returns}": [
                        "this": [
                            "value": [
                                [
                                    "condition": false,
                                    "value": 1
                                ],
                                [
                                    "{returns}": [
                                        "this": [
                                            "value": [
                                                "condition": [
                                                    "{returns}": [
                                                        "this": [
                                                            "value": true
                                                        ]
                                                    ]
                                                ],
                                                "value": 2
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        try await assert(json, equals: 2)
    }

    func test_either_comparison() async throws {
        let json = [
            "{returns}": [
                "either": [
                    [
                        "condition": [
                            "{returns}": [
                                "comparison": [
                                    "less": [
                                        "lhs": ["{returns}": ["count": ["of": ["{returns}": ["from": ["reference": blockchain.db.array(\.id)]]]]]],
                                        "rhs": 1
                                    ]
                                ]
                            ]
                        ],
                        "value": 1
                    ],
                    [
                        "condition": [
                            "{returns}": [
                                "comparison": [
                                    "greater": [
                                        "lhs": ["{returns}": ["count": ["of": ["{returns}": ["from": ["reference": blockchain.db.array(\.id)]]]]]],
                                        "rhs": 1
                                    ]
                                ]
                            ]
                        ],
                        "value": 2
                    ]
                ]
            ]
        ]

        try await app.set(blockchain.db.array, to: (1...9).array)
        try await assert(json, equals: 2)
    }
}
