// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// A value returned by a cache.
///
/// The cache consumers can request stale cache values (in order to speed up apparent loading times), which should be handled accordingly.
public enum CacheValue<Value>: CustomStringConvertible {

    /// Absent cache value.
    case absent

    /// Stale cache value.
    case stale(Value)

    /// Present and non-stale cache value.
    case present(Value)

    // MARK: - Public Properties

    public var description: String {
        switch self {
        case .absent:
            "absent"
        case .stale(let value):
            "stale(\(value))"
        case .present(let value):
            "present(\(value))"
        }
    }
}

extension CacheValue: Equatable where Value: Equatable {}

/// A cache, representing a key-value data store.
public protocol CacheAPI {

    /// A key used as a cache index.
    associatedtype Key: Hashable

    /// A value stored in the cache.
    associatedtype Value: Equatable

    /// Gets the cache value associated with the given key.
    ///
    /// - Parameter key: The key to look up in the cache.
    ///
    /// - Returns: A publisher that emits the cache value.
    func get(key: Key) -> AnyPublisher<CacheValue<Value>, Never>

    /// Streams the cache value associated with the given key, including any subsequent updates.
    ///
    /// - Parameter key: The key to look up in the cache.
    ///
    /// - Returns: A publisher that streams the cache value, including any subsequent updates.
    func stream(key: Key) -> AnyPublisher<CacheValue<Value>, Never>

    /// Stores the given value, associating it with the given key.
    ///
    /// - Parameters:
    ///   - value: A value to store inside the cache.
    ///   - key:   The key to associate with `value`.
    ///
    /// - Returns: A publisher that emits the replaced value, or `nil` if a new value was stored.
    func set(_ value: Value, for key: Key) -> AnyPublisher<Value?, Never>

    /// Removes the value associated with the given key.
    ///
    /// - Parameter key: The key to look up in the cache.
    ///
    /// - Returns: A publisher that emits the removed value, or `nil` if the key was not present in the cache.
    func remove(key: Key) -> AnyPublisher<Value?, Never>

    /// Removes all the stored values.
    ///
    /// - Returns: A publisher that emits a void value.
    func removeAll() -> AnyPublisher<Void, Never>
}

/// A type-erased cache.
public final class AnyCache<Key: Hashable, Value: Equatable>: CacheAPI {

    // MARK: - Private Properties

    private let getKey: (Key) -> AnyPublisher<CacheValue<Value>, Never>

    private let streamKey: (Key) -> AnyPublisher<CacheValue<Value>, Never>

    private let setKey: (Value, Key) -> AnyPublisher<Value?, Never>

    private let removeKey: (Key) -> AnyPublisher<Value?, Never>

    private let removeAllKeys: () -> AnyPublisher<Void, Never>

    // MARK: - Setup

    /// Creates a type-erased cache that wraps the given instance.
    ///
    /// - Parameter cache: A cache to wrap.
    public init<Cache: CacheAPI>(
        _ cache: Cache
    ) where Cache.Key == Key, Cache.Value == Value {
        self.getKey = cache.get
        self.streamKey = cache.stream
        self.setKey = cache.set
        self.removeKey = cache.remove
        self.removeAllKeys = cache.removeAll
    }

    // MARK: - Public Methods

    public func get(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        getKey(key)
    }

    public func stream(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        streamKey(key)
    }

    public func set(_ value: Value, for key: Key) -> AnyPublisher<Value?, Never> {
        setKey(value, key)
    }

    public func remove(key: Key) -> AnyPublisher<Value?, Never> {
        removeKey(key)
    }

    public func removeAll() -> AnyPublisher<Void, Never> {
        removeAllKeys()
    }
}

extension CacheAPI {

    /// Wraps this cache with a type eraser.
    public func eraseToAnyCache() -> AnyCache<Key, Value> {
        AnyCache(self)
    }
}
