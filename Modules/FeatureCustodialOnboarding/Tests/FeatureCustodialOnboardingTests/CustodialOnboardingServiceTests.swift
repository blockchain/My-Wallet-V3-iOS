import Blockchain
@testable import BlockchainNamespace
@testable import FeatureCustodialOnboarding
import XCTest

@MainActor
final class CustodialOnboardingServiceTests: XCTestCase {

    var service: CustodialOnboardingService!
    var app: AppProtocol!

    override func setUp() async throws {
        try await super.setUp()
        try await app.transaction { app in
            try await app.set(blockchain.user.id, to: "Jim")
            try await app.set(blockchain.user.currency.preferred.fiat.display.currency, to: "GBP")
            try await app.set(blockchain.user.email.is.verified, to: false)
            try await app.set(blockchain.user.is.verified, to: false)
            try await app.set(blockchain.ux.user.custodial.onboarding.is.enabled, to: true)
            try await set(accounts: [])
        }
        service = CustodialOnboardingService()
    }

    override func invokeTest() {
        app = App.test
        withDependencies {
            $0.app = app
        } operation: {
            super.invokeTest()
        }
    }

    func set(accounts: [String]) async throws {
        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.custodial.crypto.with.balance,
            repository: { _ -> AnyJSON in AnyJSON(accounts) }
        )
    }

    func test_is_synchronized() async throws {
        await service.request().synchronize(on: self)
        XCTAssertTrue(service.isSynchronized)
    }

    func test_is_finished() async throws {

        try await set(accounts: ["BTC"])

        await service.request().synchronize(on: self)
        XCTAssertTrue(service.isFinished)
    }

    func test_is_finished_when_enabled() async throws {
        await service.request().synchronize(on: self)
        XCTAssertFalse(service.isFinished)
    }

    func test_is_finished_when_disabled() async throws {
        try await app.set(blockchain.ux.user.custodial.onboarding.is.enabled, to: false)
        await service.request().synchronize(on: self)
        XCTAssertTrue(service.isFinished)
    }

    func test_is_not_finished() async throws {

        try await set(accounts: [])

        await service.request().synchronize(on: self)
        XCTAssertFalse(service.isFinished)
    }

    func test_progress_0_3() async throws {
        await service.request().synchronize(on: self)
        XCTAssertEqual(service.progress, 0.d / 3.d, accuracy: .ulpOfOne)
    }

    func test_progress_1_3() async throws {

        try await app.set(blockchain.user.email.is.verified, to: true)

        await service.request().synchronize(on: self)
        XCTAssertEqual(service.progress, 1.d / 3.d, accuracy: .ulpOfOne)
    }

    func test_progress_1_3_alternative() async throws {

        try await app.set(blockchain.user.is.verified, to: true)

        await service.request().synchronize(on: self)
        XCTAssertEqual(service.progress, 1.d / 3.d, accuracy: .ulpOfOne)
    }

    func test_progress_2_3() async throws {

        try await app.set(blockchain.user.email.is.verified, to: true)
        try await app.set(blockchain.user.is.verified, to: true)

        await service.request().synchronize(on: self)
        XCTAssertEqual(service.progress, 2.d / 3.d, accuracy: .ulpOfOne)
    }

    func test_progress_3_3() async throws {

        try await app.set(blockchain.user.email.is.verified, to: true)
        try await app.set(blockchain.user.is.verified, to: true)
        try await set(accounts: ["BTC"])

        await service.request().synchronize(on: self)
        XCTAssertEqual(service.progress, 3.d / 3.d, accuracy: .ulpOfOne)
    }

    func test_state_for_verify_email() async throws {

        await service.request().synchronize(on: self)
        XCTAssertEqual(service.state(for: .verifyEmail), .highlighted)

        try await app.set(blockchain.user.email.is.verified, to: true)
        await Task.megaYield()
        XCTAssertEqual(service.state(for: .verifyEmail), .done)

        try await app.set(blockchain.user.email.is.verified, to: false)
        try await app.set(blockchain.user.is.verified, to: true)
        await Task.megaYield()
        XCTAssertEqual(service.state(for: .verifyEmail), .highlighted)
    }

    func test_state_for_verify_identity() async throws {

        await service.request().synchronize(on: self)
        XCTAssertEqual(service.state(for: .verifyIdentity), .todo)

        try await app.set(blockchain.user.email.is.verified, to: true)
        await Task.megaYield()
        XCTAssertEqual(service.state(for: .verifyIdentity), .highlighted)

        try await app.set(blockchain.user.is.verified, to: true)
        await Task.megaYield()
        XCTAssertEqual(service.state(for: .verifyIdentity), .done)
    }

    func test_state_for_purchase_crypto() async throws {

        await service.request().synchronize(on: self)
        XCTAssertEqual(service.state(for: .purchaseCrypto), .todo)

        try await app.set(blockchain.user.email.is.verified, to: true)
        await Task.megaYield()
        XCTAssertEqual(service.state(for: .purchaseCrypto), .todo)

        try await app.set(blockchain.user.is.verified, to: true)
        await Task.megaYield()
        XCTAssertEqual(service.state(for: .purchaseCrypto), .highlighted)
    }
}

extension Bindings {

    func synchronize(
        on object: some XCTestCase,
        timeout seconds: TimeInterval = .infinity
    ) async {
        let expectation = XCTestExpectation(description: #function)
        Task {
            for await _ in onSynchronization.stream {
                return expectation.fulfill()
            }
        }
        await object.fulfillment(of: [expectation], timeout: seconds)
    }
}
