// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public indirect enum JSONValue: Codable, Hashable, CustomStringConvertible {

    struct Key: CodingKey, Hashable, CustomStringConvertible {
        var intValue: Int? { nil }

        init?(intValue: Int) {
            nil
        }

        var description: String {
            stringValue
        }

        let stringValue: String

        init(_ string: String) { self.stringValue = string }
        init?(stringValue: String) { self.stringValue = stringValue }
    }

    case array([JSONValue])
    case bool(Bool)
    case dictionary([String: JSONValue])
    case null
    case number(Float)
    case string(String)

    public var description: String {
        switch self {
        case .array(let value):
            value.description
        case .bool(let value):
            value.description
        case .dictionary(let value):
            value.description
        case .null:
            "null"
        case .number(let value):
            value.description
        case .string(let value):
            "\"\(value)\""
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .dictionary(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Float.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(
                JSONValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Item is not of a known type."
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .array(let array):
            var container = encoder.unkeyedContainer()
            for value in array {
                try container.encode(value)
            }
        case .bool(let bool):
            var container = encoder.singleValueContainer()
            try container.encode(bool)
        case .dictionary(let dictionary):
            var container = encoder.container(keyedBy: Key.self)
            for (key, value) in dictionary {
                try container.encode(value, forKey: Key(key))
            }
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        case .number(let number):
            var container = encoder.singleValueContainer()
            try container.encode(number)
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        }
    }
}
