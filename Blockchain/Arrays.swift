//
//  Arrays.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

extension Array where Element: Equatable {

    /// Returns an array of unique values in the array
    var unique: [Element] {
        var uniques = [Element]()
        for value in self {
            if !uniques.contains(value) {
                uniques.append(value)
            }
        }
        return uniques
    }
    
    func randomItem() -> Iterator.Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
}

extension Array where Element: Any {
    
    /// Cast the `Any` objects in this Array to instances of `Type`
    ///
    /// - Parameter type: the type
    /// - Returns: the casted array
    func castJsonObjects<Type: Codable>(type: Type.Type) -> [Type] {
        return self.compactMap { value -> [String: Any]? in
            guard let jsonObj = value as? [String: Any] else {
                Logger.shared.warning("Failed to cast instance \(value) to dictionary.")
                return nil
            }
            return jsonObj
        }
        .decodeJSONObjects(type: type)
    }
}

extension Array where Element == [String: Any] {
    
    /// Cast the `[String: Any]` objects in this Array to instances of `Type`
    ///
    /// - Parameter type: the type
    /// - Returns: the casted array
    func decodeJSONObjects<T: Codable>(type: T.Type) -> [T] {
        let jsonDecoder = JSONDecoder()
        return self.compactMap { value -> T? in
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
}
