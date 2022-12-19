// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import TestKit
@testable import ToolKit
import XCTest

final class InDiskCacheTests: XCTestCase {

    // MARK: - Private Properties

    private let getsConcurrent = 500

    private let getsOverlapIndexConcurrent = 50

    private let getsPerformance = 15000

    private let getsOverlapIndexPerformance = 150

    private let streamsConcurrent = 300

    private let streamsOverlapIndexConcurrent = 30

    private let streamIterationsConcurrent = 50

    private let streamsPerformance = 100

    private let streamsOverlapIndexPerformance = 10

    private let streamIterationsPerformance = 10

    private let setsConcurrent = 500

    private let setsOverlapIndexConcurrent = 50

    private let setsPerformance = 5000

    private let setsOverlapIndexPerformance = 50

    private let removesConcurrent = 500

    private let removesOverlapIndexConcurrent = 50

    private let removesPerformance = 10000

    private let removesOverlapIndexPerformance = 100
    private let refreshInterval: TimeInterval = 3
    private var subject: InDiskCache<String, Int>!
    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let refreshControl = PeriodicCacheRefreshControl(refreshInterval: refreshInterval)
        subject = InDiskCache(
            appDatabase: .makeShared(id: "InDiskCacheTests", reset: true),
            configuration: .default(),
            refreshControl: refreshControl,
            app: App.preview
        )
        cancellables = []
    }

    override func tearDown() {
        subject = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Get

    func test_get_absentKey() {
        // GIVEN: a key with no value associated
        let key = "0"

        let expectedValue: CacheValue<Int> = .absent

        // WHEN: getting that key
        let publisher = subject.get(key: key)

        // THEN: an absent value is returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_get_staleKey() {
        // GIVEN: a key with a stale value associated
        let key = "0"
        let newValue = 0

        let expectedValue: CacheValue<Int> = .stale(newValue)

        let setPublisher = subject.set(newValue, for: key)

        XCTAssertPublisherCompletion(setPublisher)

        // Wait for set value to become stale.
        Thread.sleep(forTimeInterval: refreshInterval)

        // WHEN: getting that key
        let getPublisher = subject.get(key: key)

        // THEN: the stale value is returned
        XCTAssertPublisherValues(getPublisher, expectedValue)
    }

    func test_get_presentKey() {
        // GIVEN: a key with a present value associated
        let key = "0"
        let newValue = 0

        let expectedValue: CacheValue<Int> = .present(newValue)

        let setPublisher = subject.set(newValue, for: key)

        XCTAssertPublisherCompletion(setPublisher)

        // WHEN: getting that key
        let getPublisher = subject.get(key: key)

        // THEN: the present value is returned
        XCTAssertPublisherValues(getPublisher, expectedValue)
    }

    // MARK: - Get Concurrent

    func test_get_singleKeyConcurrent() {
        try? XCTSkipIf(true) // Skipping flaky test
        // GIVEN: a key with a present value associated
        let key = "0"
        let newValue = 0

        let expectedValues: [CacheValue<Int>] = (0..<getsConcurrent).map { _ in
            .present(newValue)
        }

        let queues = (0..<getsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        let setPublisher = subject.set(newValue, for: key)

        XCTAssertPublisherCompletion(setPublisher)

        // WHEN: getting that key on multiple queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: key)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startGetPublishers = configParallelStart(&getPublishers)

        let getAssertion = XCTAsyncAssertPublisherValues(getPublishers, expectedValues)

        // THEN: all the publishers get the same value
        startGetPublishers()

        getAssertion()
    }

    func test_get_overlappingKeyConcurrent() {
        // GIVEN: a range of keys with present values associated
        let expectedValues: [CacheValue<Int>] = (0..<getsConcurrent).map { i in
            .present(i % getsOverlapIndexConcurrent)
        }

        let queues = (0..<getsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        let setPublishers = (0..<getsOverlapIndexConcurrent).map { i in
            subject.set(i, for: "\(i)")
        }

        XCTAssertPublisherCompletion(setPublishers)

        // WHEN: getting those keys on multiple overlapping queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: "\(i % getsOverlapIndexConcurrent)")
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startGetPublishers = configParallelStart(&getPublishers)

        let getAssertion = XCTAsyncAssertPublisherValues(getPublishers, expectedValues)

        // THEN: all the publishers get all their respective values
        startGetPublishers()

        getAssertion()
    }

    func test_get_uniqueKeyConcurrent() {
        // GIVEN: a range of keys with present values associated
        let expectedValues: [CacheValue<Int>] = (0..<getsConcurrent).map(CacheValue.present)

        let queues = (0..<getsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        let setPublishers = (0..<getsConcurrent).map { i in
            subject.set(i, for: "\(i)")
        }

        XCTAssertPublisherCompletion(setPublishers)

        // WHEN: getting those keys on multiple unique queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: "\(i)")
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startGetPublishers = configParallelStart(&getPublishers)

        let getAssertion = XCTAsyncAssertPublisherValues(getPublishers, expectedValues)

        // THEN: all the publishers get all their respective values
        startGetPublishers()

        getAssertion()
    }
}
