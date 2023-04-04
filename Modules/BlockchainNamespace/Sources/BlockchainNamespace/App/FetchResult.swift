// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions
import Foundation

public enum FetchResult {
    case value(Any, Metadata)
    case error(FetchResult.Error, Metadata)
}

extension FetchResult {

    public enum Error: Swift.Error, LocalizedError {
        case keyDoesNotExist(Tag.Reference)
        case decoding(AnyDecoder.Error)
        case other(Swift.Error)

        @usableFromInline init(_ error: some Swift.Error) {
            if let error = extract(FetchResult.Error.self, from: error) {
                self = error
            } else if let error = extract(AnyDecoder.Error.self, from: error) {
                self = .decoding(error)
            } else {
                self = .other(error)
            }
        }

        public var errorDescription: String? {
            switch self {
            case .keyDoesNotExist(let reference):
                return "\(reference) does not exist"
            case .decoding(let error):
                return error.errorDescription
            case .other(let error):
                return String(describing: error)
            }
        }
    }
}

public struct Metadata {
    public let ref: Tag.Reference
    public let source: Source
    public let file: String, line: Int
}

extension Metadata {

    public enum Source {
        case app
        case undefined
        case state
        case remoteConfiguration
        case bindings
        case napi
    }
}

extension FetchResult {

    public var metadata: Metadata {
        switch self {
        case .value(_, let metadata), .error(_, let metadata):
            return metadata
        }
    }

    public var isSuccess: Bool { value != nil }
    public var isFailure: Bool { error != nil }

    public var value: Any? {
        switch self {
        case .value(let any, _):
            return any
        case .error:
            return nil
        }
    }

    public var error: FetchResult.Error? {
        switch self {
        case .error(let error, _):
            return error
        case .value:
            return nil
        }
    }

    public init(_ any: Any, metadata: Metadata) {
        self = .value(any, metadata)
    }

    public init(_ error: Error, metadata: Metadata) {
        self = .error(error, metadata)
    }

    public init(catching body: () throws -> Any, _ metadata: Metadata) {
        self.init(.init(catching: body), metadata)
    }

    public init(_ result: Result<Any, some Swift.Error>, _ metadata: Metadata) {
        switch result {
        case .success(let value):
            self = .value(value, metadata)
        case .failure(let error as FetchResult.Error):
            self = .error(error, metadata)
        case .failure(let error as AnyDecoder.Error):
            self = .error(.decoding(error), metadata)
        case .failure(let error):
            self = .error(.other(error), metadata)
        }
    }

    public static func create<E: Swift.Error>(
        _ metadata: Metadata
    ) -> (
        _ result: Result<Any, E>
    ) -> FetchResult {
        { result in FetchResult(result, metadata) }
    }

    public static func create(
        _ metadata: Metadata
    ) -> (
        _ result: Any?
    ) -> FetchResult {
        { result in
            if let any = result {
                return .value(any, metadata)
            } else {
                return .error(.keyDoesNotExist(metadata.ref), metadata)
            }
        }
    }
}

extension Tag {

    public func metadata(_ source: Metadata.Source = .undefined, file: String = #fileID, line: Int = #line) -> Metadata {
        Metadata(ref: reference, source: source, file: file, line: line)
    }
}

extension Tag.Reference {

    public func metadata(_ source: Metadata.Source = .undefined, file: String = #fileID, line: Int = #line) -> Metadata {
        Metadata(ref: self, source: source, file: file, line: line)
    }
}

public protocol DecodedFetchResult {

    associatedtype Value: Decodable

    var identity: FetchResult.Value<Value> { get }

    static func value(_ value: Value, _ metatata: Metadata) -> Self
    static func error(_ error: FetchResult.Error, _ metatata: Metadata) -> Self

    func get() throws -> Value
}

extension FetchResult {

    typealias Decoded = DecodedFetchResult

    public enum Value<T: Decodable>: DecodedFetchResult {
        case value(T, Metadata)
        case error(FetchResult.Error, Metadata)
    }

