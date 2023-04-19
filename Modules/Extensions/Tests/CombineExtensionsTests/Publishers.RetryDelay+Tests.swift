import Combine
import CombineExtensions
import CombineSchedulers
import XCTest

final class RetryDelayTests: XCTestCase {

    enum Test: Swift.Error, Equatable {
        case explicitFail
        case onlyWhen
    }

    var scheduler = DispatchQueue.test
    var publisher = [false, nil].publisher
        .tryMap { it throws -> Bool in
            try it.or(throw: Test.explicitFail)
        }

    var received = (
        count: 0,
        completion: (
            finished: false,
            errored: false,
            error: Swift.Error?.none
        )
    )

    var bag: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        scheduler = DispatchQueue.test
        received = (
            count: 0,
            completion: (
                finished: false,
                errored: false,
                error: nil
            )
        )
    }

    func sink(completion: Subscribers.Completion<Swift.Error>) {
        switch completion {
        case .failure(let error):
            received.completion.errored = true
            received.completion.error = error
        case .finished:
            received.completion.finished = true
        }
    }

    func sink(receiveValue: Bool) {
        received.count += 1
    }

    func test_after_seconds() throws {

        publisher
            .retry(max: 5, delay: .seconds(1), scheduler: scheduler)
            .sink(completion: My.sink(completion:), receiveValue: My.sink(receiveValue:), on: self)
            .store(in: &bag)

        XCTAssertEqual(received.count, 1)

        scheduler.advance(by: .seconds(1))
        XCTAssertEqual(received.count, 2)

        scheduler.advance(by: .seconds(1))
        XCTAssertEqual(received.count, 3)

        scheduler.advance(by: .seconds(60))
        XCTAssertEqual(received.count, 6)

        XCTAssertTrue(received.completion.errored)
        XCTAssertEqual(received.completion.error as? Test, Test.explicitFail)
    }

    func test_zero() throws {

        let scheduler = DispatchQueue.test

        publisher
            .retry(max: 5, delay: .never, scheduler: scheduler)
            .sink(completion: My.sink(completion:), receiveValue: My.sink(receiveValue:), on: self)
            .store(in: &bag)

        XCTAssertEqual(received.count, 1)

        scheduler.advance(by: .seconds(1))
        XCTAssertEqual(received.count, 6)

        XCTAssertTrue(received.completion.errored)
        XCTAssertEqual(received.completion.error as? Test, Test.explicitFail)
    }

    func test_exponential() throws {

        var rng = NonRandomNumberGenerator(
            [
                16864412655522353077,
                13575047831205307916,
                16465027152260688579,
                4758078365451685014,
                5675376578459560188
            ]
        )

        publisher
            .retry(max: 5, delay: .exponential(unit: 1, using: &rng), scheduler: scheduler)
            .sink(completion: My.sink(completion:), receiveValue: My.sink(receiveValue:), on: self)
            .store(in: &bag)

        XCTAssertEqual(received.count, 1)

        scheduler.advance(by: .seconds(2))
        XCTAssertEqual(received.count, 2)

        scheduler.advance(by: .seconds(2))
        XCTAssertEqual(received.count, 3)

        scheduler.advance(by: .seconds(4))
        XCTAssertEqual(received.count, 4)

        scheduler.advance(by: .seconds(11))
        XCTAssertEqual(received.count, 6)

        XCTAssertTrue(received.completion.errored)
        XCTAssertEqual(received.completion.error as? Test, Test.explicitFail)
    }

    func test_fail_then_recover() throws {

        var tried = 0
        publisher.tryCatch { e -> AnyPublisher<Bool, Error> in
            defer { tried += 1 }
            if tried > 0 {
                return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                throw e
            }
        }
        .retry(max: 5, delay: .seconds(1), scheduler: scheduler)
        .sink(completion: My.sink(completion:), receiveValue: My.sink(receiveValue:), on: self)
        .store(in: &bag)

        XCTAssertEqual(received.count, 1)

        scheduler.advance(by: .seconds(1))

        XCTAssertEqual(received.count, 3)
        XCTAssertTrue(received.completion.finished)
    }

    func test_fail_condition_no_match_do_not_retry() throws {

        publisher
            .retry(max: 5, delay: .zero, if: { SwiftExtensions.isEqual($0, Test.onlyWhen) }, scheduler: scheduler)
            .sink(completion: My.sink(completion:), receiveValue: My.sink(receiveValue:), on: self)
            .store(in: &bag)

        XCTAssertEqual(received.count, 1)

        scheduler.advance(by: .seconds(1))
        XCTAssertEqual(received.count, 1)

        XCTAssertTrue(received.completion.errored)
        XCTAssertEqual(received.completion.error as? Test, Test.explicitFail)
    }

    func test_fail_condition_match_retries_max_attempts() throws {

        publisher
            .retry(max: 5, delay: .zero, if: { SwiftExtensions.isEqual($0, Test.explicitFail) }, scheduler: scheduler)
            .sink(completion: My.sink(completion:), receiveValue: My.sink(receiveValue:), on: self)
            .store(in: &bag)

        XCTAssertEqual(received.count, 1)

        scheduler.advance(by: .seconds(1))
        XCTAssertEqual(received.count, 6)

        XCTAssertTrue(received.completion.errored)
        XCTAssertEqual(received.completion.error as? Test, Test.explicitFail)
    }
}
