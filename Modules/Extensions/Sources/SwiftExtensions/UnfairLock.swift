// https://developer.apple.com/documentation/uikit/uiimage/building_high-performance_lists_and_collection_views

import Foundation

public final class UnfairLock {

    @usableFromInline let os_lock: UnsafeMutablePointer<os_unfair_lock>

    public init() {
        self.os_lock = .allocate(capacity: 1)
        os_lock.initialize(to: os_unfair_lock())
    }

    deinit {
        os_lock.deallocate()
    }

    @inlinable
    @inline(__always)
    public func lock() {
        os_unfair_lock_lock(os_lock)
    }

    @inlinable
    @inline(__always)
    public func unlock() {
        os_unfair_lock_unlock(os_lock)
    }

    @discardableResult
    @inlinable
    @inline(__always)
    public func withLock<Result>(body: () throws -> Result) rethrows -> Result {
        os_unfair_lock_lock(os_lock)
        defer { os_unfair_lock_unlock(os_lock) }
        return try body()
    }

    @inlinable
    @inline(__always)
    public func withLock(body: () -> Void) {
        os_unfair_lock_lock(os_lock)
        defer { os_unfair_lock_unlock(os_lock) }
        body()
    }

    @inlinable
    @inline(__always)
    public func assertOwner() {
        os_unfair_lock_assert_owner(os_lock)
    }

    @inlinable
    @inline(__always)
    public func assertNotOwner() {
        os_unfair_lock_assert_not_owner(os_lock)
    }
}

#if canImport(Combine)

import Combine

extension UnfairLock {

    private final class LockAssertion: Cancellable {
        private var _owner: UnfairLock

        init(owner: UnfairLock) {
            self._owner = owner
            os_unfair_lock_lock(owner.os_lock)
        }

        __consuming func cancel() {
            os_unfair_lock_unlock(_owner.os_lock)
        }
    }

    func acquire() -> Cancellable {
        LockAssertion(owner: self)
    }
}

#endif
