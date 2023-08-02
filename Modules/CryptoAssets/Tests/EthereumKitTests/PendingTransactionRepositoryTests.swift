// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumDataKit
@testable import EthereumKit
import Combine
import UnifiedActivityDomain
import MoneyKit
import XCTest

final class PendingTransactionRepositoryTests: XCTestCase {

    var bag: Set<AnyCancellable> = []

    func test_isWaitingOnTransaction() {
        let mockUnifiedActivity = MockUnifiedActivityRepo()

        let sut = PendingTransactionRepository(repository: mockUnifiedActivity)

        // given
        mockUnifiedActivity.mockPendingActivity = [
            ActivityEntry(
                id: "a",
                type: .swap,
                network: "ETH",
                pubKey: "pubKey",
                externalUrl: "",
                item: .init(leading: [], trailing: []),
                state: .confirming,
                timestamp: Date(timeIntervalSinceNow: -60 * 60).timeIntervalSince1970,
                transactionType: nil
            )
        ]

        let expectation = expectation(description: "disallows transaction")

        // when
        sut.isWaitingOnTransaction(network: .ethereum)
            .sink { value in
                // then
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1)
    }

    func test_isWaitingOnTransaction_ignore_stale_txs() {
        let mockUnifiedActivity = MockUnifiedActivityRepo()

        let sut = PendingTransactionRepository(repository: mockUnifiedActivity)

        // given a transaction that occured 2+ hours ago
        mockUnifiedActivity.mockPendingActivity = [
            ActivityEntry(
                id: "a",
                type: .swap,
                network: "ETH",
                pubKey: "pubKey",
                externalUrl: "",
                item: .init(leading: [], trailing: []),
                state: .confirming,
                timestamp: Date(timeIntervalSinceNow: -60 * 60 * 3).timeIntervalSince1970,
                transactionType: nil
            )
        ]

        let expectation = expectation(description: "allows transaction")

        // when
        sut.isWaitingOnTransaction(network: .ethereum)
            .sink { value in
                // then
                XCTAssertFalse(value)
                expectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1)
    }
}

private class MockUnifiedActivityRepo: UnifiedActivityRepositoryAPI {
    var mockPendingActivity: [ActivityEntry] = []
    var mockActivity: [ActivityEntry] = []

    var activity: AnyPublisher<[ActivityEntry], Never> {
        .just(mockActivity)
    }

    var pendingActivity: AnyPublisher<[ActivityEntry], Never> {
        .just(mockPendingActivity)
    }
}
