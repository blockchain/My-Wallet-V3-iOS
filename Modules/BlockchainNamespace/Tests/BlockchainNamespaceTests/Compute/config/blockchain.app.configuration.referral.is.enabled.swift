@testable import BlockchainNamespace
import XCTest

final class blockchain_app_configuration_referral_is_enabled_Tests: ComputeTestCase {

    func test() async throws {

        app.signIn(userId: "test")

        let json = [
            "{returns}": [
                "not": [
                    "{returns}": [
                        "comparison": [
                            "equal": [
                                "lhs": [
                                    "{returns}": [
                                        "from": ["reference": "blockchain.user.address.country.code"]
                                    ]
                                ],
                                "rhs": "GB"
                            ]
                        ]
                    ]
                ]
            ],
            "default": true
        ] as [String: Any]

        // Enabled ROW
        try await app.set(blockchain.user.address.country.code, to: "US")
        try await assert(json, equals: true)

        // Disabled UK
        try await app.set(blockchain.user.address.country.code, to: "GB")
        try await assert(json, equals: false)

        // Fallback is Enabled
        try await app.set(blockchain.user.address.country.code, to: nil)
        try await assert(json, equals: true)
    }
}
