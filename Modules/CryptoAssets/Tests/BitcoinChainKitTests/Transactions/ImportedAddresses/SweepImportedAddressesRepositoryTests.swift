// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import BlockchainNamespace

import Combine
import XCTest

final class SweepImportedAddressesRepositoryTests: XCTestCase {

    let testApp = App.test
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        testApp.state.clear(blockchain.ux.sweep.imported.addresses.swept.addresses)
        cancellables = []
    }

    func test_sweep_imported_addresses_update() throws {

        let now = { Date() }

        let sut = SweepImportedAddressesRepository(app: testApp, now: now)

        let expectation = self.expectation(description: "whoa")

        sut.prepare()
            .sink { value in
                XCTAssertTrue(value.isEmpty)
                XCTAssertTrue(sut.sweptBalances.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)

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

        let expectation = self.expectation(description: "whoa")

        sut.prepare()
            .sink { value in
                XCTAssertFalse(value.isEmpty)
                XCTAssertEqual(value, ["a", "b"])
                XCTAssertFalse(sut.sweptBalances.isEmpty)
                XCTAssertEqual(sut.sweptBalances, ["a", "b"])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)

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
        let expectation = self.expectation(description: "whoa")
        sut2.prepare()
            .sink { value in
                XCTAssertEqual(value, [])
                XCTAssertEqual(sut2.sweptBalances, [])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)

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
        let expectation = self.expectation(description: "whoa")
        sut2.prepare()
            .sink { value in
                XCTAssertEqual(value, ["a", "b"])
                XCTAssertEqual(sut2.sweptBalances, ["a", "b"])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)

        let stored = try? testApp.state.get(blockchain.ux.sweep.imported.addresses.swept.addresses, as: [String].self)
        XCTAssertNotNil(stored)
        XCTAssertEqual(stored, ["a", "b"])
    }

    func test_sweep_imported_addresses_methods() throws {
        let mockDate = Date()
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
