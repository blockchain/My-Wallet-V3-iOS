// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ResultProtocol {

    associatedtype Success
    associatedtype Failure: Error

    var result: Result<Success, Failure> { get }

    static func success(_ success: Success) -> Self
    static func failure(_ failure: Failure) -> Self

    func map<NewSuccess>(
        _ transform: (Success) -> NewSuccess
    ) -> Result<NewSuccess, Failure>

    func mapError<NewFailure>(
        _ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> where NewFailure: Error

    func flatMap<NewSuccess>(
        _ transform: (Success) -> Result<NewSuccess, Failure>
    ) -> Result<NewSuccess, Failure>

    func flatMapError<NewFailure>(
        _ transform: (Failure) -> Result<Success, NewFailure>
    ) -> Result<Success, NewFailure> where NewFailure: Error

    func get() throws -> Success
}

extension Result: ResultProtocol {

    public var result: Result<Success, Failure> { self }

    @inlinable public var success: Success? {
        switch result {
        case .success(let success):
            success
        case .failure:
            nil
        }
    }

    @inlinable public var failure: Failure? {
        switch result {
        case .failure(let failure):
            failure
        case .success:
            nil
        }
    }
}

extension ResultProtocol {

    @inlinable public var isSuccess: Bool { success != nil }
    @inlinable public var isFailure: Bool { failure != nil }

    @inlinable public var success: Success? {
        switch result {
        case .success(let success):
            success
        case .failure:
            nil
        }
    }

    @inlinable public var failure: Failure? {
        switch result {
        case .success:
            nil
        case .failure(let failure):
            failure
        }
    }
}

extension RandomAccessCollection where Element: ResultProtocol {

    public func zip() -> Result<[Element.Success], Element.Failure> {
        switch count {
        case 0:
            .success([])
        case 1:
            self[_0]
                .map { [$0] }
        case 2:
            self[_0].result
                .zip(self[_1].result)
                .map { [$0, $1] }
        case 3:
            self[_0].result
                .zip(self[_1].result, self[_2].result)
                .map { [$0, $1, $2] }
        case 4:
            self[_0].result
                .zip(self[_1].result, self[_2].result, self[_3].result)
                .map { [$0, $1, $2, $3] }
        default:
            prefix(4).zip()
                .zip(dropFirst(4).zip())
                .map { $0 + $1 }
        }
    }

    private var _0: Index { startIndex }
    private var _1: Index { index(after: startIndex) }
    private var _2: Index { index(after: _1) }
    private var _3: Index { index(after: _2) }
}

extension Result {

    public func zip<A>(
        _ a: Result<A, Failure>
    ) -> Result<(Success, A), Failure> {
        flatMap { success in
            switch a {
            case .success(let a):
                .success((success, a))
            case .failure(let error):
                .failure(error)
            }
        }
    }

    public func zip<A, B>(
        _ a: Result<A, Failure>,
        _ b: Result<B, Failure>
    ) -> Result<(Success, A, B), Failure> {
        zip(a)
            .zip(b)
            .map { ($0.0, $0.1, $1) }
    }

    public func zip<A, B, C>(
        _ a: Result<A, Failure>,
        _ b: Result<B, Failure>,
        _ c: Result<C, Failure>
    ) -> Result<(Success, A, B, C), Failure> {
        zip(a, b)
            .zip(c)
            .map { ($0.0, $0.1, $0.2, $1) }
    }

    public func zip<A, B, C, D>(
        _ a: Result<A, Failure>,
        _ b: Result<B, Failure>,
        _ c: Result<C, Failure>,
        _ d: Result<D, Failure>
    ) -> Result<(Success, A, B, C, D), Failure> {
        zip(a, b, c)
            .zip(d)
            .map { ($0.0, $0.1, $0.2, $0.3, $1) }
    }
}

extension Result where Success: OptionalProtocol {

    public func onNil(error: Failure) -> Result<Success.Wrapped, Failure> {
        flatMap { element -> Result<Success.Wrapped, Failure> in
            guard let value = element.wrapped else {
                return .failure(error)
            }
            return .success(value)
        }
    }
}

extension Result where Failure == Never {

    public func mapError<E: Error>(to type: E.Type) -> Result<Success, E> {
        mapError()
    }

    public func mapError<E: Error>() -> Result<Success, E> {
        switch self {
        case .success(let value):
            .success(value)
        }
    }
}

extension Result where Success == Never {

    public func map<T>(to type: T.Type) -> Result<T, Failure> {
        map()
    }

    public func map<T>() -> Result<T, Failure> {
        switch self {
        case .failure(let error):
            .failure(error)
        }
    }
}

extension Result {

    public func replaceError<E: Error>(with error: E) -> Result<Success, E> {
        mapError { _ in error }
    }
}

extension Result {

    public func eraseError() -> Result<Success, Error> {
        mapError { $0 }
    }
}

extension Result {

    public func reduce<NewValue>(_ transform: (Result<Success, Failure>) -> NewValue) -> NewValue {
        transform(self)
    }
}
