// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import TestKit
import ToolKit
import XCTest

extension Optional: Comparable where Wrapped: Comparable {

    public static func < (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return false
        case (.none, .some):
            return true
        case (.some, .none):
            return false
        case (.some(let lhs), .some(let rhs)):
            return lhs < rhs
        }
    }
}

class InMemoryCacheTests: XCTestCase {

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

    private var subject: InMemoryCache<Int, Int>!

    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let refreshControl = PeriodicCacheRefreshControl(refreshInterval: refreshInterval)
        subject = InMemoryCache(
            configuration: .default(),
            refreshControl: refreshControl
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
        let key = 0

        let expectedValue: CacheValue<Int> = .absent

        // WHEN: getting that key
        let publisher = subject.get(key: key)

        // THEN: an absent value is returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_get_staleKey() {
        // GIVEN: a key with a stale value associated
        let key = 0
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
        let key = 0
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
        let key = 0
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
            subject.set(i, for: i)
        }

        XCTAssertPublisherCompletion(setPublishers)

        // WHEN: getting those keys on multiple overlapping queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: i % getsOverlapIndexConcurrent)
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
            subject.set(i, for: i)
        }

        XCTAssertPublisherCompletion(setPublishers)

        // WHEN: getting those keys on multiple unique queues
        var getPublishers = (0..<getsConcurrent).map { i in
            subject.get(key: i)
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

    // MARK: - Get Performance

    func test_get_singleKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for _ in 0..<getsPerformance {
                subject.get(key: 0)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_get_overlappingKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<getsPerformance {
                subject.get(key: i % getsOverlapIndexPerformance)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_get_uniqueKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<getsPerformance {
                subject.get(key: i)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    // MARK: - Stream

    /// NOTE: This test is flaky and it's temporarily disabled
    func test_stream_updates() throws {
        try XCTSkipIf(true)
        // GIVEN: a key with no value associated
        // Also streams the initial value.
        let expectedValues: [CacheValue<Int>] = [
            .absent,
            .present(0),
            .present(1)
        ]

        // WHEN: streaming that key and updating it
        let streamPublisher = subject.stream(key: 0)

        let streamAssertion = XCTAsyncAssertPublisherValues(streamPublisher, expectedValues, expectCompletion: false)

        let setPublisher1 = subject.set(0, for: 0)

        // Ensure updates to other keys do not send updates to specified key.
        let setPublisher2 = subject.set(0, for: 1)

        let setPublisher3 = subject.set(1, for: 0)

        // THEN: all the updates are collected
        XCTAssertPublisherCompletion(setPublisher1)

        XCTAssertPublisherCompletion(setPublisher2)

        XCTAssertPublisherCompletion(setPublisher3)

        streamAssertion()
    }

    // MARK: - Stream Concurrent

    func test_stream_singleKeyConcurrent() {
        // GIVEN: a key with no value associated
        let key = 0

        // Also streams the initial value.
        let perStreamValues: [CacheValue<Int>] = [.absent] + (0..<streamIterationsConcurrent).map(CacheValue.present)
        let expectedValues = Array(repeating: perStreamValues, count: streamsConcurrent)

        let queues = (0..<streamsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: streaming and updating that key multiple times on multiple queues
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

        let setPublishers = (0..<streamIterationsConcurrent).map { i in
            subject.set(i, for: key)
        }

        // THEN: all the publishers collect all the updates
        startStreamPublishers()

        // Wait for all streams to start.
        Thread.sleep(forTimeInterval: 0.1)

        XCTAssertPublisherCompletion(setPublishers)

        streamAssertion()
    }

    func test_stream_overlappingKeyConcurrent() {
        // GIVEN: a range of keys with no values associated
        // Also streams the initial value.
        let perStreamValues: [CacheValue<Int>] = [.absent] + (0..<streamIterationsConcurrent).map(CacheValue.present)
        let expectedValues = Array(repeating: perStreamValues, count: streamsConcurrent)

        let queues = (0..<streamsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: streaming and updating those keys multiple times on multiple overlapping queues
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

        let setPublishers = (0..<(streamIterationsConcurrent * streamsOverlapIndexConcurrent)).map { i in
            subject.set(i % streamIterationsConcurrent, for: i / streamIterationsConcurrent)
        }

        // THEN: all the publishers collect all their respective updates
        startStreamPublishers()

        // Wait for all streams to start.
        Thread.sleep(forTimeInterval: 0.1)

        XCTAssertPublisherCompletion(setPublishers)

        streamAssertion()
    }

    /// NOTE: This test is flaky and it's temporarily disabled
    func test_stream_uniqueKeyConcurrent() throws {
        try XCTSkipIf(true)
        // GIVEN: a range of keys with no values associated
        // Also streams the initial value.
        let perStreamValues: [CacheValue<Int>] = [.absent] + (0..<streamIterationsConcurrent).map(CacheValue.present)
        let expectedValues = Array(repeating: perStreamValues, count: streamsConcurrent)

        let queues = (0..<streamsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: streaming and updating those keys multiple times on multiple unique queues
        var streamPublishers = (0..<streamsConcurrent).map { i in
            subject.stream(key: i)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startStreamPublishers = configParallelStart(&streamPublishers)

        let streamAsssertion = XCTAsyncAssertPublisherValues(
            streamPublishers,
            expectedValues,
            expectCompletion: false
        )

        let setPublishers = (0..<(streamIterationsConcurrent * streamsConcurrent)).map { i in
            subject.set(i % streamIterationsConcurrent, for: i / streamIterationsConcurrent)
        }

        // THEN: all the publishers collect all their respective updates
        startStreamPublishers()

        // Wait for all streams to start.
        Thread.sleep(forTimeInterval: 0.1)

        XCTAssertPublisherCompletion(setPublishers)

        streamAsssertion()
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

            for i in 0..<streamIterationsPerformance {
                subject.set(i, for: 0)
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

            for i in 0..<(streamIterationsPerformance * streamsOverlapIndexPerformance) {
                subject.set(i % streamIterationsPerformance, for: i / streamIterationsPerformance)
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

            for i in 0..<(streamIterationsPerformance * streamsPerformance) {
                subject.set(i % streamIterationsPerformance, for: i / streamIterationsPerformance)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    // MARK: - Set

    func test_set_overwriteValue() {
        // GIVEN: a key with no value associated
        let getExpectedValues: [CacheValue<Int>] = [
            .absent,
            .present(0),
            .present(1)
        ]
        let setExpectedValues: [Int?] = [
            nil,
            0
        ]

        // WHEN: setting that key multiple times
        let getPublisher1 = subject.get(key: 0)

        let setPublisher1 = subject.set(0, for: 0)

        let getPublisher2 = subject.get(key: 0)

        let setPublisher2 = subject.set(1, for: 0)

        let getPublisher3 = subject.get(key: 0)

        // THEN: the value is set, and the replaced value is overwritten
        XCTAssertPublisherValues(getPublisher1, getExpectedValues[0])

        XCTAssertPublisherValues(setPublisher1, setExpectedValues[0])

        XCTAssertPublisherValues(getPublisher2, getExpectedValues[1])

        XCTAssertPublisherValues(setPublisher2, setExpectedValues[1])

        XCTAssertPublisherValues(getPublisher3, getExpectedValues[2])
    }

    // MARK: - Set Concurrent

    func test_set_singleKeyConcurrent() {
        // GIVEN: a key with no value associated
        let key = 0
        let expectedValues = Array(0..<setsConcurrent)

        let queues = (0..<setsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: setting that key on multiple queues
        var setPublishers = (0..<setsConcurrent).map { i in
            subject.set(i, for: key)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startSetPublishers = configParallelStart(&setPublishers)

        let setAssertion = XCTAsyncAssertPublisherValues(
            setPublishers,
            expectedValues,
            transformReceived: { receivedValues in
                // The first set will return `nil`, and the last value set will not be returned, thus being "missing".
                // Compute the missing value (represented by `nil`) by calculating the difference between the expected and received sums.
                let missingValue = expectedValues.reduce(0, +) - receivedValues.reduce(0, +)

                let missingIndex = receivedValues.firstIndex(of: nil)

                XCTAssertNotNil(missingIndex, "No index is nil")
                XCTAssertEqual(
                    missingIndex,
                    receivedValues.lastIndex(of: nil),
                    "Multiple missing indices when only one was expected"
                )

                receivedValues[missingIndex!] = missingValue

                receivedValues.sort()
            }
        )

        // THEN: all the publishers return all the set values
        startSetPublishers()

        setAssertion()
    }

    func test_set_overlappingKeyConcurrent() {
        // GIVEN: a range of keys with no values associated
        let expectedValues = Array(0..<setsConcurrent)

        let queues = (0..<setsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: setting those keys on multiple overlapping queues
        var setPublishers = (0..<setsConcurrent).map { i in
            subject.set(i, for: i % setsOverlapIndexConcurrent)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startSetPublishers = configParallelStart(&setPublishers)

        let setAssertion = XCTAsyncAssertPublisherValues(
            setPublishers,
            expectedValues,
            transformReceived: { [setsConcurrent, setsOverlapIndexConcurrent] receivedValues in
                // There must be exactly one `nil` value for each index.
                //
                // A sample output pre transformation is (50 publishers, overlapping every 10 publishers) :
                // Index:     0,            1,            2,            3,            4,            5,            6,            7,            8,            9
                // Optional(20), Optional(21), Optional(12), Optional(43), Optional(34),          nil,          nil, Optional(17), Optional(48), Optional(29),
                // Optional(30), Optional(31), Optional(42), Optional(33), Optional(24), Optional(45), Optional(26), Optional(27), Optional(38), Optional(39),
                // Optional(10), Optional(11), Optional( 2), Optional(13), Optional( 4), Optional( 5), Optional( 6),          nil, Optional(18), Optional(19),
                // Optional(40),          nil,          nil,          nil, Optional(44), Optional(25), Optional(16), Optional(47),          nil, Optional(49),
                //          nil, Optional( 1), Optional(32), Optional(23),          nil, Optional(35), Optional(36), Optional( 7), Optional(28),          nil

                let overlaps = setsConcurrent / setsOverlapIndexConcurrent

                // The sum of the expected values for the zero index.
                let sumZeroIndexValues = (((overlaps - 1) * overlaps) / 2) * setsOverlapIndexConcurrent

                // Iterate through the indexes in a single overlap range.
                for i in 0..<setsOverlapIndexConcurrent {
                    // Pick the received values for the current index.
                    let receivedIndexValues = (0..<overlaps).map { j in
                        receivedValues[j * setsOverlapIndexConcurrent + i]
                    }

                    // Add the index-dependent values for the sum of the current index values.
                    let sumIndexValues = sumZeroIndexValues + i * overlaps

                    let missingValue = sumIndexValues - receivedIndexValues.reduce(0, +)

                    let missingIndexInOverlap = receivedIndexValues.firstIndex(of: nil)

                    XCTAssertNotNil(missingIndexInOverlap, "No index is nil")
                    XCTAssertEqual(
                        missingIndexInOverlap,
                        receivedIndexValues.lastIndex(of: nil),
                        "Multiple missing indices when only one was expected"
                    )

                    let missingIndex = missingIndexInOverlap! * setsOverlapIndexConcurrent + i

                    receivedValues[missingIndex] = missingValue
                }

                receivedValues.sort()
            }
        )

        // THEN: all the publishers return all their respective set values
        startSetPublishers()

        setAssertion()
    }

    func test_set_uniqueKeyConcurrent() {
        // GIVEN: a range of keys with no values associated
        let expectedValues: [Int?] = Array(repeating: nil, count: setsConcurrent)

        let queues = (0..<setsConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        // WHEN: setting those keys on multiple unique queues
        var setPublishers = (0..<setsConcurrent).map { i in
            subject.set(i, for: i)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startSetPublishers = configParallelStart(&setPublishers)

        let setAssertion = XCTAsyncAssertPublisherValues(setPublishers, expectedValues)

        // THEN: all the publishers return all their respective set values
        startSetPublishers()

        setAssertion()
    }

    // MARK: - Set Performance

    func test_set_singleKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<setsPerformance {
                subject.set(i, for: 0)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_set_overlappingKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<setsPerformance {
                subject.set(i, for: i % setsOverlapIndexPerformance)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_set_uniqueKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<setsPerformance {
                subject.set(i, for: i)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    // MARK: - Remove

    func test_remove_exitingValue() {
        // GIVEN: a key with no value associated
        let removeExpectedValues: [Int?] = [
            nil,
            0
        ]
        let setExpectedValue: Int? = nil
        let getExpectedValue: CacheValue<Int> = .absent

        // WHEN: removing that key, setting it, and removing it again
        let removePublisher1 = subject.remove(key: 0)

        let setPublisher = subject.set(0, for: 0)

        let removePublisher2 = subject.remove(key: 0)

        let getPublisher = subject.get(key: 0)

        // THEN: the value is removed, and the removed value is returned
        XCTAssertPublisherValues(removePublisher1, removeExpectedValues[0])

        XCTAssertPublisherValues(setPublisher, setExpectedValue)

        XCTAssertPublisherValues(removePublisher2, removeExpectedValues[1])

        XCTAssertPublisherValues(getPublisher, getExpectedValue)
    }

    // MARK: - Remove Concurrent

    func test_remove_singleKeyConcurrent() {
        // GIVEN: a key with a present value associated
        let key = 0
        let newValue = 0

        let expectedValues = Array(repeating: nil, count: removesConcurrent - 1) + [newValue]

        let queues = (0..<removesConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        let setPublisher = subject.set(newValue, for: key)

        XCTAssertPublisherCompletion(setPublisher)

        // WHEN: removing that key on multiple queues
        var removePublishers = (0..<removesConcurrent).map { i in
            subject.remove(key: key)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startRemovePublishers = configParallelStart(&removePublishers)

        let removeAssertion = XCTAsyncAssertPublisherValues(
            removePublishers,
            expectedValues,
            transformReceived: { $0.sort() }
        )

        // THEN: all the publishers return all the removed values
        startRemovePublishers()

        removeAssertion()
    }

    func test_remove_overlappingKeyConcurrent() {
        // GIVEN: a range of keys with present values associated
        let expectedValues = Array(
            repeating: nil,
            count: removesConcurrent - removesOverlapIndexConcurrent
        ) + Array(0..<removesOverlapIndexConcurrent)

        let queues = (0..<removesConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        let setPublishers = (0..<removesOverlapIndexConcurrent).map { i in
            subject.set(i, for: i)
        }

        XCTAssertPublisherCompletion(setPublishers)

        // WHEN: removing those keys on multiple overlapping queues
        var removePublishers = (0..<removesConcurrent).map { i in
            subject.remove(key: i % removesOverlapIndexConcurrent)
                .subscribe(on: queues[i])
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startRemovePublishers = configParallelStart(&removePublishers)

        let removeAssertion = XCTAsyncAssertPublisherValues(
            removePublishers,
            expectedValues,
            transformReceived: { $0.sort() }
        )

        // THEN: all the publishers return all their respective removed values
        startRemovePublishers()

        removeAssertion()
    }

    func test_remove_uniqueKeyConcurrent() {
        // GIVEN: a range of keys with present values associated
        let expectedValues = Array(0..<removesConcurrent)

        let queues = (0..<removesConcurrent).map { i in
            DispatchQueue(label: "Queue \(i)")
        }

        let setPublishers = (0..<removesConcurrent).map { i in
            subject.set(i, for: i)
        }

        XCTAssertPublisherCompletion(setPublishers)

        // WHEN: removing those keys on multiple unique queues
        var removePublishers = (0..<removesConcurrent).map { i in
            subject.remove(key: i)
                .receive(on: queues[i])
                .eraseToAnyPublisher()
        }

        let startRemovePublishers = configParallelStart(&removePublishers)

        let removeAssertion = XCTAsyncAssertPublisherValues(removePublishers, expectedValues)

        // THEN: all the publishers return all their respective removed values
        startRemovePublishers()

        removeAssertion()
    }

    // MARK: - Remove Performance

    func test_remove_singleKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for _ in 0..<removesPerformance {
                subject.remove(key: 0)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_remove_overlappingKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<removesPerformance {
                subject.remove(key: i % removesOverlapIndexPerformance)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    func test_remove_uniqueKeyPerformance() throws {
        try XCTSkipIf(true)
        measure {
            for i in 0..<removesPerformance {
                subject.remove(key: i)
                    .sink(receiveValue: noop)
                    .store(in: &cancellables)
            }
        }
    }

    // MARK: - Remove All

    func test_removeAll_existingValues() {
        // GIVEN: two keys with present values associated
        let setExpectedValues: [Int?] = [
            nil,
            nil
        ]
        let getExpectedValues: [CacheValue<Int>] = [
            .absent,
            .absent
        ]

        let setPublisher1 = subject.set(0, for: 0)

        let setPublisher2 = subject.set(1, for: 1)

        XCTAssertPublisherValues(setPublisher1, setExpectedValues[0])

        XCTAssertPublisherValues(setPublisher2, setExpectedValues[1])

        // WHEN: removing all the keys
        let removeAllPublisher = subject.removeAll()

        let getPublisher1 = subject.get(key: 0)

        let getPublisher2 = subject.get(key: 1)

        // THEN: the keys have no values associated
        XCTAssertPublisherCompletion(removeAllPublisher)

        XCTAssertPublisherValues(getPublisher1, getExpectedValues[0])

        XCTAssertPublisherValues(getPublisher2, getExpectedValues[1])
    }
}
