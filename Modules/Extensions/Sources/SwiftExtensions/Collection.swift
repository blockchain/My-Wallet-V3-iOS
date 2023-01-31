// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftformat:disable redundantSelf

import Algorithms

extension Collection {

    @inlinable public func filter<T>(_ type: T.Type) -> [T] {
        compactMap { $0 as? T }
    }

    @inlinable public func contains<T>(_ type: T.Type) -> Bool {
        contains(where: { $0 is T })
    }
}

extension BinaryInteger {

    @inlinable public func of<T>(_ value: @autoclosure () -> T) -> [T] {
        Array(repeating: value(), count: i)
    }

    @inlinable public func of<T>(_ value: () -> T) -> [T] {
        Array(repeating: value(), count: i)
    }
}

extension Collection where Element: Equatable {

    @inlinable public func sorted(like other: [Element]) -> [Element] {
        guard isNotEmpty, other.isNotEmpty else {
            return Array(self)
        }
        return sorted { a, b -> Bool in
            guard let first = other.firstIndex(of: a) else { return false }
            guard let second = other.firstIndex(of: b) else { return true }
            return first < second
        }
    }

    @inlinable public func sorted<Other: Collection>(
        like other: Other,
        other keyPath: KeyPath<Other.Element, Element>
    ) -> [Element] where Other.Element: Equatable {
        guard isNotEmpty, other.isNotEmpty else {
            return Array(self)
        }
        return sorted { a, b -> Bool in
            guard let first = other.firstIndex(where: { $0[keyPath: keyPath] == a }) else { return false }
            guard let second = other.firstIndex(where: { $0[keyPath: keyPath] == b }) else { return true }
            return first < second
        }
    }

    @inlinable public func sorted<Other: Collection>(
        like other: Other,
        my keyPath: KeyPath<Element, Other.Element>
    ) -> [Element] where Other.Element: Equatable {
        guard isNotEmpty, other.isNotEmpty else {
            return Array(self)
        }
        return sorted { a, b -> Bool in
            guard let first = other.firstIndex(where: { $0 == a[keyPath: keyPath] }) else { return false }
            guard let second = other.firstIndex(where: { $0 == b[keyPath: keyPath] }) else { return true }
            return first < second
        }
    }
}

extension Collection {

    @inlinable public func min<T>(
        using keyPath: KeyPath<Element, T>,
        by areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> Element? where T: Comparable {
        try self.min(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }

    @inlinable public func max<T>(
        using keyPath: KeyPath<Element, T>,
        by areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> Element? where T: Comparable {
        try self.max(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }

    @inlinable public func minAndMax<T>(
        using keyPath: KeyPath<Element, T>,
        by areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> (min: Element, max: Element)? where T: Comparable {
        try minAndMax(by: { try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) })
    }
}

extension Collection {
    @inlinable public var isNotEmpty: Bool { !isEmpty }
}

extension Collection where Element: Hashable {
    @inlinable public var set: Set<Element> { Set(self) }
}

extension Collection {
    @inlinable public var array: [Element] { Array(self) }
}

extension Collection {

    /// Returns a Boolean value indicating whether any element of a sequence satisfies a given predicate.
    @inlinable public func any(_ predicate: (Element) -> Bool) -> Bool {
        !allSatisfy { !predicate($0) }
    }
}

extension Collection {

    @inlinable public var firstAndOnly: Element? {
        count == 1 ? first : nil
    }
}

extension RandomAccessCollection {

    @inlinable public static func * (lhs: Self, rhs: Int) -> [Element] {
        let array = lhs.array
        return (0..<rhs).reduce(into: []) { o, _ in
            o.append(contentsOf: array)
        }
    }
}

extension Collection {

    /// Returns the result `Dictionary` keyed using the given `keyTransform` closure.
    public func dictionary<T: Hashable>(
        keyedBy keyTransform: (Element) -> T
    ) -> [T: Element] {
        reduce(into: [T: Element]()) { partialResult, element in
            partialResult[keyTransform(element)] = element
        }
    }
}
