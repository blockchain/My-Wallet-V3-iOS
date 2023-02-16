// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
@testable import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import TestKit
import XCTest

final class SubscriptionsStateServiceTests: XCTestCase {

    enum TestData {
        static let entry0 = SubscriptionEntry(
            account: SubscriptionEntry.Account(index: 0, name: "0"),
            currency: "0",
            pubKeys: [SubscriptionEntry.PubKey(pubKey: "0", style: "0", descriptor: 0)]
        )
        static let entry1 = SubscriptionEntry(
            account: SubscriptionEntry.Account(index: 1, name: "1"),
            currency: "1",
            pubKeys: [SubscriptionEntry.PubKey(pubKey: "1", style: "1", descriptor: 1)]
        )
        static let event = blockchain.app.configuration.pubkey.service.auth
    }

    var cancellables: Set<AnyCancellable>!
    var subject: SubscriptionsStateServiceAPI!
    var app: AppProtocol!

    override func setUp() {
        super.setUp()
        app = App.test
        subject = SubscriptionsStateService(
            app: app
        )
        cancellables = []
    }

    override func tearDown() {
        app.state.set(TestData.event, to: nil)
        super.tearDown()
    }

    func testNullState() {
        app.state.set(TestData.event, to: nil)
        run(name: "test null state - empty array", input: [], expectedValue: true)
        run(name: "test null state - array", input: [TestData.entry0], expectedValue: false)
    }

    func testEmptyState() {
        app.state.set(TestData.event, to: [])
        run(name: "test empty state - empty array", input: [], expectedValue: true)
        run(name: "test empty state - array", input: [TestData.entry0], expectedValue: false)
    }

    func testGarbageState() {
        app.state.set(TestData.event, to: "unexpected type")
        run(name: "test garbage state - empty array", input: [], expectedValue: true)
        run(name: "test garbage state - array", input: [TestData.entry0], expectedValue: false)
    }

    func testValidStateCompleteMatch() {
        app.state.set(TestData.event, to: [TestData.entry0, TestData.entry1])
        run(
            name: "test valid state - complete match",
            input: [TestData.entry0, TestData.entry1],
            expectedValue: true
        )
    }

    func testValidStatePartialMatch() {
        app.state.set(TestData.event, to: [TestData.entry0, TestData.entry1])
        run(
            name: "test valid state - partial match",
            input: [TestData.entry0],
            expectedValue: true
        )
    }

    func testValidStateEmptyArray() {
        app.state.set(TestData.event, to: [TestData.entry0, TestData.entry1])
        run(name: "test valid state - empty array", input: [], expectedValue: true)
    }

    func testValidStateNoMatch() {
        app.state.set(TestData.event, to: [TestData.entry0])
        run(
            name: "test valid state - no match",
            input: [TestData.entry1],
            expectedValue: false
        )
    }

    func run(name: String, input: [SubscriptionEntry], expectedValue: Bool) {
        let expectation = expectation(description: name)
        var error: Error?
        var receivedValue: Bool?
        subject.isSubscribed(to: input)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failureError):
                        error = failureError
                    }
                },
                receiveValue: { value in
                    receivedValue = value
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        waitForExpectations(timeout: 5)
        XCTAssertNil(error)
        XCTAssertNotNil(receivedValue)
        XCTAssertEqual(receivedValue, expectedValue)
    }
}
