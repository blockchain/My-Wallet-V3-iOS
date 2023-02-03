// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import TestKit
import ToolKit
import ToolKitMock
import XCTest

class CachedValueNewTests: XCTestCase {

    // MARK: - Private Properties

    private let getsConcurrent = 500

    private let getsOverlapIndexConcurrent = 50

    private let getsPerformance = 10000

    private let getsOverlapIndexPerformance = 100

    private let streamsConcurrent = 500

    private let streamsOverlapIndexConcurrent = 50

    private let streamsPerformance = 10000

    private let streamsOverlapIndexPerformance = 100

    private let fetchErrorKey = -1

    private let fetchValue = 1

    private let refreshInterval: TimeInterval = 3

    private var cache: AnyCache<Int, Int>!

    private var subject: CachedValueNew<Int, Int, MockError>!

    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let refreshControl = PeriodicCacheRefreshControl(refreshInterval: refreshInterval)
        cache = InMemoryCache(
            configuration: .default(),
            refreshControl: refreshControl
        )
        .eraseToAnyCache()

        subject = CachedValueNew(cache: cache) { [fetchErrorKey, fetchValue] key in
            switch key {
            case fetchErrorKey:
                return .failure(.unknown)
            default:
                return .just(fetchValue)
            }
        }

        cancellables = []
    }

    override func tearDown() {
        cache = nil
        subject = nil
        cancellables = nil

        super.tearDown()
    }

    // MARK: - Get

    func test_get_absentKey() {
        // GIVEN: a key with no value associated
        let key = 0

        let expectedValue = fetchValue

        // WHEN: getting that key
        let publisher = subject.get(key: key)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_get_staleKey() {
        // GIVEN: a key with a stale value associated
        let key = 0
        let newValue = 0

        let expectedValue = fetchValue

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // Wait for set value to become stale.
        Thread.sleep(forTimeInterval: refreshInterval)

        // WHEN: getting that key
        let publisher = subject.get(key: key)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_get_presentKey() {
        // GIVEN: a key with a present value associated
        let key = 0
        let newValue = 0

        let expectedValue = newValue

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // WHEN: getting that key
        let publisher = subject.get(key: key)

        // THEN: the present value is returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_get_forceFetch() {
        // GIVEN: a key with a present value associated
        let key = 0
        let newValue = 0

        let expectedValue = fetchValue

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // WHEN: getting that key with force fetch
        let publisher = subject.get(key: key, forceFetch: true)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_get_errorKey() {
        // GIVEN: fetching fails, and a key with no value associated
        let key = fetchErrorKey

        let expectedError: MockError = .unknown

        // WHEN: getting that key
        let publisher = subject.get(key: key)

        // THEN: an error is returned
        XCTAssertPublisherError(publisher, expectedError)
    }

    // MARK: - Get Concurrent

    func test_get_singleKeyConcurrent() throws {
        try XCTSkipIf(true) // Skipping flaky test
        // GIVEN: a key with no value associated
        let key = 0

        let expectedValues = Array(repeating: fetchValue, count: getsConcurrent)

        let queues = (0..<getsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: getting that key on multiple queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: key)
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startGetPublishers = configParallelStart(&getPublishers)

        let getAssertion = XCTAsyncAssertPublisherValues(getPublishers, expectedValues)

        // THEN: all the publishers get the same value
        startGetPublishers()

        getAssertion()
    }

    func test_get_overlappingKeyConcurrent() throws {
        try XCTSkipIf(true) // Skipping flaky test
        // GIVEN: a range of keys with no values associated
        let expectedValues = Array(repeating: fetchValue, count: getsConcurrent)

        let queues = (0..<getsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: getting those keys on muliple overlapping queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: i % getsOverlapIndexConcurrent)
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

    func test_get_uniqueKeyConcurrent() throws {
        try XCTSkipIf(true) // Skipping flaky test
        // GIVEN: a range of keys with no values associated
        let expectedValues = Array(repeating: fetchValue, count: getsConcurrent)

        let queues = (0..<getsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: getting those keys on multiple unique queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: i)
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

    // MARK: - Get Performance

    func test_get_singleKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for _ in 0..<getsPerformance {
                subject.get(key: 0)
                    .sink(receiveCompletion: noop, receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_get_overlappingKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<getsPerformance {
                subject.get(key: i % getsOverlapIndexPerformance)
                    .sink(receiveCompletion: noop, receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_get_uniqueKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<getsPerformance {
                subject.get(key: i)
                    .sink(receiveCompletion: noop, receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    // MARK: - Stream

    func test_stream_absentKey() {
        // GIVEN: a key with no value associated
        let key = 0

        let expectedValue: Result<Int, MockError> = .success(fetchValue)

        // WHEN: streaming that key
        let publisher = subject.stream(key: key)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue, expectCompletion: false)
    }

    func test_stream_staleKey() {
        // GIVEN: a key with a stale value associated
        let key = 0
        let newValue = 0

        let expectedValues: [Result<Int, MockError>] = [.success(newValue), .success(fetchValue)]

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // Wait for set value to become stale.
        Thread.sleep(forTimeInterval: refreshInterval)

        // WHEN: streaming that key
        let publisher = subject.stream(key: key, skipStale: false)

        // THEN: a new value is fetched, and both the stale and new value are returned
        XCTAssertPublisherValues(publisher, expectedValues, expectCompletion: false)
    }

    func test_stream_skipStale() {
        // GIVEN: a key with a stale value associated
        let key = 0
        let newValue = 0

        let expectedValue: Result<Int, MockError> = .success(fetchValue)

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // Wait for set value to become stale.
        Thread.sleep(forTimeInterval: refreshInterval)

        // WHEN: streaming that key with skip stale
        let publisher = subject.stream(key: key, skipStale: true)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue, expectCompletion: false)
    }

    func test_stream_presentKey() {
        // GIVEN: a key with a present value associated
        let key = 0
        let newValue = 0

        let expectedValue: Result<Int, MockError> = .success(newValue)

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // WHEN: streaming that key
        let publisher = subject.stream(key: key)

        // THEN: the present value is returned
        XCTAssertPublisherValues(publisher, expectedValue, expectCompletion: false)
    }

    func test_stream_errorKey() {
        // GIVEN: fetching fails, and a key with no value associated
        let key = fetchErrorKey

        let expectedValues: [Result<Int, MockError>] = [.failure(.unknown)]

        // WHEN: getting that key
        let publisher = subject.stream(key: key)

        // THEN: an error is returned
        XCTAssertPublisherValues(publisher, expectedValues, expectCompletion: false)
    }

    /// NOTE: This test is flaky and it's temporarily disabled
    func test_stream_updates() throws {
        try XCTSkipIf(true)
        // GIVEN: a key with a present value associated
        let key = 0
        let newValue = 0

        let expectedValues: [Result<Int, MockError>] = [.success(newValue), .success(fetchValue)]

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // WHEN: streaming that key and updating it
        let streamPublisher = subject.stream(key: key)

        let streamAssertion = XCTAsyncAssertPublisherValues(streamPublisher, expectedValues, expectCompletion: false)

        let getPublisher = subject.get(key: key, forceFetch: true)

        // THEN: both the present and new value are returned
        XCTAssertPublisherCompletion(getPublisher)

        streamAssertion()
    }

    // MARK: - Stream Concurrent

    func test_stream_singleKeyConcurrent() throws {
        try XCTSkipIf(true)
        // GIVEN: a key with no value associated
        let key = 0

        let perStreamValues: [Result<Int, MockError>] = [.success(fetchValue)]
        let expectedValues = Array(repeating: perStreamValues, count: streamsConcurrent)

        let queues = (0..<streamsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: streaming and updating that key on multiple queues
        var streamPublishers = (0..<streamsConcurrent).map { i in
            subject.stream(key: key)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startStreamPublishers = configParallelStart(&streamPublishers)

        let streamAssertion = XCTAsyncAssertPublisherValues(
            streamPublishers,
            expectedValues,
            expectCompletion: false
        )

        // THEN: all the publishers collect all the updates
        startStreamPublishers()

        streamAssertion()
    }

    func test_stream_overlappingKeyConcurrent() throws {
        try XCTSkipIf(true)
        // GIVEN: a range of keys with no values associated
        let perStreamValues: [Result<Int, MockError>] = [.success(fetchValue)]
        let expectedValues = Array(repeating: perStreamValues, count: streamsConcurrent)

        let queues = (0..<streamsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: streaming and updating those keys on multiple overlapping queues
        var streamPublishers = (0..<streamsConcurrent).map { i in
            subject.stream(key: i % streamsOverlapIndexConcurrent)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startStreamPublishers = configParallelStart(&streamPublishers)

        let streamAssertion = XCTAsyncAssertPublisherValues(
            streamPublishers,
            expectedValues,
            expectCompletion: false
        )

        // THEN: all the publishers collect all their respective updates
        startStreamPublishers()

        streamAssertion()
    }

    /// NOTE: This test is flaky and it's temporarily disabled
    func test_stream_uniqueKeyConcurrent() throws {
        try XCTSkipIf(true)
        // GIVEN: a range of keys with no values associated
        let perStreamValues: [Result<Int, MockError>] = [.success(fetchValue)]
        let expectedValues = Array(repeating: perStreamValues, count: streamsConcurrent)

        let queues = (0..<streamsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: streaming and updating those keys on multiple unique queues
        var streamPublishers = (0..<streamsConcurrent).map { i in
            subject.stream(key: i)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startStreamPublishers = configParallelStart(&streamPublishers)

        let streamAssertion = XCTAsyncAssertPublisherValues(
            streamPublishers,
            expectedValues,
            expectCompletion: false
        )

        // THEN: all the publishers collect all their respective updates
        startStreamPublishers()

        streamAssertion()
    }

    // MARK: - Stream Performance

    func test_stream_singleKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for _ in 0..<streamsPerformance {
                subject.stream(key: 0)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_stream_overlappingKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<streamsPerformance {
                subject.stream(key: i % streamsOverlapIndexPerformance)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_stream_uniqueKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<streamsPerformance {
                subject.stream(key: i)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }
}