    public func decode<T: Decodable>(
        _ type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) -> Value<T> {
        do {
            switch self {
            case .value(let value, let metadata):
                return try .value(decoder.decode(T.self, from: value), metadata)
            case .error(let error, _):
                throw error
            }
        } catch let error as AnyDecoder.Error {
            return .error(.decoding(error), metadata)
        } catch {
            return .error(FetchResult.Error(error), metadata)
        }
    }

    public var result: Result<Any, FetchResult.Error> {
        switch self {
        case .value(let value, _):
            return .success(value)
        case .error(let error, _):
            return .failure(error)
        }
    }

    public func get() throws -> Any {
        try result.get()
    }
}

extension FetchResult.Value {
    public var identity: FetchResult.Value<T> { self }
}

extension DecodedFetchResult {

    public var metadata: Metadata {
        switch identity {
        case .value(_, let metadata), .error(_, let metadata):
            return metadata
        }
    }

    public var value: Value? {
        switch identity {
        case .value(let value, _):
            return value
        case .error:
            return nil
        }
    }

    public var error: FetchResult.Error? {
        switch identity {
        case .error(let error, _):
            return error
        case .value:
            return nil
        }
    }

    public var result: Result<Value, FetchResult.Error> {
        switch identity {
        case .value(let value, _):
            return .success(value)
        case .error(let error, _):
            return .failure(error)
        }
    }

    public func get() throws -> Value {
        try result.get()
    }

    public func map<T>(_ transform: (Value) -> (T)) -> FetchResult.Value<T> {
        switch identity {
        case .error(let error, let metadata):
            return .error(error, metadata)
        case .value(let value, let metadata):
            return .value(transform(value), metadata)
        }
    }

    public func flatMap<T>(_ transform: (Value, Metadata) -> (FetchResult.Value<T>)) -> FetchResult.Value<T> {
        switch identity {
        case .error(let error, let metadata):
            return .error(error, metadata)
        case .value(let value, let metadata):
            return transform(value, metadata)
        }
    }
}

#if canImport(Combine)

import AnyCoding
import Combine

extension Publisher where Output == FetchResult {

    public func decode<T>(
        _: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) -> AnyPublisher<FetchResult.Value<T>, Failure> {
        map { result in result.decode(T.self, using: decoder) }
            .eraseToAnyPublisher()
    }

    @_disfavoredOverload
    public func cast<T>(_ type: T.Type) -> Publishers.CompactMap<Self, T> {
        compactMap { result in
            result.value as? T
        }
    }

    @_disfavoredOverload
    public func decode<T: Decodable>(
        _ type: T.Type,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) -> Publishers.CompactMap<Self, T> {
        compactMap { result in
            result.decode(T.self, using: decoder).value
        }
    }
}

extension Publisher where Output: DecodedFetchResult {

    public func replaceError(
        with value: Output.Value
    ) -> AnyPublisher<Output.Value, Failure> {
        flatMap { output -> Just<Output.Value> in
            switch output.result {
            case .failure:
                return Just(value)
            case .success(let value):
                return Just(value)
            }
        }
        .eraseToAnyPublisher()
    }

    public func assign<Root>(
        to keyPath: ReferenceWritableKeyPath<Root, Output.Value>,
        on object: Root,
        onError: @escaping (FetchResult.Error) -> Void = { _ in }
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] value in
            guard let object else { return }
            switch value.result {
            case .success(let value):
                object[keyPath: keyPath] = value
            case .failure(let error):
                onError(error)
            }
        }
    }
}

#endif

extension Dictionary where Key == Tag {

    public func decode<T: Decodable>(
        _ key: L,
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decode(key[], as: T.self, using: decoder)
    }

    public func decode<T: Decodable>(
        _ key: Tag,
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try FetchResult.value(self[key] as Any, key.metadata())
            .decode(T.self, using: decoder)
            .get()
    }
}

extension Optional {

    public func decode<T: Decodable>(
        _ type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: self as Any)
    }
}

extension AnyHashable {

    public func decode<T: Decodable>(
        _ type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: base)
    }
}
