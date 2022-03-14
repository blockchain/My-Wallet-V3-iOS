// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxRelay
import RxSwift

/// This implements an in-memory cache with transparent refreshing/invalidation
public class CachedValue<Value> {

    /// Any error produced internally
    private enum CachedValueError: Error {
        /// The fetch method is undefined
        case fetchMethodUndefined
    }

    /// Typealias for fetch method
    typealias FetchMethod = () -> Single<Value>

    /// Streams a single value and terminates
    public var valueSingle: Single<Value> {
        _ = setup
        return Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return self.fetch()
        }
    }

    /// Fetches the value and updates the cache for future subscribers.
    /// It streams the fetched value afterwards.
    public var fetchValue: Single<Value> {
        performFetchAndUpdateCache()
    }

    public func invalidate() {
        _ = setup
        refreshControl.actionRelay.accept(.flush)
    }

    /// Sets the fetch method. Must be called before any subscription.
    /// - Parameter fetch: The fetch method.
    public func setFetch(_ fetch: @escaping () -> Single<Value>) {
        fetchMethod = fetch
    }

    /// Sets the fetch method. Must be called before any subscription.
    /// - Parameters:
    ///   - object: Weakly referenced object
    ///   - fetch: Fetch method
    public func setFetch<A: AnyObject>(weak object: A, fetch: @escaping (A) -> Single<Value>) {
        fetchMethod = { [weak object] in
            guard let object = object else {
                return .error(ToolKitError.nullReference(A.self))
            }
            return fetch(object)
        }
    }

    private lazy var setup: Void = refreshControl.action
        .do(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .fetch:
                self.refresh()
            case .flush:
                self.flush()
            }
        })
        .subscribe()
        .disposed(by: disposeBag)

    private var fetchMethod: FetchMethod?
    private let atomicValue = Atomic<Value?>(nil)
    private let disposeBag = DisposeBag()
    private let configuration: CachedValueConfiguration
    private let refreshControl: CachedValueRefreshControl

    public init(
        configuration: CachedValueConfiguration
    ) {
        self.configuration = configuration
        refreshControl = CachedValueRefreshControl(configuration: configuration)
    }

    private func flush() {
        atomicValue.mutate { $0 = nil }
    }

    private func refresh() {
        performFetchAndUpdateCache()
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func fetch() -> Single<Value> {
        guard refreshControl.shouldRefresh else {
            guard let value = atomicValue.value else {
                return performFetchAndUpdateCache()
            }
            return .just(value)
        }
        return performFetchAndUpdateCache()
    }

    @discardableResult
    private func performFetchAndUpdateCache() -> Single<Value> {
        performFetch()
            .do(onSuccess: { [weak self] value in
                self?.refreshControl.update(refreshDate: Date())
                self?.atomicValue.mutate { $0 = value }
            })
            .observe(on: configuration.scheduler)
            .subscribe(on: configuration.scheduler)
    }

    private func performFetch() -> Single<Value> {
        guard let fetch = fetchMethod else {
            fatalError(CachedValueError.fetchMethodUndefined.localizedDescription)
        }
        return fetch()
    }
}
