// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AnyOptionalProtocol: ExpressibleByNilLiteral {
    static var null: AnyOptionalProtocol { get }
    var flattened: Any? { get }
}

public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped

    var wrapped: Wrapped? { get }
    static var none: Self { get }

    static func some(_ newValue: Wrapped) -> Self
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

extension OptionalProtocol {
    public var isNil: Bool { wrapped == nil }
    public var isNotNil: Bool { wrapped != nil }
}

public func recursiveFlatMapOptional(_ any: Any?) -> Any? {
    any.flattened
}

extension Optional: AnyOptionalProtocol {
    @inlinable public static var null: AnyOptionalProtocol { Optional.none as AnyOptionalProtocol }
    @inlinable public var flattened: Any? {
        switch self {
        case nil:
            return nil
        case let wrapped?:
            return (wrapped as? AnyOptionalProtocol)?.flattened ?? wrapped
        }
    }
}

extension Optional: OptionalProtocol {
    @inlinable public var wrapped: Wrapped? { self }
}

// Optional Throw
infix operator ??^: AssignmentPrecedence

extension Optional {

    public enum GetError: Error {
        case isNil
    }

    @discardableResult
    public func or(throw error: @autoclosure () -> some Error) throws -> Wrapped {
        guard let value = self else { throw error() }
        return value
    }

    public func or(default defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        guard let value = self else { return defaultValue() }
        return value
    }

    public func `as`<T>(_ type: T.Type) -> T? {
        wrapped as? T
    }

    public subscript<T>(_: T.Type = T.self) -> T? {
        wrapped as? T
    }

    public static func ??^ (lhs: Optional, rhs: @autoclosure () -> some Error) throws -> Wrapped {
        try lhs.or(throw: rhs())
    }
}

// Optional Assignment
infix operator ?=: AssignmentPrecedence

public func ?= <A>(l: inout A, r: A?) {
    if let r { l = r }
}

extension Optional {

    @inlinable public func map<T>(_ type: T.Type) -> T? { self as? T }
}

extension Collection {

    @inlinable public var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension Optional where Wrapped: Collection {

    @inlinable public var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }

    @inlinable public var isNotNilOrEmpty: Bool {
        !isNilOrEmpty
    }

    @inlinable public var nilIfEmpty: Optional {
        isNilOrEmpty ? nil : self
    }
}

extension Optional where Wrapped: Collection & ExpressibleByArrayLiteral {

    @inlinable public var emptyIfNil: Wrapped {
        switch self {
        case .none:
            return []
        case .some(let wrapped):
            return wrapped
        }
    }

    @inlinable public var emptyIfNilOrNotEmpty: Self {
        switch self {
        case .none:
            return .some([])
        case .some(let wrapped):
            return wrapped.isEmpty ? .none : .some(wrapped)
        }
    }
}

extension Optional where Wrapped: Collection & ExpressibleByStringLiteral {

    @inlinable public var emptyIfNil: Wrapped {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Optional: CustomStringConvertible {

    public var description: String {
        switch self {
        case .none:
            return "nil"
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
}

public protocol OptionalCodingPropertyWrapper {
    associatedtype WrappedType: ExpressibleByNilLiteral
    var wrappedValue: WrappedType { get }
    init(wrappedValue: WrappedType)
}

extension KeyedDecodingContainer {

    public func decode<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> T where T: Decodable, T: OptionalCodingPropertyWrapper {
        (try? decodeIfPresent(T.self, forKey: key)) ?? T(wrappedValue: nil)
    }
}

extension KeyedEncodingContainer {

    public mutating func encode(
        _ value: some Encodable & OptionalCodingPropertyWrapper,
        forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        if case Optional<Any>.none = value.wrappedValue as Any { return }
        try encodeIfPresent(value, forKey: key)
    }
}

extension Optional where Wrapped: Swift.Codable {

    @propertyWrapper
    public struct Codable: Swift.Codable, OptionalCodingPropertyWrapper {

        public var wrappedValue: Wrapped?

        public init(wrappedValue: Wrapped?) {
            self.wrappedValue = wrappedValue
        }

        public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                self.wrappedValue = try container.decode(Wrapped.self)
            } catch {
                self.wrappedValue = try? Wrapped(from: decoder)
            }
        }

        public func encode(to encoder: Encoder) throws {
            do {
                var container = encoder.singleValueContainer()
                try container.encode(wrappedValue)
            } catch {
                try? wrappedValue.encode(to: encoder)
            }
        }
    }
}

extension Optional.Codable: Equatable where Wrapped: Equatable {}
extension Optional.Codable: Hashable where Wrapped: Hashable {}
