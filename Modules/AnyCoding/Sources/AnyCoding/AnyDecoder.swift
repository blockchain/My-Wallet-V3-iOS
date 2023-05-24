// https://github.com/ollieatkinson/Eumorphic/blob/anything/Sources/Anything/AnyDecoder.swift

import Combine
import CoreGraphics
import Foundation
import SwiftExtensions

public protocol AnyDecoderProtocol: AnyObject, Decoder {

    var value: Any { get set }
    var codingPath: [CodingKey] { get set }
    var userInfo: [CodingUserInfoKey: Any] { get set }

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any])

    func decode<T>(_: T.Type, from any: Any) throws -> T where T: Decodable
    func convert<T>(_ any: Any, to: T.Type) throws -> Any?
}

extension AnyDecoderProtocol {

    @_disfavoredOverload
    public func decode<T>(_: T.Type, from any: Any?) throws -> T where T: Decodable {
        try decode(T.self, from: any as Any)
    }
}

open class AnyDecoder: AnyDecoderProtocol, TopLevelDecoder {

    public var codingPath: [CodingKey] = []
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public var value: Any = NSNull()

    internal var `super`: Decoder?

    public required init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    public func decode<T>(_: T.Type = T.self, from any: Any) throws -> T where T: Decodable {
        if let any = any as? T { return any }
        let old = value
        value = any
        defer { value = old }
        do {
            if let o = T.self as? OptionalDecodableProtocol.Type {
                return o.decodeUnwrapped(from: self) as! T
            }
            if let optional = any as? AnyOptionalProtocol {
                guard let value = optional.flattened else { throw valueNotFound(T.self, at: codingPath) }
                return try decode(T.self, from: value)
            } else if let o = try convert(any, to: T.self) as? T {
                return o
            }
            return try T(from: self)
        } catch {
            return try ((T.self as? AnyOptionalProtocol.Type)?.null as? T).or(throw: error)
        }
    }

    public func decode<T>(_: T?.Type = T?.self, from any: Any) -> T? where T: Decodable {
        try? decode(T.self, from: any)
    }

    // swiftlint:disable cyclomatic_complexity
    open func convert<T>(_ any: Any, to type: T.Type) throws -> Any? {
        if let any = any as? T { return any }
        switch (any, T.self) {
        case (let any as AnyJSON, _):
            return try convert(any.wrapped, to: T.self)
        case (let time as TimeInterval, is Date.Type):
            return Date(timeIntervalSince1970: time)
        case (let string as String, is URL.Type):
            return try URL(string: string).or(throw: Error(message: "'\(string)' is not a URL", at: codingPath))
        case (let number as NSNumber, is Bool.Type):
            return number.boolValue
        case (let number as NSNumber, is Int.Type):
            return number.intValue
        case (let number as NSNumber, is UInt.Type):
            return number.uintValue
        case (let number as NSNumber, is Float.Type):
            return number.floatValue
        case (let number as NSNumber, is Double.Type):
            return number.doubleValue
        case (let number as NSNumber, is CGFloat.Type):
            return number.doubleValue
        case (let boolean as Bool, is String.Type):
            return boolean.description
        case (let string as String, is Int.Type):
            return Int(string)
        case (let string as String, is Bool.Type):
            return Bool(string)
        case (let string as CustomStringConvertible, is String.Type):
            return string.description
        case (let data as Data, _) where !(T.self is Data.Type):
            return try JSONSerialization.jsonObject(with: data)
        default:
            switch Wrapper<T>.self {
            case let rawRepresentable as AnyRawRepresentable.Type:
                return rawRepresentable.value(from: any, using: self)
            default:
                return nil
            }
        }
    }
}

extension AnyDecoder {

    public struct Error: Swift.Error, LocalizedError, Equatable {

        public let message: String
        public let codingPath: [CodingKey]

        public init(
            message: String,
            at codingPath: [CodingKey]
        ) {
            self.message = message
            self.codingPath = codingPath
        }

        public var errorDescription: String? { message }

        public static func == (x: Self, y: Self) -> Bool {
            x.message == y.message && x.codingPath.string == y.codingPath.string
        }
    }

    func valueNotFound<T>(
        _: T.Type,
        at codingPath: [CodingKey]
    ) -> Error {
        .init(
            message: "Value of type \(T.self) not found at coding path /\(codingPath.string); found \(Swift.type(of: value)). \(value)",
            at: codingPath
        )
    }
}

extension AnyDecoder {

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        try KeyedDecodingContainer(KeyedContainer<Key>(decoder: self))
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try UnkeyedContainer(decoder: self)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        try SingleValueContainer(decoder: self)
    }
}

extension AnyDecoder {

    public struct KeyedContainer<Key> where Key: CodingKey {

        let decoder: AnyDecoder
        public let dictionary: [String: Any]

        public var codingPath: [CodingKey] { decoder.codingPath }
        public var userInfo: [CodingUserInfoKey: Any] { decoder.userInfo }

        public init(decoder: AnyDecoder) throws {
            self.decoder = decoder
            self.dictionary = try ((decoder.convert(decoder.value, to: [String: Any].self) ?? decoder.value) as? [String: Any])
                .or(throw: Error(message: "Expected a [String: Any] but got: \(decoder.value)", at: decoder.codingPath))
        }

        public func value(for key: Key) throws -> Any {
            try dictionary[key.stringValue]
                .or(throw: Error(message: "No value found for key '\(key.stringValue)'", at: codingPath))
        }
    }
}

extension AnyDecoder.KeyedContainer: KeyedDecodingContainerProtocol {

    public var allKeys: [Key] {
        dictionary.keys.compactMap(Key.init)
    }

