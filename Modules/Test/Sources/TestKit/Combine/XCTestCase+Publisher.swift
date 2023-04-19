// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

extension XCTestCase {

    // MARK: - One Publisher One Value

    /// Asserts that a publisher will emit the expected value and (optionally) complete without errors.
    ///
    /// This method generates a failure when `publisher` doesn't emit the expected value and doesn't (optionally) complete without errors.
    ///
    /// - Parameters:
    ///   - publisher:         A publisher.
    ///   - expectedValue:     A value of the publisher's output type.
    ///   - transformReceived: A closure for transforming the received value.
    ///   - expectCompletion:  Whether the publisher is expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherValues<T: Publisher>(
        _ publisher: T,
        _ expectedValue: T.Output,
        transformReceived: ((inout T.Output) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Output: Equatable {
        XCTAsyncAssertPublisherValues(
            publisher,
            expectedValue,
            transformReceived: transformReceived,
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )()
    }

    /// Creates an asynchronous assertion that a publisher will emit the expected value and (optionally) complete without errors.
    ///
    /// This method generates a failure when `publisher` doesn't emit the expected value and doesn't (optionally) complete without errors.
    ///
    /// This is useful when a publisher must be subscribed to, but further actions must be taken until the assertion can be called.
    ///
    /// - Parameters:
    ///   - publisher:         A publisher.
    ///   - expectedValue:     A value of the publisher's output type.
    ///   - transformReceived: A closure for transforming the received value.
    ///   - expectCompletion:  Whether the publisher is expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    ///
    /// - Returns: The asynchronous assertion.
    public func XCTAsyncAssertPublisherValues<T: Publisher>(
        _ publisher: T,
        _ expectedValue: T.Output,
        transformReceived: ((inout T.Output) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> () -> Void where T.Output: Equatable {
        let collectAndWait = collectAndWaitForPublishers(
            [publisher],
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )

        return { () in
            let (receivedValuesSequence, receivedErrors) = collectAndWait()

            let receivedValues = receivedValuesSequence[0]
            let receivedError = receivedErrors[0]

            XCTAssertEqual(
                receivedValues.count,
                1,
                "Received values count does not match expected values count",
                file: file,
                line: line
            )

            if var receivedValue = receivedValues.first {
                transformReceived?(&receivedValue)

                XCTAssertEqual(
                    receivedValue,
                    expectedValue,
                    "Received value does not match expected value",
                    file: file,
                    line: line
                )
            } else {
                XCTFail("No value received", file: file, line: line)
            }

            XCTAssertNil(receivedError, "Received error when no error was expected", file: file, line: line)
        }
    }

    // MARK: - Many Publishers One Value

    /// Asserts that a sequence of publishers will emit the expected values and (optionally) complete without errors.
    ///
    /// This method generates a failure when any publisher from `publishers` doesn't emit the expected values and doesn't (optionally) complete without errors.
    ///
    /// - Parameters:
    ///   - publishers:        A sequence of publishers.
    ///   - expectedValues:    A sequence of a single value per each publisher, of the publishers' output type.
    ///   - transformReceived: A closure for transforming the sequence of received values.
    ///   - expectCompletion:  Whether the publishers are expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherValues<T: Publisher>(
        _ publishers: [T],
        _ expectedValues: [T.Output],
        transformReceived: ((inout [T.Output]) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Output: Equatable {
        XCTAsyncAssertPublisherValues(
            publishers,
            expectedValues,
            transformReceived: transformReceived,
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )()
    }

    /// Creates an asynchronous assertion that a sequence of publishers will emit the expected values and (optionally) complete without errors.
    ///
    /// This method generates a failure when any publisher from `publishers` doesn't emit the expected values and doesn't (optionally) complete without errors.
    ///
    /// This is useful when a sequence of publishers must be subscribed to, but further actions must be taken until the assertion can be called.
    ///
    /// - Parameters:
    ///   - publishers:        A sequence of publishers.
    ///   - expectedValues:    A sequence of a single value per each publisher, of the publishers' output type.
    ///   - transformReceived: A closure for transforming the sequence of received values.
    ///   - expectCompletion:  Whether the publishers are expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAsyncAssertPublisherValues<T: Publisher>(
        _ publishers: [T],
        _ expectedValues: [T.Output],
        transformReceived: ((inout [T.Output]) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> () -> Void where T.Output: Equatable {
        XCTAssertEqual(publishers.count, expectedValues.count, "Publishers count does not match expected values count")

        let collectAndWait = collectAndWaitForPublishers(
            publishers,
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )

        return { () in
            let (receivedValues, receivedErrors) = collectAndWait()

            XCTAssertEqual(
                receivedValues.map(\.count),
                Array(repeating: 1, count: expectedValues.count),
                "Received values counts do not match expected values counts",
                file: file,
                line: line
            )

            var receivedValuesFlattened = receivedValues.flatMap { $0 }

            transformReceived?(&receivedValuesFlattened)

            XCTAssertEqual(
                receivedValuesFlattened,
                expectedValues,
                "Received values do not match expected values",
                file: file,
                line: line
            )

            XCTAssertTrue(
                receivedErrors.allSatisfy { $0 == nil },
                "Received errors when no errors were expected: \(receivedErrors)",
                file: file,
                line: line
            )
        }
    }

    // MARK: - One Publisher Many Values

    /// Asserts that a publisher will emit the expected values and (optionally) complete without errors.
    ///
    /// This method generates a failure when `publisher` doesn't emit the expected values and doesn't (optionally) complete without errors.
    ///
    /// - Parameters:
    ///   - publisher:         A publisher.
    ///   - expectedValues:    A sequence of values of the publisher's output type.
    ///   - transformReceived: A closure for transforming the received values.
    ///   - expectCompletion:  Whether the publisher is expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherValues<T: Publisher>(
        _ publisher: T,
        _ expectedValues: [T.Output],
        transformReceived: ((inout [T.Output]) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Output: Equatable {
        XCTAsyncAssertPublisherValues(
            publisher,
            expectedValues,
            transformReceived: transformReceived,
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )()
    }

    /// Creates an asynchronous assertion that a publisher will emit the expected values and (optionally) complete without errors.
    ///
    /// This method generates a failure when `publisher` doesn't emit the expected values and doesn't (optionally) complete without errors.
    ///
    /// This is useful when a publisher must be subscribed to, but further actions must be taken until the assertion can be called.
    ///
    /// - Parameters:
    ///   - publisher:         A publisher.
    ///   - expectedValues:    A sequence of values of the publisher's output type.
    ///   - transformReceived: A closure for transforming the received values.
    ///   - expectCompletion:  Whether the publisher is expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    ///
    /// - Returns: The asynchronous assertion.
    public func XCTAsyncAssertPublisherValues<T: Publisher>(
        _ publisher: T,
        _ expectedValues: [T.Output],
        transformReceived: ((inout [T.Output]) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> () -> Void where T.Output: Equatable {
        let collectAndWait = collectAndWaitForPublishers(
            [publisher],
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )

        return { () in
            let (receivedValuesSequence, receivedErrors) = collectAndWait()

            var receivedValues = receivedValuesSequence[0]
            let receivedError = receivedErrors[0]

            XCTAssertEqual(
                receivedValues.count,
                expectedValues.count,
                "Received values count does not match expected values count",
                file: file,
                line: line
            )

            transformReceived?(&receivedValues)

            XCTAssertEqual(
                receivedValues,
                expectedValues,
                "Received values do not match expected values",
                file: file,
                line: line
            )

            XCTAssertNil(receivedError, "Received error when no error was expected", file: file, line: line)
        }
    }

    // MARK: - Many Publishers Many Values

    /// Asserts that a sequence of publishers will emit the expected values and (optionally) complete without errors.
    ///
    /// This method generates a failure when any publisher from `publishers` doesn't emit the expected values and doesn't (optionally) complete without errors.
    ///
    /// - Parameters:
    ///   - publishers:        A sequence of publishers.
    ///   - expectedValues:    A sequence of a sequence of values per each publisher, of the publishers' output type.
    ///   - transformReceived: A closure for transforming the sequence of received values.
    ///   - expectCompletion:  Whether the publishers are expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherValues<T: Publisher>(
        _ publishers: [T],
        _ expectedValues: [[T.Output]],
        transformReceived: ((inout [[T.Output]]) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Output: Equatable {
        XCTAsyncAssertPublisherValues(
            publishers,
            expectedValues,
            transformReceived: transformReceived,
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )()
    }

    /// Creates an asynchronous assertion that a sequence of publishers will emit the expected values and (optionally) complete without errors.
    ///
    /// This method generates a failure when any publisher from `publishers` doesn't emit the expected values and doesn't (optionally) complete without errors.
    ///
    /// This is useful when a sequence of publishers must be subscribed to, but further actions must be taken until the assertion can be called.
    ///
    /// - Parameters:
    ///   - publishers:        A sequence of publishers.
    ///   - expectedValues:    A sequence of a sequence of values per each publisher, of the publishers' output type.
    ///   - transformReceived: A closure for transforming the sequence of received values.
    ///   - expectCompletion:  Whether the publishers are expected to complete.
    ///   - seconds:           The amount of time within which all expectations must be fulfilled.
    ///   - file:              The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:              The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAsyncAssertPublisherValues<T: Publisher>(
        _ publishers: [T],
        _ expectedValues: [[T.Output]],
        transformReceived: ((inout [[T.Output]]) -> Void)? = nil,
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> () -> Void where T.Output: Equatable {
        XCTAssertEqual(publishers.count, expectedValues.count, "Publishers count does not match expected values count")

        let collectAndWait = collectAndWaitForPublishers(
            publishers,
            expectCompletion: expectCompletion,
            timeout: seconds,
            file: file,
            line: line
        )

        return { () in
            var (receivedValues, receivedErrors) = collectAndWait()

            XCTAssertEqual(
                receivedValues.map(\.count),
                expectedValues.map(\.count),
                "Received values counts do not match expected values counts",
                file: file,
                line: line
            )

            transformReceived?(&receivedValues)

            XCTAssertEqual(
                receivedValues,
                expectedValues,
                "Received values do not match expected values",
                file: file,
                line: line
            )

            XCTAssertTrue(
                receivedErrors.allSatisfy { $0 == nil },
                "Received errors when no errors were expected: \(receivedErrors)",
                file: file,
                line: line
            )
        }
    }

    // MARK: - One Publisher Completion

    /// Asserts that a publisher will complete without errors.
    ///
    /// This method generates a failure when `publisher` doesn't complete without errors.
    ///
    /// - Parameters:
    ///   - publisher: A publisher.
    ///   - seconds:   The amount of time within which all expectations must be fulfilled.
    ///   - file:      The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:      The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherCompletion(
        _ publisher: some Publisher,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (_, receivedErrors) = collectAndWaitForPublishers([publisher], timeout: seconds, file: file, line: line)()

        let receivedError = receivedErrors[0]

        XCTAssertNil(receivedError, "Received error when no error was expected", file: file, line: line)
    }

    // MARK: - Many Publishers Completion

    /// Asserts that a sequence of publishers will complete without errors.
    ///
    /// This method generates a failure when any publisher from `publishers` doesn't complete without errors.
    ///
    /// - Parameters:
    ///   - publishers: A sequence of publishers.
    ///   - seconds:    The amount of time within which all expectations must be fulfilled.
    ///   - file:       The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:       The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherCompletion(
        _ publishers: [some Publisher],
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (_, receivedErrors) = collectAndWaitForPublishers(publishers, timeout: seconds, file: file, line: line)()

        XCTAssertTrue(
            receivedErrors.allSatisfy { $0 == nil },
            "Received errors when no errors were expected: \(receivedErrors)",
            file: file,
            line: line
        )
    }

    // MARK: - One Publisher Error

    /// Asserts that a publisher will complete with the expected error.
    ///
    /// This method generates a failure when `publisher` doesn't complete with the expected error.
    ///
    /// - Parameters:
    ///   - publisher:     A publisher.
    ///   - expectedError: An error of the publisher's failure type.
    ///   - seconds:       The amount of time within which all expectations must be fulfilled.
    ///   - file:          The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:          The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherError<T: Publisher>(
        _ publisher: T,
        _ expectedError: T.Failure,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Failure: Equatable {
        let (receivedValues, receivedErrors) = collectAndWaitForPublishers(
            [publisher],
            timeout: seconds,
            file: file,
            line: line
        )()

        let receivedValue = receivedValues[0]
        let receivedError = receivedErrors[0]

        XCTAssertTrue(
            receivedValue.isEmpty,
            "Received value when no value was expected: \(receivedValue)",
            file: file,
            line: line
        )

        XCTAssertEqual(
            receivedError,
            expectedError,
            "Received error does not match expected error",
            file: file,
            line: line
        )
    }

    // MARK: - Many Publishers Error

    /// Asserts that a sequence of publishers will complete with the expected error.
    ///
    /// This method generates a failure when any publisher from `publishers` doesn't complete with the expected error.
    ///
    /// - Parameters:
    ///   - publisher:     A sequence of publishers.
    ///   - expectedError: A sequence of a single error per each publisher, of the publishers' failure type.
    ///   - seconds:       The amount of time within which all expectations must be fulfilled.
    ///   - file:          The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:          The line number where the failure occurs. The default is the line number where you call this function.
    public func XCTAssertPublisherError<T: Publisher>(
        _ publishers: [T],
        _ expectedErrors: [T.Failure],
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Failure: Equatable {
        XCTAssertEqual(publishers.count, expectedErrors.count, "Publishers count does not match expected errors count")

        let (receivedValues, receivedErrors) = collectAndWaitForPublishers(
            publishers,
            timeout: seconds,
            file: file,
            line: line
        )()

        XCTAssertTrue(
            receivedValues.allSatisfy(\.isEmpty),
            "Received values when no values were expected: \(receivedValues)",
            file: file,
            line: line
        )

        XCTAssertEqual(
            receivedErrors,
            expectedErrors,
            "Received errors do not match expected errors",
            file: file,
            line: line
        )
    }

    // MARK: - Private Methods

    /// Subscribes to a sequence of publishers, collecting their values and errors, (optionally) waiting for their completion.
    ///
    /// This method generates a failure when any publisher from `publishers` doesn't (optionally) complete.
    ///
    /// - Parameters:
    ///   - publishers:       A sequence of publishers.
    ///   - expectCompletion: Whether the publishers are expected to complete.
    ///   - seconds:          The amount of time within which all expectations must be fulfilled.
    ///   - file:             The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:             The line number where the failure occurs. The default is the line number where you call this function.
    ///
    /// - Returns: A function to wait for the expectations, that returns the received values and errors.
    private func collectAndWaitForPublishers<T: Publisher>(
        _ publishers: [T],
        expectCompletion: Bool = true,
        timeout seconds: TimeInterval = 0.5,
        file: StaticString = #file,
        line: UInt = #line
    ) -> () -> (receivedValues: [[T.Output]], receivedErrors: [T.Failure?]) {
        var receivedValues: [[T.Output]] = Array(repeating: [], count: publishers.count)
        var receivedErrors: [T.Failure?] = Array(repeating: nil, count: publishers.count)

        let expectation = expectation(description: "Publisher completion")
        expectation.expectedFulfillmentCount = publishers.count
        expectation.isInverted = !expectCompletion

        let lock = NSRecursiveLock()

        let cancellables = publishers.enumerated().map { i, publisher in
            publisher.sink { completion in
                switch completion {
                case .failure(let error):
                    receivedErrors[i] = error
                case .finished:
                    break
                }

                expectation.fulfill()
            } receiveValue: { value in
                lock.lock()
                defer { lock.unlock() }
                receivedValues[i].append(value)
            }
        }

        return { [unowned self] in
            wait(for: [expectation], timeout: seconds, file: file, line: line)

            cancellables.forEach { $0.cancel() }

            return (receivedValues, receivedErrors)
        }
    }
}
