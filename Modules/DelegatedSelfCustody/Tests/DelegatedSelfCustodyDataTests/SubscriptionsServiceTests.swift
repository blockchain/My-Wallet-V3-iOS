// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import TestKit
import XCTest

final class SubscriptionsServiceTests: XCTestCase {

    enum TestData {
        static let account = Account(
            coin: .bitcoin,
            derivationPath: "derivationPath",
            style: "style",
            publicKey: Data(hex: "0x01"),
            privateKey: Data(hex: "0x02")
        )
        static let subscriptionEntry = SubscriptionEntry(
            currency: "BTC",
            account: .init(index: 0, name: "DeFi Wallet"),
            pubKeys: [
                .init(pubKey: "01", style: "style", descriptor: 0)
            ]
        )

        static let guid = "guid"
        static let guidHash = "guidHash"
        static let sharedKeyHash = "sharedKeyHash"
    }

    var cancellables: Set<AnyCancellable>!
    var subject: DelegatedCustodySubscriptionsServiceAPI!
    var accountRepository: AccountRepositoryMock!
    var subscriptionsStateService: SubscriptionsStateServiceMock!
    var authenticationDataRepository: AuthenticationDataRepositoryMock!
    var authenticationClient: AuthenticationClientMock!
    var subscriptionsClient: SubscriptionsClientMock!

    override func setUp() {
        accountRepository = AccountRepositoryMock()
        subscriptionsStateService = SubscriptionsStateServiceMock()
        authenticationDataRepository = AuthenticationDataRepositoryMock()
        authenticationClient = AuthenticationClientMock()
        subscriptionsClient = SubscriptionsClientMock()
        subject = SubscriptionsService(
            accountRepository: accountRepository,
            authClient: authenticationClient,
            authenticationDataRepository: authenticationDataRepository,
            subscriptionsClient: subscriptionsClient,
            subscriptionsStateService: subscriptionsStateService
        )
        cancellables = []
        authenticationDataRepository.initialAuthenticationDataResult = .success(
            (guid: TestData.guid, sharedKeyHash: TestData.sharedKeyHash)
        )
        authenticationDataRepository.authenticationDataResult = .success(
            (guidHash: TestData.guidHash, sharedKeyHash: TestData.sharedKeyHash)
        )
        super.setUp()
    }

    func testSuccessfullySubscribesWhenValidationFails() {
        accountRepository.result = .success([TestData.account])
        subscriptionsStateService.result = .success(false)
        authenticationClient.authResult = .success(())
        subscriptionsClient.subscribeResult = .success(())

        run(name: "test successfully subscribes when validation fails", expectedDidComplete: true)

        XCTAssertEqual(authenticationClient.authParams.guid, TestData.guid)
        XCTAssertEqual(authenticationClient.authParams.sharedKeyHash, TestData.sharedKeyHash)

        XCTAssertEqual(subscriptionsClient.subscribeParams.guidHash, TestData.guidHash)
        XCTAssertEqual(subscriptionsClient.subscribeParams.sharedKeyHash, TestData.sharedKeyHash)
        XCTAssertEqual(subscriptionsClient.subscribeParams.subscriptions, [TestData.subscriptionEntry])

        XCTAssertEqual(subscriptionsStateService.recordSubscriptionParamsAccounts, ["BTC"])
    }

    func testSkipsWhenValidationSucceeds() {
        accountRepository.result = .success([TestData.account])
        subscriptionsStateService.result = .success(true)

        run(name: "test skips when validation succeeds", expectedDidComplete: true)

        XCTAssertNil(authenticationClient.authParams)
        XCTAssertNil(subscriptionsClient.subscribeParams)
    }

    func run(name: String, expectedDidComplete: Bool) {
        let expectation = expectation(description: name)
        var error: Error?
        var didComplete: Bool?
        subject.subscribe()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failureError):
                        error = failureError
                    }
                },
                receiveValue: { _ in
                    didComplete = true
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        waitForExpectations(timeout: 5)
        XCTAssertNil(error)
        XCTAssertNotNil(didComplete)
        XCTAssertEqual(didComplete, expectedDidComplete)
    }
}
