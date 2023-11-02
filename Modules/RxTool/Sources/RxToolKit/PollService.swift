// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxRelay
import RxSwift

/// The result of the poll
public enum PollResult<Value> {

    /// Final result - poll has finished and the result is the
    /// associated value
    case final(Value)

    /// Timeout result - take the last result before satisfying the match
    case timeout(Value)

    /// Cancellation
    case cancel
}

/// A service that polls using a given matcher (to check generically for value match)
/// and a fetch method
public class PollService<Value> {

    // MARK: - Types

    private enum ServiceError: Error {
        case conditionNotMet
        case pollCancelled
        case timeout(Value)
    }

    // MARK: - Properties

    private let matcher: (Value) -> Bool
    private var fetch: (() -> Single<Value>)!
    private let isActiveRelay = BehaviorRelay(value: false)
    private var endDate: Date = .distantPast

    /// Cancel polling
    public var cancel: Completable {
        Completable
            .create { [weak self] observer -> Disposable in
                self?.isActiveRelay.accept(false)
                observer(.completed)
                return Disposables.create()
            }
    }

    /// Stop polling if it has been cancelled.
    private var stopPollingIfNecessary: Single<Void> {
        isActiveRelay
            .take(1)
            .asSingle()
            .map { isActive in
                guard isActive else {
                    throw ServiceError.pollCancelled
                }
                return ()
            }
    }

    private var retryScheduler: Single<Int> {
        Single<Int>
            .timer(
                .seconds(5),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
    }

    // MARK: - Setup

    public init(matcher: @escaping (Value) -> Bool) {
        self.matcher = matcher
    }

    public func setFetch(_ fetch: @escaping () -> Single<Value>) {
        self.fetch = fetch
    }

    public func setFetch<A: AnyObject>(weak object: A, fetch: @escaping (A) -> Single<Value>) {
        self.fetch = { [weak object] in
            guard let object else {
                return .error(ToolKitError.nullReference(A.self))
            }
            return fetch(object)
        }
    }

    /// Start polling until the user reaches a given status on a given value, or a
    /// certain amount of time passes.
    public func poll(timeoutAfter seconds: TimeInterval) -> Single<PollResult<Value>> {
        endDate = Date().addingTimeInterval(seconds)
        return start()
    }

    /// Start polling by triggering waitForCondition
    private func start() -> Single<PollResult<Value>> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.isActiveRelay.accept(true)
                observer(.success(()))
                return Disposables.create()
            }
            .flatMap(weak: self) { (self, _: ()) -> Single<PollResult<Value>> in
                self.waitForMatch()
            }
    }

    private func waitForMatch() -> Single<PollResult<Value>> {
        stopPollingIfNecessary
            .flatMap(weak: self) { (self, _) -> Single<PollResult<Value>> in
                self.fetch()
                    .map(weak: self) { (self, value) in
                        try self.checkForTimeout(lastValue: value)
                    }
                    .map(weak: self) { (self, value) in
                        try self.checkForMatch(value: value)
                    }
                    .map { .final($0) }
                    .catchError(weak: self) { (self, error) in
                        self.catchError(error: error)
                    }
            }
    }

    /// Catches an error raised by `waitForCondition` and react accordingly.
    private func catchError(error: Error) -> Single<PollResult<Value>> {
        switch error {
        case ServiceError.timeout(let lastValue):
            cancel.andThen(Single.just(.timeout(lastValue)))
        case ServiceError.pollCancelled:
            cancel.andThen(Single.just(.cancel))
        case ServiceError.conditionNotMet:
            retryScheduler
                .flatMap(weak: self) { (self, _) -> Single<PollResult<Value>> in
                    self.waitForMatch()
                }
        default:
            /// Other network errors
            cancel.andThen(Single.error(error))
        }
    }

    private func checkForTimeout(lastValue: Value) throws -> Value {
        guard Date().timeIntervalSince(endDate) < 0 else {
            throw ServiceError.timeout(lastValue)
        }
        return lastValue
    }

    private func checkForMatch(value: Value) throws -> Value {
        guard matcher(value) else {
            throw ServiceError.conditionNotMet
        }
        return value
    }
}
