@testable import BlockchainNamespace
import XCTest

final class BindingsTests: XCTestCase {

    var app: AppProtocol!
    var bindings: Bindings.ToObject<BindingsTests>!

    var int: Int?
    var string: String?
    var tag: Tag?
    var bool: Bool?
    var number: Double?

    override func setUp() {
        super.setUp()
        app = App.test
        bindings = app.binding(self)
    }

    func test_bindings() async throws {

        try await app.transaction { app in
            try await app.set(blockchain.db.type.integer, to: 1)
            try await app.set(blockchain.db.type.string, to: "Hello World!")
            try await app.set(blockchain.db.type.tag, to: blockchain.db.type.tag.none[])
            try await app.set(blockchain.db.type.boolean, to: true)
            try await app.set(blockchain.db.type.number, to: 1.2)
        }

        bindings
            .subscribe(\.int, to: blockchain.db.type.integer)
            .subscribe(\.string, to: blockchain.db.type.string)
            .subscribe(\.tag, to: blockchain.db.type.tag)
            .subscribe(\.bool, to: blockchain.db.type.boolean)
            .subscribe(\.number, to: blockchain.db.type.number)

        await bindings.requestThenSynchronize()

        XCTAssertEqual(int, 1)
        XCTAssertEqual(string, "Hello World!")
        XCTAssertEqual(tag, blockchain.db.type.tag.none[])
        XCTAssertEqual(bool, true)
        XCTAssertEqual(number, 1.2)
    }

    func test_bindings_fail_to_synchronize_number() async throws {

        try await app.transaction { app in
            try await app.set(blockchain.db.type.integer, to: 1)
            try await app.set(blockchain.db.type.number, to: "not a number")
        }

        bindings
            .subscribe(\.int, to: blockchain.db.type.integer)
            .subscribe(\.number, to: blockchain.db.type.number)

        await bindings.requestThenSynchronize()

        XCTAssertNotNil(int)
        XCTAssertNil(number)
    }

    func test_bindings_subscription() async throws {

       try await app.set(blockchain.db.type.integer, to: 1)

        bindings.subscribe(\.int, to: blockchain.db.type.integer)

        await bindings.requestThenSynchronize()

        XCTAssertEqual(int, 1)

        try await app.set(blockchain.db.type.integer, to: 2)
        XCTAssertEqual(int, 2)

        try await app.set(blockchain.db.type.integer, to: 3)
        XCTAssertEqual(int, 3)

        bindings.unsubscribe()

        try await app.set(blockchain.db.type.integer, to: 4)
        XCTAssertNotEqual(int, 4)
    }

    func test_bindings_compute() async throws {

        try await app.set(blockchain.db.array, to: (1...9).array)
        try await app.set(blockchain.db.type.integer, to: ["{returns}": ["count": ["of": ["{returns}": ["from": ["reference": blockchain.db.array(\.id)]]]]]])

        bindings.subscribe(\.int, to: blockchain.db.type.integer)
        await bindings.requestThenSynchronize()

        XCTAssertEqual(int, 9)
    }
}

extension Bindings.ToObject where Object: XCTestCase {

    func requestThenSynchronize(timeout seconds: TimeInterval = .infinity) async {
        guard let object else { return }
        let expectation = XCTestExpectation(description: #function)
        Task {
            request()
            for await _ in _bindings.onSynchronization.stream {
                return expectation.fulfill()
            }
        }
        await object.fulfillment(of: [expectation], timeout: seconds)
    }
}
