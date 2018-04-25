//
//  Pin.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct SavePinError: Error {}

/// Model for a user's 4-digit pin
class Pin {
    static let Invalid = Pin(code: 0000)

    private var pinCode: UInt

    /// Checks if this pin is a valid
    var isValid: Bool {
        return self != Pin.Invalid
    }

    /// Checks if this pin is a commonly used pin (read: not very secure)
    var isCommon: Bool {
        let commonPinCodes: [UInt] = [1234, 1111, 1212, 7777, 1004]
        return commonPinCodes.contains(pinCode)
    }

    /// String representation of the underlying pin
    var toString: String {
        return pinCode.pinToString
    }

    init(code: UInt) {
        self.pinCode = code
    }

    // TODO: not the best place for this - move elsewhere
    func save() throws {
        //32 Random bytes for key
        let data = [__uint8_t](repeating: 0, count: 32)
        let dataPointer = UnsafeMutableRawPointer(mutating: data)
        var error = SecRandomCopyBytes(kSecRandomDefault, data.count, dataPointer)
        guard error == noErr else {
            throw SavePinError()
        }

        let key = NSData(bytes: dataPointer, length: data.count).hexadecimalString()

        //32 random bytes for value
        error = SecRandomCopyBytes(kSecRandomDefault, data.count, dataPointer)
        guard error == noErr else {
            throw SavePinError()
        }

        let value = NSData(bytes: dataPointer, length: data.count).hexadecimalString()

        WalletManager.shared.wallet.pinServerPutKey(onPinServerServer: key, value: value, pin: self.toString)
        // TODO handle touch ID
        //    #ifdef ENABLE_TOUCH_ID
        //    if (BlockchainSettings.sharedAppInstance.touchIDEnabled) {
        //        [KeychainItemWrapper setPINInKeychain:pin];
        //    }
        //    #endif
    }
}

extension Pin: Equatable, Hashable {
    static func == (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.pinCode == rhs.pinCode
    }

    var hashValue: Int {
        return Int(pinCode)
    }
}

extension UInt {
    var pinToString: String {
        return String(format: "%lu", CUnsignedLongLong(self))
    }
}
