// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@dynamicMemberLookup
public enum Either<A, B> {
    case left(A), right(B)
}

extension Either where A == B {

    @inlinable public subscript<V>(dynamicMember keyPath: KeyPath<A, V>) -> V {
            switch self {
            case .left(let a): return a[keyPath: keyPath]
            case .right(let b): return b[keyPath: keyPath]
            }
        }
}

extension Either {
    public init(_ a: A) { self = .left(a) }
    public init(_ b: B) { self = .right(b) }
}

extension Either {

    @inlinable public var left: A? {
        if case .left(let a) = self {
            return a
        } else {
            return nil
        }
    }

    @inlinable public var right: B? {
        if case .right(let b) = self {
            return b
        } else {
            return nil
        }
    }

    @inlinable public var isLeft: Bool { left != nil }
    @inlinable public var isRight: Bool { right != nil }

    @inlinable public var inverted: Either<B, A> {
        switch self {
        case .left(let a):
            return .right(a)
        case .right(let b):
            return .left(b)
        }
    }
}

extension Either {

    @inlinable public subscript(type: A.Type = A.self) -> A? { left }
    @inlinable public subscript(type: B.Type = B.self) -> B? { right }

    @inlinable public func `is`(_: A.Type) -> Bool { left != nil }
    @inlinable public func `is`(_: B.Type) -> Bool { right != nil }

    @inlinable public func cast<T>(to: T.Type = T.self) -> T? {
        left as? T ?? right as? T
    }
}

extension Either: Identifiable where A: Hashable, B: Hashable {
    public var id: Self { self }
}

extension Either: Equatable where A: Equatable, B: Equatable {

    @inlinable public static func == (lhs: Either, rhs: Either<B, A>) -> Bool {
        switch (lhs, rhs) {
        case (.left(let l), .right(let r)):
            return l == r
        case (.right(let l), .left(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension Either: Hashable where A: Hashable, B: Hashable {}
extension Either: Comparable where A: Comparable, B: Comparable {

    public static func < (lhs: Either<A, B>, rhs: Either<A, B>) -> Bool {
        switch (lhs, rhs) {
        case (.left, .right):
            return true
        case (.right, .left):
            return false
        case (.left(let lhs), .left(let rhs)):
            return lhs < rhs
        case (.right(let lhs), .right(let rhs)):
            return lhs < rhs
        }
    }
}

extension Either: CustomStringConvertible {

    public var description: String {
        switch self {
        case .left(let a):
            return String(describing: a)
        case .right(let b):
            return String(describing: b)
        }
    }
}

public struct EitherDecodingError: Error {
    public let error: (left: Error, right: Error)
}

extension Either: Decodable where A: Decodable, B: Decodable {

    public init(from decoder: Decoder) throws {
        do {
            try self.init(A(from: decoder))
        } catch let a {
            do {
                try self.init(B(from: decoder))
            } catch let b {
                throw EitherDecodingError(error: (a, b))
            }
        }
    }
}

extension Either: Encodable where A: Encodable, B: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .left(let a):
            try a.encode(to: encoder)
        case .right(let b):
            try b.encode(to: encoder)
        }
    }
}

extension Either: CustomDebugStringConvertible {

    public var debugDescription: String { description }
}

extension Either: Sendable where A: Sendable, B: Sendable {}

extension Either {

    public static func randomRoute(
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>
    ) -> [Self] {
        let lower = max(0, length.lowerBound)
        let upper = max(lower, length.upperBound)
        return (0..<Int.random(in: lower...upper)).compactMap { _ -> Either? in
            Double.random(in: 0...1) < bias
                ? a.randomElement().map(Either.left)
                : b.randomElement().map(Either.right)
        }
    }

    public static func randomRoutes(
        count: Int,
        in a: [A],
        and b: [B],
        bias: Double = 0.5,
        length: ClosedRange<Int>
    ) -> [[Self]] {
        (0..<max(0, count)).map { _ in
            randomRoute(in: a, and: b, bias: bias, length: length)
        }
    }
}

extension Either where A: Error {

    @inlinable public var result: Result<B, A> {
        switch self {
        case .left(let a):
            return .failure(a)
        case .right(let b):
            return .success(b)
        }
    }
}

extension Either where B: Error {

    @inlinable public var result: Result<A, B> {
        switch self {
        case .left(let a):
            return .success(a)
        case .right(let b):
            return .failure(b)
        }
    }
}

extension Result {

    @inlinable public var either: Either<Success, Failure> {
        switch self {
        case .success(let a):
            return .left(a)
        case .failure(let b):
            return .right(b)
        }
    }
}

#if canImport(Combine)
import Combine

extension Either {

    public typealias Publisher = Deferred<Just<Either>>

    /// The publisher waits until it receives a request for at least one value, then sends the output to all subscribers and finishes normally.
    public var publisher: Either.Publisher {
        .init { Just(self) }
    }
}
#endif

extension Either {

    @inlinable public func fold<T>(left: (A) -> T, right: (B) -> T) -> T {
        switch self {
        case .left(let a):
            return left(a)
        case .right(let b):
            return right(b)
        }
    }

    @inlinable public func mapLeft<T>(_ transform: (A) -> T) -> Either<T, B> {
        switch self {
        case .left(let a):
            return .left(transform(a))
        case .right(let b):
            return .right(b)
        }
    }

    @inlinable public func flatMapLeft<T>(_ transform: (A) -> Either<T, B>) -> Either<T, B> {
        switch self {
        case .left(let a):
            return transform(a)
        case .right(let b):
            return .right(b)
        }
    }

    @inlinable public func mapRight<T>(_ transform: (B) -> T) -> Either<A, T> {
        switch self {
        case .left(let a):
            return .left(a)
        case .right(let b):
            return .right(transform(b))
        }
    }

    @inlinable public func flatMapLeft<T>(_ transform: (B) -> Either<A, T>) -> Either<A, T> {
        switch self {
        case .left(let a):
            return .left(a)
        case .right(let b):
            return transform(b)
        }
    }
}
