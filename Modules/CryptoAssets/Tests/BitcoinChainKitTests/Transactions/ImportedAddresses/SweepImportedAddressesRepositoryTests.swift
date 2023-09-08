// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import BlockchainNamespace

import XCTest

final class SweepImportedAddressesRepositoryTests: XCTestCase {

    let testApp = App.test

    override func setUp() {
        testApp.state.clear(blockchain.ux.sweep.imported.addresses.swept.addresses)
    }

    func test_sweep_imported_addresses_update() throws {

        let now = { Date() }

        let sut = SweepImportedAddressesRepository(app: testApp, now: now)

        sut.prepare()

        XCTAssertTrue(sut.sweptBalances.isEmpty)

        sut.update(result: .init(accountIdentifier: "a", result: .success(.noValue)))

        XCTAssertEqual(sut.sweptBalances.count, 1)
        XCTAssertEqual(sut.sweptBalances.first!, "a")

        let stored: [String]? = try? testApp.state.get(blockchain.ux.sweep.imported.addresses.swept.addresses)
        XCTAssertNotNil(stored)
        XCTAssertEqual(stored!.count, 1)
        XCTAssertEqual(stored!.first!, "a")
    }

    func test_sweep_imported_addresses_retrieves_stored() throws {

        let now = { Date() }

        let sut = SweepImportedAddressesRepository(app: testApp, now: now)

        testApp.state.set(blockchain.ux.sweep.imported.addresses.swept.addresses, to: ["a", "b"])

        sut.prepare()

        XCTAssertFalse(sut.sweptBalances.isEmpty)
        XCTAssertEqual(sut.sweptBalances, ["a", "b"])

        sut.update(result: .init(accountIdentifier: "c", result: .success(.noValue)))

        XCTAssertEqual(sut.sweptBalances.count, 3)
        XCTAssertEqual(sut.sweptBalances, ["a", "b", "c"])
    }

    func test_sweep_imported_addresses_clear_after_certain_threshold() throws {
        var mockDate = Date()

        let sut = SweepImportedAddressesRepository(app: testApp, now: { mockDate })

        sut.update(result: .init(accountIdentifier: "a", result: .success(.noValue)))
        sut.update(result: .init(accountIdentifier: "b", result: .success(.noValue)))

        // setting a day to 2 hours ago
        mockDate = Date(timeIntervalSinceNow: -(2 * 60 * 60))
        sut.setLastSweptAttempt()

        // on a new session

        let sut2 = SweepImportedAddressesRepository(app: testApp, now: { mockDate })
        // should clear any stored values
        sut2.prepare()

        XCTAssertEqual(sut2.sweptBalances, [])
        let stored = try? testApp.state.get(blockchain.ux.sweep.imported.addresses.swept.addresses, as: [String].self)
        XCTAssertNil(stored)
    }

    func test_sweep_imported_addresses_repo() throws {
        var mockDate = Date()

        let sut = SweepImportedAddressesRepository(app: testApp, now: { mockDate })

        sut.update(result: .init(accountIdentifier: "a", result: .success(.noValue)))
        sut.update(result: .init(accountIdentifier: "b", result: .success(.noValue)))

        // setting a day to 2 hours ago
        mockDate = Date(timeIntervalSinceNow: -(1 * 60 * 60))
        sut.setLastSweptAttempt()

        // on a new session

        let sut2 = SweepImportedAddressesRepository(app: testApp, now: { mockDate })
        // should *NOT* clear any stored values
        sut2.prepare()

        XCTAssertEqual(sut2.sweptBalances, ["a", "b"])
        let stored = try? testApp.state.get(blockchain.ux.sweep.imported.addresses.swept.addresses, as: [String].self)
        XCTAssertNotNil(stored)
        XCTAssertEqual(stored, ["a", "b"])
    }

    func test_sweep_imported_addresses_methods() throws {
        var mockDate = Date()
        let sut = SweepImportedAddressesRepository(app: testApp, now: { mockDate })

        sut.update(result: .init(accountIdentifier: "a", result: .success(.noValue)))
        // storing the same identifier skips the value
        sut.update(result: .init(accountIdentifier: "a", result: .success(.noValue)))
        XCTAssertEqual(sut.sweptBalances, ["a"])

        let stored = try? testApp.state.get(blockchain.ux.sweep.imported.addresses.swept.addresses, as: [String].self)
        XCTAssertEqual(stored!, ["a"])

        sut.update(result: .init(accountIdentifier: "b", result: .success(.noValue)))
        XCTAssertEqual(sut.sweptBalances, ["a", "b"])

        let stored2 = try? testApp.state.get(blockchain.ux.sweep.imported.addresses.swept.addresses, as: [String].self)
        XCTAssertEqual(stored2!, ["a", "b"])

        XCTAssertTrue(
            sut.contains(result: .init(accountIdentifier: "a", result: .success(.noValue)))
        )
    }
}
