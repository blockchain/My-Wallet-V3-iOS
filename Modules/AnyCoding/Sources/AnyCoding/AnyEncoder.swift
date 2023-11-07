// https://github.com/ollieatkinson/Eumorphic/blob/anything/Sources/Anything/AnyEncoder.swift

import Combine
import Foundation
import SwiftExtensions

public protocol AnyEncoderProtocol: AnyObject, Encoder {

    var value: Any? { get set }
    var codingPath: [CodingKey] { get set }

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any])

    func convert<T>(_ value: T) throws -> Any?
    func encode<T>(_ this: T) throws -> Any? where T: Encodable
}

open class AnyEncoder: AnyEncoderProtocol, TopLevelEncoder {

    public var codingPath: [CodingKey] = []
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    var `super`: AnyEncoder?

    public required init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    private var root = (
        container: EncodingContainer.singleValue, ()
    )

    private var _value: Any?
    public var value: Any? {
        get { get() }
        set { set(newValue) }
    }

    public func encode(_ this: some Encodable) throws -> Any? {
        root.container = this.containerType
        if let o = this as? OptionalEncodableProtocol {
            return o.encodeUnwrapped(to: self)
        }
        try this.encode(to: self)
        return _value
    }

    open func convert(_ value: some Any) throws -> Any? {
        switch value {
        case let url as URL:
            url.absoluteString
        case let date as Date:
            date.timeIntervalSince1970
        default:
            nil
        }
    }
}

extension AnyEncoder {

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        KeyedEncodingContainer(KeyedContainer<Key>(encoder: self))
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        UnkeyedContainer(encoder: self)
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        SingleValueContainer(encoder: self)
    }
}

extension AnyEncoder {

    public struct KeyedContainer<Key> where Key: CodingKey {

        private let encoder: AnyEncoder

        public var codingPath: [CodingKey] { encoder.codingPath }
        public var userInfo: [CodingUserInfoKey: Any] { encoder.userInfo }

        public init(encoder: AnyEncoder) {
            self.encoder = encoder
        }
    }
}

extension AnyEncoder.KeyedContainer: KeyedEncodingContainerProtocol {

    public func encodeNil(forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        encoder.value = NSNull()
    }

    public mutating func encode(_ value: some Encodable, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        encoder.value = try encoder.box(value)
    }
}

extension AnyEncoder {

    public struct SingleValueContainer {

        private let encoder: AnyEncoder

        public var codingPath: [CodingKey] { encoder.codingPath }
        public var userInfo: [CodingUserInfoKey: Any] { encoder.userInfo }

        public init(encoder: AnyEncoder) {
            self.encoder = encoder
        }
    }
}

extension AnyEncoder.SingleValueContainer: SingleValueEncodingContainer {

    public func encodeNil() throws {
        encoder.value = NSNull()
    }

    public func encode(_ value: some Encodable) throws {
        switch value.containerType {
        case .singleValue:
            encoder.value = try encoder.convert(value) ?? value
        case .keyed, .unkeyed:
            encoder.value = try encoder.box(value)
        }
    }
}

extension AnyEncoder {

    public struct UnkeyedContainer {

        private let encoder: AnyEncoder

        public var codingPath: [CodingKey] { encoder.codingPath }
        public var userInfo: [CodingUserInfoKey: Any] { encoder.userInfo }

        public var count: Int = 0

        public init(encoder: AnyEncoder) {
            self.encoder = encoder
        }
    }
}

extension AnyEncoder.UnkeyedContainer: UnkeyedEncodingContainer {

    public mutating func encodeNil() throws {
        defer { count += 1 }
        encoder.codingPath.append(AnyCodingKey(count))
        defer { encoder.codingPath.removeLast() }
        encoder.value = NSNull()
    }

    public mutating func encode(_ value: some Encodable) throws {
        defer { count += 1 }
        encoder.codingPath.append(AnyCodingKey(count))
        defer { encoder.codingPath.removeLast() }
        encoder.value = try encoder.box(value)
    }
}

extension AnyEncoder {

    func get() -> Any {
        switch `super`?._value ?? _value {
        case let array as [Any]:
            array[codingPath] as Any
        case let dictionary as [String: Any]:
            dictionary[codingPath] as Any
        case let fragment:
            fragment as Any
        }
    }

    func set(_ newValue: Any?) {
        if let `super` {
            let old = `super`.codingPath
            `super`.codingPath = codingPath
            defer { `super`.codingPath = old }
            `super`.set(newValue)
        } else {
            switch root.container {
            case .unkeyed:
                var array = (_value as? [Any]) ?? []
                array[codingPath] = newValue
                _value = array
            case .keyed:
                var dictionary = (_value as? [String: Any]) ?? [:]
                dictionary[codingPath] = newValue
                _value = dictionary
            case .singleValue:
                _value = newValue
            }
        }
    }

    private func box(_ it: Encodable) throws -> Any {
        if let o = try convert(it) { return o }
        try it.encode(to: self)
        return get()
    }
}

extension AnyEncoder.KeyedContainer {

    public mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        encoder.codingPath.append(AnyCodingKey(key.stringValue))
        defer { encoder.codingPath.removeLast() }
        let nested = AnyEncoder(codingPath: codingPath, userInfo: userInfo)
        nested.super = encoder
        return KeyedEncodingContainer(AnyEncoder.KeyedContainer<NestedKey>(encoder: nested))
    }

    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        encoder.codingPath.append(AnyCodingKey(key.stringValue))
        defer { encoder.codingPath.removeLast() }
        let nested = AnyEncoder(codingPath: codingPath, userInfo: userInfo)
        nested.super = encoder
        return AnyEncoder.UnkeyedContainer(encoder: encoder)
    }

    public func superEncoder() -> Encoder { encoder.super ?? encoder }
    public func superEncoder(forKey key: Key) -> Encoder { encoder.super ?? encoder }
}

extension AnyEncoder.UnkeyedContainer {

    public mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        defer { count += 1 }
        encoder.codingPath.append(AnyCodingKey(count))
        defer { encoder.codingPath.removeLast() }
        let nested = AnyEncoder(codingPath: codingPath, userInfo: userInfo)
        nested.super = encoder
        return KeyedEncodingContainer(AnyEncoder.KeyedContainer<NestedKey>(encoder: nested))
    }

    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        defer { count += 1 }
        encoder.codingPath.append(AnyCodingKey(count))
        defer { encoder.codingPath.removeLast() }
        let nested = AnyEncoder(codingPath: codingPath, userInfo: userInfo)
        nested.super = encoder
        return AnyEncoder.UnkeyedContainer(encoder: nested)
    }

    public func superEncoder() -> Encoder { encoder.super ?? encoder }
}

private protocol OptionalEncodableProtocol: Encodable {
    func encodeUnwrapped(to encoder: AnyEncoder) -> Any
}

extension Optional: OptionalEncodableProtocol where Wrapped: Encodable {

    func encodeUnwrapped(to encoder: AnyEncoder) -> Any {
        switch self {
        case .some(let value):
            (try? encoder.encode(value)) as Any
        case .none:
            NSNull()
        }
    }
}
