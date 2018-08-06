//
//  PinStoreKeyPair.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct PinStoreKeyPairError: Error {
    let localizedDescription: String
}

/// Represents a key-value pair to be used when creating storing a new pin code in the
/// Blockchain remote pin store.
struct PinStoreKeyPair {
    /// String used to loop up `value`
    let key: String

    /// String used to encrypt the user's password
    let value: String
}

extension PinStoreKeyPair {
    static func generateNewKeyPair() throws -> PinStoreKeyPair {
        //32 Random bytes for key
        let data = [__uint8_t](repeating: 0, count: 32)
        let dataPointer = UnsafeMutableRawPointer(mutating: data)
        var error = SecRandomCopyBytes(kSecRandomDefault, data.count, dataPointer)
        guard error == noErr,
            let key = NSData(bytes: dataPointer, length: data.count).hexadecimalString() else {
            throw PinStoreKeyPairError(localizedDescription: "Failed to generate key.")
        }

        //32 random bytes for value
        error = SecRandomCopyBytes(kSecRandomDefault, data.count, dataPointer)
        guard error == noErr,
            let value = NSData(bytes: dataPointer, length: data.count).hexadecimalString() else {
            throw PinStoreKeyPairError(localizedDescription: "Failed to generate value.")
        }

        return PinStoreKeyPair(key: key, value: value)
    }
}
