// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoSwift
import Foundation

enum EthereumAddressValidator {

    /// Converts address to checksum address.
    /// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
    static func toChecksumAddress(_ address: String) -> String? {
        let address = address.lowercased().withoutHex
        guard let data = address.data(using: .ascii) else { return nil }
        let hash = SHA3(variant: .keccak256).calculate(for: Array(data)).toHexString()
        return zip(address, hash)
            .map { a, h -> String in
                switch (a, h) {
                case (let x, _) where "0123456789".contains(x):
                    return String(a)
                case (_, let x) where "89abcdef".contains(x):
                    return String(a).uppercased()
                default:
                    return String(a).lowercased()
                }
            }
            .joined()
            .withHex
    }

    // Check that the address only contains alphanumerics
    private static func isAlphanumericOnly(_ address: String) -> Bool {
        address.withoutHex.isAlphanumeric
    }

    /// Checks if address size is 20 bytes long.
    private static func hasCorrectLength(_ address: String) -> Bool {
        address.withoutHex.count == 40
            && Data(hex: address.withoutHex).count == 20
    }

    static func validate(address: String) throws {
        // Check that the address only contains alphanumerics
        guard Self.isAlphanumericOnly(address) else {
            throw AddressValidationError.containsInvalidCharacters
        }

        // Check that the normalised address is exactly 20 bytes long
        guard Self.hasCorrectLength(address) else {
            throw AddressValidationError.invalidLength
        }
    }

    static func isValid(address: String) -> Bool {
        isAlphanumericOnly(address) && hasCorrectLength(address)
    }
}
