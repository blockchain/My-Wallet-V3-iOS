@testable import BlockchainNamespace
import XCTest

final class ComputeReferenceTests: ComputeTestCase {

    func test_from() async throws {

        app.signIn(userId: "Oliver")
        app.state.set(blockchain.user.is.cowboy.fan, to: true)

        let json = ["{returns}": ["from": ["reference": blockchain.user.is.cowboy.fan(\.id)]]]

        try await app.set(blockchain.db.type.any, to: json)

        var expected = true
        var count = 0
        for await result in app.computed(blockchain.db.type.any, as: Bool.self) {
            try XCTAssertEqual(result.get(), expected)
            expected.toggle()
            count += 1
            app.state.set(blockchain.user.is.cowboy.fan, to: expected)
            if count > 5 { break }
        }
    }

    func test_from_recursive() async throws {

        let json = [
            "bool": [
                "{returns}": [
                    "this": [
                        "value": [
                            "{returns}": [
                                "from": ["reference": "blockchain.db.type.boolean"]
                            ]
                        ]
                    ]
                ]
            ],
            "int": [
                "{returns}": [
                    "this": [
                        "value": [
                            "{returns}": [
                                "this": [
                                    "value": [
                                        "{returns}": [
                                            "from": ["reference": "blockchain.db.type.integer"]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        "condition": [
                            "{returns}": [
                                "this": [
                                    "value": true
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        try await app.set(blockchain.db.type.boolean, to: true)
        try await app.set(blockchain.db.type.integer, to: 0)
        try await app.set(blockchain.db.type.any, to: json)

        let stream = app.computed(blockchain.db.type.any, as: A.self)

        do {
            let snapshot = try await stream.next().get()
            XCTAssertEqual(snapshot, A(int: 0, bool: true))
        }

        do {
            try await app.set(blockchain.db.type.boolean, to: false)
            let snapshot = try await stream.next().get()
            XCTAssertEqual(snapshot, A(int: 0, bool: false))
        }

        do {
            try await app.set(blockchain.db.type.integer, to: 2)
            let snapshot = try await stream.next().get()
            XCTAssertEqual(snapshot, A(int: 2, bool: false))
        }

        do {
            try await app.set(blockchain.db.type.integer, to: 3)
            let snapshot = try await stream.next().get()
            XCTAssertEqual(snapshot, A(int: 3, bool: false))
        }

        do {
            try await  app.set(blockchain.db.type.boolean, to: true)
            let snapshot = try await stream.next().get()
            XCTAssertEqual(snapshot, A(int: 3, bool: true))
        }
    }

    func test_from_context() async throws {
        let json = [
            "{returns}": [
                "from": [
                    "reference": blockchain.user.is.cowboy.fan(\.id),
                    "context": [blockchain.user.id(\.id): "Clement"]
                ]
            ]
        ]
        try await assert(json, as: Bool.self, throws: true)
        try await app.set(blockchain.user["Clement"].is.cowboy.fan, to: true)
        try await assert(json, equals: true)
    }
}
