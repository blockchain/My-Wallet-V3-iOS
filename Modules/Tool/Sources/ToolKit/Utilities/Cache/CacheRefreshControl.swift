// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// A cache refresh control.
public protocol CacheRefreshControl {

    /// Returns a `Boolean` value indicating whether the cache value should be refreshed.
    ///
    /// - Parameter lastRefresh: The time when the cache value was last refreshed.
    func shouldRefresh(lastRefresh: Date) -> Bool
    func invalidate()
}

/// A cache refresh control that never expires.
public final class PerpetualCacheRefreshControl: CacheRefreshControl {

    public init() {}

    public func shouldRefresh(lastRefresh: Date) -> Bool {
        false
    }

    public func invalidate() {}
}

/// A periodic cache refresh control, checking cache values that should be refreshed based on a given refresh interval.
public final class PeriodicCacheRefreshControl: CacheRefreshControl {

    // MARK: - Private Properties

    /// The refresh interval.
    /// Cache values with a `lastRefresh` time older than the start of this interval, relative to the current time, should be refreshed.
    private let refreshInterval: TimeInterval
    private var invalidatedAt: Date?

    // MARK: - Setup

    /// Creates a periodic cache refresh control.
    ///
    /// - Parameter refreshInterval: A refresh interval.
    public init(refreshInterval: TimeInterval) {
        self.refreshInterval = refreshInterval
    }

    // MARK: - Public Methods

    public func shouldRefresh(lastRefresh: Date) -> Bool {
        if let invalidatedAt, lastRefresh < invalidatedAt {
            return true
        }
        return lastRefresh < Date(timeIntervalSinceNow: -refreshInterval)
    }

    public func invalidate() {
        invalidatedAt = Date()
    }
}

// MARK: Remote RefreshControl

/// Used with `RemotePeriodicCacheRefreshControl`
public struct RemoteCacheConfig: Decodable {
    // The amount of time of expiration for this cache
    let interval: Int
    // When `true` disables the cache, ignores `interval`
    let disable: Bool

    public init(interval: Int, disable: Bool) {
        self.interval = interval
        self.disable = disable
    }
}

/// A convenient `CacheRerfresh` that loads a remote configuration of type `RemoteRefreshControlConfig`
public final class RemotePeriodicCacheRefreshControl: CacheRefreshControl {

    private var config: RemoteCacheConfig
    private var invalidatedAt: Date?

    private var cancellables: Set<AnyCancellable> = []

    public init(
        defaultConfig: RemoteCacheConfig,
        fetch: @escaping () -> AnyPublisher<RemoteCacheConfig?, Error>
    ) {
        self.config = defaultConfig
        // Fetch the remote config
        fetch()
            .replaceError(with: defaultConfig)
            .sink(
                receiveValue: { [weak self, defaultConfig] remoteConfig in
                    self?.config = remoteConfig ?? defaultConfig
                }
            )
            .store(in: &cancellables)
    }

    public func shouldRefresh(lastRefresh: Date) -> Bool {
        if config.disable {
            return true
        } else if let invalidatedAt, lastRefresh < invalidatedAt {
            return true
        } else {
            return lastRefresh < Date(timeIntervalSinceNow: -Double(config.interval))
        }
    }

    public func invalidate() {
        invalidatedAt = Date()
    }
}
