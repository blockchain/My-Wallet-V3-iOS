// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Extensions
import Foundation

/// An in-memory cache implementation.
public final class InMemoryCache<Key: Hashable, Value: Equatable>: CacheAPI {

    // MARK: - Private Types

    /// An item stored inside the cache.
    private struct CacheItem: Equatable {

        /// The cache value.
        let value: Value

        /// The time when the cache value was last refreshed.
        var lastRefresh: Date

        init(value: Value, lastRefresh: Date = Date()) {
            self.value = value
            self.lastRefresh = lastRefresh
        }
    }

    // MARK: - Private Properties

    private let cacheItems = Atomic<[Key: CacheItem]>([:])

    private let refreshControl: CacheRefreshControl

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup

    /// Creates an in-memory cache.
    ///
    /// - Parameters:
    ///   - configuration:  A cache configuration.
    ///   - refreshControl: A cache refresh control.
    public convenience init(
        configuration: CacheConfiguration,
        refreshControl: CacheRefreshControl,
        notificationCenter: NotificationCenter = .default
    ) {
        var isInTest: Bool { NSClassFromString("XCTestCase") != nil }
        if isInTest {
            self.init(
                configuration: configuration,
                refreshControl: refreshControl,
                notificationCenter: notificationCenter,
                app: App.preview
            )
        } else {
            self.init(
                configuration: configuration,
                refreshControl: refreshControl,
                notificationCenter: notificationCenter,
                app: resolve()
            )
        }
    }

    /// Creates an in-memory cache.
    ///
    /// - Parameters:
    ///   - configuration:  A cache configuration.
    ///   - refreshControl: A cache refresh control.
    public init(
        configuration: CacheConfiguration,
        refreshControl: CacheRefreshControl,
        notificationCenter: NotificationCenter = .default,
        app: AppProtocol
    ) {
        self.refreshControl = refreshControl

        for flushNotificationName in configuration.flushNotificationNames {
            notificationCenter
                .publisher(for: flushNotificationName)
                .flatMap { [removeAll] _ in removeAll() }
                .subscribe()
                .store(in: &cancellables)
        }

        for flush in configuration.flushEvents {
            switch flush {
            case .notification(let event):
                app.on(event) { [weak self] _ in self?.flush() }
                    .subscribe()
                    .store(in: &cancellables)
            case .binding(let event):
                app.publisher(for: event)
                    .sink { [weak self] _ in _ = self?.flush() }
                    .store(in: &cancellables)
            }
        }
    }

    // MARK: - Public Properties

    public func get(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        Deferred { [cacheItems, toCacheValue] () -> AnyPublisher<CacheValue<Value>, Never> in
            let cacheItem = cacheItems.value[key]
            let cacheValue = toCacheValue(cacheItem)

            return .just(cacheValue)
        }
        .eraseToAnyPublisher()
    }

    public func stream(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        cacheItems.publisher
            .map { $0[key] }
            .removeDuplicates()
            .map(toCacheValue)
            .share()
            .eraseToAnyPublisher()
    }

    public func set(_ value: Value, for key: Key) -> AnyPublisher<Value?, Never> {
        Deferred { [cacheItems] () -> AnyPublisher<Value?, Never> in
            let cacheItem = cacheItems
                .mutateAndReturn { cache in
                    cache.updateValue(CacheItem(value: value), forKey: key)
                }
            let cacheValue = cacheItem?.value

            return .just(cacheValue)
        }
        .eraseToAnyPublisher()
    }

    public func remove(key: Key) -> AnyPublisher<Value?, Never> {
        Deferred { [cacheItems] () -> AnyPublisher<Value?, Never> in
            let cacheItem = cacheItems.mutateAndReturn { $0.removeValue(forKey: key) }
            let cacheValue = cacheItem?.value

            return .just(cacheValue)
        }
        .eraseToAnyPublisher()
    }

    public func removeAll() -> AnyPublisher<Void, Never> {
        Deferred { [flush] () -> AnyPublisher<Void, Never> in
            .just(flush())
        }
        .eraseToAnyPublisher()
    }

    private func flush() {
        cacheItems.mutate { o in
            o.removeAll()
        }
    }

    // MARK: - Private Methods

    /// Maps the given cache item to a cache value.
    ///
    /// - Parameter cacheItem: A cache item.
    ///
    /// - Returns: A cache value.
    private func toCacheValue(cacheItem: CacheItem?) -> CacheValue<Value> {
        guard let cacheItem else {
            return .absent
        }

        if refreshControl.shouldRefresh(lastRefresh: cacheItem.lastRefresh) {
            return .stale(cacheItem.value)
        }

        return .present(cacheItem.value)
    }
}
