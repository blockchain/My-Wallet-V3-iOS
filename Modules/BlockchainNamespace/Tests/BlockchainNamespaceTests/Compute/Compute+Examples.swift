@testable import BlockchainNamespace
import XCTest

final class ComputeExamples: ComputeTestCase {

    func test_version_check() async throws {
        let json = [
            "{returns}": [
                "comparison": [
                    "less": [
                        "lhs": ["{returns}": ["from": ["reference": blockchain.ui.device.os.version(\.id)]]],
                        "rhs": "15"
                    ]
                ]
            ]
        ]

        // "16.0.2" < "15" == false
        try await app.set(blockchain.ui.device.os.version, to: "16.0.2")
        try await assert(json, equals: false)

        // "14.2.3" < "15" == true
        try await app.set(blockchain.ui.device.os.version, to: "14.2.3")
        try await assert(json, equals: true)
    }

    func test_receive_frequent_action() async throws {
        let json = [
            "then": [
                "enter": [
                    "into": [
                        "{returns}": [
                            "this": [
                                "value": blockchain.ux.user.KYC(\.id),
                                "condition": ["{returns}": ["not": ["{returns}": ["from": ["reference": blockchain.user.is.verified(\.id)]]]]]
                            ]
                        ],
                        "default": blockchain.ux.currency.receive.address(\.id)
                    ]
                ]
            ]
        ]

        app.signIn(userId: "dimitris")

        try await app.transaction { app in
            app.state.set(blockchain.ux.asset.id, to: "BTC")
            try await app.set(blockchain.ux.asset.receive, to: json)
        }

        bindings.subscribe(\.tag, to: blockchain.ux.asset.receive.then.enter.into)
        await bindings.request().synchronize()

        try await app.set(blockchain.user.is.verified, to: true)
        XCTAssertEqual(tag, blockchain.ux.currency.receive.address[])

        try await app.set(blockchain.user.is.verified, to: false)
        XCTAssertEqual(tag, blockchain.ux.user.KYC[])
    }
}
