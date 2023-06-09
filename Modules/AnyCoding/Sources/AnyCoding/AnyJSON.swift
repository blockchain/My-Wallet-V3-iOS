import Foundation
import SwiftExtensions

@dynamicMemberLookup
public struct AnyJSON: Codable, Hashable, Equatable, CustomStringConvertible {

    public typealias Error = String.Error

    public private(set) var wrapped: Any
    public var any: Any { wrapped }

    public var value: Any? {
        get { wrapped }
        set { wrapped = newValue.flattened as Any }
    }

    internal var __unwrapped: Any {
        (wrapped as? AnyJSON)?.__unwrapped ?? wrapped
    }

    public init() {
        self = nil
    }

    public init(_ any: Any?) {
        switch any {
        case let thing as AnyJSON:
            self = thing
        default:
            self.wrapped = any as Any
        }
    }

    private var __subscript: Any? {
        get { wrapped }
        set { wrapped = newValue ?? NSNull() }
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Any?, T>) -> T? {
        __subscript[keyPath: keyPath]
    }

    public subscript(dynamicMember string: String) -> AnyJSON {
        get { AnyJSON(self[AnyCodingKey(string)]) }
        set { self[AnyCodingKey(string)] = newValue.__unwrapped }
    }

    public subscript(first: AnyCodingKey, rest: AnyCodingKey...) -> Any? {
        get { __subscript[[first] + rest] }
        set { __subscript[[first] + rest] = newValue }
    }

    public subscript(path: some Collection<CodingKey>) -> Any? {
        get { __subscript[path] }
        set { __subscript[path] = newValue }
    }

    public func hash(into hasher: inout Hasher) {
        (wrapped as? AnyHashable).hash(into: &hasher)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        isEqual(lhs.__unwrapped, rhs.__unwrapped)
    }

    public init(from decoder: Decoder) throws {
        switch decoder {
        case let decoder as EmptyDecoder:
            self = nil
        case let decoder as DecodingContainerDecoder:
            _ = try decoder.unkeyedContainer()
            self = nil
        case let decoder as AnyDecoderProtocol:
            func ƒ(_ any: Any) throws -> Any {
                let json = try decoder.convert(any, to: AnyJSON.self) as? AnyJSON
                switch json?.value ?? any {
                case let array as [Any]:
                    return try array.enumerated().map { o -> Any in
                        decoder.codingPath.append(AnyCodingKey(o.offset))
                        defer { decoder.codingPath.removeLast() }
                        return try ƒ(o.element)
                    }
                case let dictionary as [String: Any]:
                    return try Dictionary(uniqueKeysWithValues: dictionary.map { o -> (String, Any) in
                        decoder.codingPath.append(AnyCodingKey(o.key))
                        defer { decoder.codingPath.removeLast() }
                        return try (o.key, ƒ(o.value))
                    })
                case let fragment:
                    return fragment
                }
            }
            self = try .init(ƒ(decoder.value))
        default:
            throw Error(
                """
                AnyJSON can only be decoded with
                AnyDecoderProtocol; got: \(decoder)
                """
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch encoder {
        case let encoder as ContainerTypeEncoder:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        case let encoder as AnyEncoderProtocol:
            func ƒ(_ any: Any) throws -> Any {
                if let o = try encoder.convert(any) { return o }
                switch any {
                case let array as [Any]:
                    return try array.map(ƒ)
                case let dictionary as [String: Any]:
                    return try dictionary.mapValues(ƒ)
                case let fragment:
                    return fragment
                }
            }
            encoder.value = try ƒ(wrapped)
        default:
            throw Error(
                """
                AnyJSON can currently only be encoded with a
                AnyEncoderProtocol; got: \(encoder)
                """
            )
        }
    }

    public func `as`<T>(_ type: T.Type) throws -> T {
        try (wrapped as? T).or(throw: Error("Cannot cast \(Swift.type(of: wrapped)) to \(T.self)"))
    }

    public var description: String {
        any as? String ?? (any as? CustomStringConvertible)?.description ?? String(describing: any)
    }

    public func dictionary() -> [String: Any]? {
        wrapped as? [String: Any]
    }

    public func array() -> [Any]? {
        wrapped as? [Any]
    }

    public func pretty(using decoder: AnyDecoderProtocol = AnyDecoder()) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try String(decoding: encoder.encode(decoder.decode(JSONValue.self, from: self)), as: UTF8.self)
    }

    public static let empty: AnyJSON = nil
}

extension AnyJSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(NSNull())
    }
}

extension AnyJSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

extension AnyJSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init([String: Any].init(elements, uniquingKeysWith: { $1 }))
    }
}

extension AnyJSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension AnyJSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension AnyJSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension AnyJSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension AnyJSON: ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(stringInterpolation.description)
    }
}

extension AnyJSON {

    @inlinable public var isNil: Bool { value == nil }
    @inlinable public var isNotNil: Bool { !isNil }

    @inlinable public var isEmpty: Bool { (value as? any Collection)?.isEmpty ?? false }
    @inlinable public var isNotEmpty: Bool { !isEmpty }

    @_disfavoredOverload
    @inlinable public func decode<T: Decodable>(_: T.Type = T.self, using decoder: AnyDecoderProtocol) throws -> T {
        try decoder.decode(T.self, from: wrapped)
    }
}

public protocol AnyJSONConvertible {
    func toJSON() -> AnyJSON
}

extension AnyJSON {

    public func data(using encoder: AnyEncoderProtocol = AnyEncoder()) throws -> Data {
        let value = try encoder.encode(self) ?? NSNull()
        guard JSONSerialization.isValidJSONObject([value]) else {
            throw AnyJSON.Error("is not a valid JSON")
        }
        return try JSONSerialization.data(withJSONObject: value)
    }
}

extension AnyJSON {

    public var isNotError: Bool { return !isError }
    public var isError: Bool {
        if value is String { return false }
        return value is Swift.Error
    }

    public func throwIfError() throws -> AnyJSON {
        if !(any is String), let error = any as? Swift.Error { throw error }
        return self
    }
}

extension Any? {

    public func throwIfError() throws -> Any? {
        if !(self is String), let error = self as? Swift.Error { throw error }
        return self
    }
}

extension AnyJSON.Error: EmptyInit {
    public init() { self = "".error() }
}

enum JSONValue: Codable, Equatable {

    case null
    case boolean(Bool)
    case string(String)
    case number(NSNumber)
    case array([JSONValue])
    case object([String: JSONValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let int = try? container.decode(Int.self) {
            self = .number(NSNumber(value: int))
        } else if let double = try? container.decode(Double.self) {
            self = .number(NSNumber(value: double))
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            let value = (decoder as? AnyDecoderProtocol)?.value
            throw DecodingError.typeMismatch(
                JSONValue.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected to decode JSON value but got \(type(of: value)) == \(value ?? "nil")"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .boolean(let bool):
            try container.encode(bool)
        case .number(let number):
            switch CFNumberGetType(number) {
            case .intType, .nsIntegerType, .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type:
                try container.encode(number.intValue)
            default:
                try container.encode(number.doubleValue)
            }
        case .string(let string):
            try container.encode(string)
        case .array(let array):
            try container.encode(array)
        case .object(let object):
            try container.encode(object)
        }
    }
}
