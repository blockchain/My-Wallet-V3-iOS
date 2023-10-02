@testable import BlockchainNamespace
import XCTest

final class blockchain_ux_kyc_SSN_should_be_collected_Tests: ComputeTestCase {

    func test() async throws {

        let json = [
            "{returns}": [
                "yes": [
                    "if": [
                        [
                            "{returns}": [
                                "from": [
                                    "reference": blockchain.ux.kyc.SSN.is.enabled(\.id)
                                ]
                            ],
                            "default": false
                        ],
                        [
                            "{returns}": [
                                "from": [
                                    "reference": blockchain.api.nabu.gateway.onboarding.SSN.is.mandatory(\.id)
                                ]
                            ],
                            "default": false
                        ],
                        [
                            "{returns}": [
                                "comparison": [
                                    "equal": [
                                        "lhs": [
                                            "{returns}": [
                                                "from": [
                                                    "reference": blockchain.api.nabu.gateway.onboarding.SSN.state(\.id)
                                                ]
                                            ]
                                        ],
                                        "rhs": [
                                            "{returns}": [
                                                "language": [
                                                    "id": blockchain.api.nabu.gateway.onboarding.SSN.state.required(\.id)
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
        ]

        try await app.set(blockchain.ux.kyc.SSN.is.enabled, to: true)
        try await app.register(
            napi: blockchain.api.nabu.gateway.onboarding,
            domain: blockchain.api.nabu.gateway.onboarding.SSN,
            repository: { _ in
                AnyJSON(
                    [
                        "is": [
                            "mandatory": true
                        ],
                        "state": blockchain.api.nabu.gateway.onboarding.SSN.state.required(\.id)
                    ]
                )
            }
        )

        try await assert(json, equals: true)

        // Don't request when feature flag is disabled
        try await app.set(blockchain.ux.kyc.SSN.is.enabled, to: false)
        try await app.register(
            napi: blockchain.api.nabu.gateway.onboarding,
            domain: blockchain.api.nabu.gateway.onboarding.SSN,
            repository: { _ in
                AnyJSON(
                    [
                        "is": [
                            "mandatory": true
                        ],
                        "state": blockchain.api.nabu.gateway.onboarding.SSN.state.pending(\.id)
                    ]
                )
            }
        )

        try await assert(json, equals: false)

        // Don't request when pending
        try await app.set(blockchain.ux.kyc.SSN.is.enabled, to: true)
        try await app.register(
            napi: blockchain.api.nabu.gateway.onboarding,
            domain: blockchain.api.nabu.gateway.onboarding.SSN,
            repository: { _ in
                AnyJSON(
                    [
                        "is": [
                            "mandatory": true
                        ],
                        "state": blockchain.api.nabu.gateway.onboarding.SSN.state.pending(\.id)
                    ]
                )
            }
        )

        try await assert(json, equals: false)

        // Don't request when it's not mandatory
        try await app.set(blockchain.ux.kyc.SSN.is.enabled, to: true)
        try await app.register(
            napi: blockchain.api.nabu.gateway.onboarding,
            domain: blockchain.api.nabu.gateway.onboarding.SSN,
            repository: { _ in
                AnyJSON(
                    [
                        "is": [
                            "mandatory": false
                        ]
                    ]
                )
            }
        )

        try await assert(json, equals: false)
    }
}
