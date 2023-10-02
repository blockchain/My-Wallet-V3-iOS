// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct FailableDecodable<T: Decodable>: Decodable {

    public let value: T?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.value = try container.decode(T.self)
        } catch {
            self.value = nil
            print("FailableDecodable: \(error)")
        }
    }
}

extension Decodable {

    public init(json any: Any, using decoder: JSONDecoder = .init()) throws {
        let data = try JSONSerialization.data(withJSONObject: any, options: .fragmentsAllowed)
        self = try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {

    public func data(using encoder: JSONEncoder = .init()) throws -> Data {
        try encoder.encode(self)
    }

    public func json(using encoder: JSONEncoder = .init()) throws -> Any {
        try data(using: encoder).json()
    }
}

extension Data {

    public func json() throws -> Any {
        try JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
}

extension [String: Any] {

    public func json(options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: options)
    }
}

extension [Any] {

    public func json(options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: options)
    }
}

extension Data? {

    public func json() throws -> Any {
        switch self {
        case nil:
            return NSNull()
        case let wrapped?:
            return try wrapped.json()
        }
    }
}

extension DecodingError {
    /// Provides a formatted description of a `DecodingError`, please note the result is not localized intentionally
    public var formattedDescription: String {
        switch self {
        case .dataCorrupted(let context):
            let underlyingError = (context.underlyingError as? NSError)?.debugDescription ?? ""
            return "Data corrupted. \(context.debugDescription) \(underlyingError)"
        case .keyNotFound(let codingKey, let context):
            return "Key not found. Expected -> \(codingKey.stringValue) <- at: \(formattedPath(for: context))"
        case .typeMismatch(_, let context):
            return "Type mismatch. \(context.debugDescription) at: \(formattedPath(for: context))"
        case .valueNotFound(_, let context):
            return "Value not found. -> \(formattedPath(for: context)) <- \(context.debugDescription)"
        @unknown default:
            return "Unknown error while decoding"
        }
    }

    private func formattedPath(for context: DecodingError.Context) -> String {
        context.codingPath.map(\.stringValue).joined(separator: ".")
    }
}

extension EncodingError {
    /// Provides a formatted description of a `EncodingError`, please note the result is not localized intentionally
    public var formattedDescription: String {
        switch self {
        case .invalidValue(_, let context):
            return "Invalid value while encoding found -> \(formattedPath(for: context))"
        @unknown default:
            return "Unknown error while encoding"
        }
    }

    private func formattedPath(for context: EncodingError.Context) -> String {
        context.codingPath.map(\.stringValue).joined(separator: ".")
    }
}