    public func contains(_ key: Key) -> Bool {
        dictionary[key.stringValue] != nil
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        dictionary[key.stringValue].isNil
    }

    public func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let value = try value(for: key)
        decoder.codingPath.append(AnyCodingKey(key.stringValue))
        defer { decoder.codingPath.removeLast() }
        return try decoder.decode(type, from: value)
    }

    public func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T: Decodable {
        try? decode(type, forKey: key)
    }
}

extension AnyDecoder {

    public struct SingleValueContainer {

        public let decoder: AnyDecoder
        public let value: Any

        public var codingPath: [CodingKey] { decoder.codingPath }
        public var userInfo: [CodingUserInfoKey: Any] { decoder.userInfo }

        public init(decoder: AnyDecoder) throws {
            self.decoder = decoder
            self.value = decoder.value
        }
    }
}

extension AnyDecoder.SingleValueContainer: SingleValueDecodingContainer {

    public func decodeNil() -> Bool {
        recursiveFlatMapOptional(value).isNil
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        guard type.containerType == .singleValue else { return try decoder.decode(from: value) }
        if let value = value as? T { return value }
        if let error = value as? Swift.Error { throw error }
        throw decoder.valueNotFound(T.self, at: codingPath)
    }
}

extension AnyDecoder {

    public struct UnkeyedContainer {

        public let array: [Any]
        public let decoder: AnyDecoder

        public var count: Int? { array.count }
        public private(set) var currentIndex: Int = 0

        public var codingPath: [CodingKey] { decoder.codingPath }
        public var userInfo: [CodingUserInfoKey: Any] { decoder.userInfo }

        public init(decoder: AnyDecoder) throws {
            self.decoder = decoder
            self.array = try ((decoder.convert(decoder.value, to: [Any].self) ?? decoder.value) as? [Any])
                .or(throw: Error(message: "Expected a [Any] but got: \(decoder.value)", at: decoder.codingPath))
        }
    }
}

extension AnyDecoder.UnkeyedContainer: UnkeyedDecodingContainer {

    public var isAtEnd: Bool { currentIndex == count }

    public mutating func decodeNil() throws -> Bool {
        let null = recursiveFlatMapOptional(array[currentIndex]).isNil
        defer { currentIndex += null ? 1 : 0 }
        return null
    }

    public mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        defer { currentIndex += 1 }
        decoder.codingPath.append(AnyCodingKey(currentIndex))
        defer { decoder.codingPath.removeLast() }
        return try decoder.decode(from: array[currentIndex])
    }

    public mutating func decodeIfPresent<T>(_ type: T.Type) throws -> T? where T: Decodable {
        try? decode(type)
    }
}

extension AnyDecoder.KeyedContainer {

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(AnyCodingKey(key.stringValue))
        defer { decoder.codingPath.removeLast() }
        let nested = AnyDecoder(codingPath: codingPath, userInfo: userInfo)
        nested.value = dictionary[key.stringValue] as Any
        nested.super = decoder
        return try AnyDecoder.UnkeyedContainer(decoder: nested)
    }

    public func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        decoder.codingPath.append(AnyCodingKey(key.stringValue))
        defer { decoder.codingPath.removeLast() }
        let nested = AnyDecoder(codingPath: codingPath, userInfo: userInfo)
        nested.value = dictionary[key.stringValue] as Any
        nested.super = decoder
        return try KeyedDecodingContainer(AnyDecoder.KeyedContainer<NestedKey>(decoder: nested))
    }

    public func superDecoder() throws -> Decoder { decoder.super ?? decoder }
    public func superDecoder(forKey key: Key) throws -> Decoder { decoder.super ?? decoder }
}

extension AnyDecoder.UnkeyedContainer {

    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        defer { currentIndex += 1 }
        decoder.codingPath.append(AnyCodingKey(currentIndex))
        defer { decoder.codingPath.removeLast() }
        let nested = AnyDecoder(codingPath: codingPath, userInfo: userInfo)
        nested.value = array[currentIndex]
        nested.super = decoder
        return try AnyDecoder.UnkeyedContainer(decoder: nested)
    }

    public mutating func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        defer { currentIndex += 1 }
        decoder.codingPath.append(AnyCodingKey(currentIndex))
        defer { decoder.codingPath.removeLast() }
        let nested = AnyDecoder(codingPath: codingPath, userInfo: userInfo)
        nested.value = array[currentIndex]
        nested.super = decoder
        return try KeyedDecodingContainer(AnyDecoder.KeyedContainer<NestedKey>(decoder: nested))
    }

    public mutating func superDecoder() throws -> Decoder { decoder.super ?? decoder }
}

extension Sequence<CodingKey> {
    public var string: String { map(\.stringValue).joined(separator: ".") }
}

private protocol OptionalDecodableProtocol {
    static func decodeUnwrapped<D: AnyDecoderProtocol>(from decoder: D) -> Self
}

extension Optional: OptionalDecodableProtocol where Wrapped: Decodable {
    static func decodeUnwrapped(from decoder: some AnyDecoderProtocol) -> Optional {
        try? decoder.decode(Wrapped.self, from: decoder.value)
    }
}

private protocol AnyRawRepresentable {
    static func value(from any: Any, using decoder: AnyDecoderProtocol) -> Any?
}

private enum Wrapper<T> {}

extension Wrapper: AnyRawRepresentable where T: RawRepresentable, T.RawValue: Decodable {
    static func value(from any: Any, using decoder: AnyDecoderProtocol) -> Any? {
        guard let value = any as? T.RawValue ?? (try? decoder.decode(T.RawValue.self, from: any)) else {
            return nil
        }
        return T(rawValue: value)
    }
}
