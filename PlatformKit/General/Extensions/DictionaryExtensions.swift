//
//  DictionaryExtensions.swift
//  PlatformKit
//
//  Created by Jack on 05/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Dictionary {
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> Dictionary<Key, T> {
        return try self.reduce(into: [Key: T](), { (result, x) in
            if let value = try transform(x.value) {
                result[x.key] = value
            }
        })
    }
}

extension Dictionary where Key == String, Value == [String: Any] {
    /// Cast the `[String: [String: Any]]` objects in this Dictionary to instances of `Type`
    ///
    /// - Parameter type: the type
    /// - Returns: the casted array
    public func decodeJSONObjects<T: Codable>(type: T.Type) -> Dictionary<String, T> {
        let jsonDecoder = JSONDecoder()
        return compactMapValues { value -> T? in
            guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
                Logger.shared.warning("Failed to serialize dictionary.")
                return nil
            }
            
            do {
                return try jsonDecoder.decode(type.self, from: data)
            } catch {
                Logger.shared.error("Failed to decode \(error)")
            }
            
            return nil
        }
    }
    
    public func decodeJSONValues<T: Codable>(type: T.Type) -> [T] {
        return decodeJSONObjects(type: type)
            .compactMap { (tuple) -> T? in
                let (_, value) = tuple
                return value
            }
    }
}

