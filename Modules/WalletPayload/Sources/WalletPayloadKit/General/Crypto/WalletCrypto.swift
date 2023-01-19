// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoKit
import DIKit
import Foundation
import ToolKit

/// Hashes a value over n iterations using SHA256
/// - Parameters:
///   - iterations: An `Int` for the number of iterations for the hashed value
///   - value: A `String` of the initial value
/// - Returns: A `String` value hashed n times
func hashNTimes(iterations: Int, value: String) -> String {
    assert(iterations > 0)
    let data = Data(value.utf8)
    return (1...iterations)
        .reduce(into: data) { result, _ in
            result = Data(SHA256.hash(data: result))
        }
        .toHexString
}

/// Decrypts a value using a second password
/// - Parameters:
///   - secPassword: A `String` value representing the user's second password
///   - sharedKey: A `String` value of the sharedKey from `Wallet`
///   - pbkdf2Iterations: An `Int` value of the number of iterations for the decryption
///   - value: A `String` encrypted value to be decrypted
/// - Returns: A `Result<String, PayloadCryptoError>` with a decrypted value or a failure
func decryptValue(
    using secPassword: String,
    sharedKey: String,
    pbkdf2Iterations: Int,
    value: String,
    decryptor: PayloadCryptoAPI = PayloadCrypto(cryptor: AESCryptor())
) -> Result<String, PayloadCryptoError> {
    let isValueBase64Encoded = Data(base64Encoded: value) != nil
    let base64EncodedValue = isValueBase64Encoded ? value : Data(value.utf8).base64EncodedString()
    return decryptor.decrypt(
        data: base64EncodedValue,
        with: sharedKey + secPassword,
        pbkdf2Iterations: UInt32(pbkdf2Iterations)
    )
}

func encrypt(
    value: Data,
    password: String,
    pbkdf2Iterations: Int,
    encryptor: PayloadCryptoAPI = PayloadCrypto(cryptor: AESCryptor())
) -> Result<String, PayloadCryptoError> {
    guard let value = String(data: value, encoding: .utf8) else {
        return .failure(.decodingFailed)
    }
    return encryptor.encrypt(data: value, with: password, pbkdf2Iterations: UInt32(pbkdf2Iterations))
}

/// Applies SHA256 hashing
/// - Parameter data: The `Data` to be hashed
/// - Returns: A hashed `Data`
func checksum(data: Data) -> Data {
    Data(SHA256.hash(data: data))
}

/// Applies SHA256 hashing and returns a hexademical string
/// - Parameter value: The `String` to be hashed
/// - Returns: A hashed `String`
func checksumHex(data: Data) -> String {
    checksum(data: data).toHexString
}

/// Applies SHA256 to given value and returns the first 5 characters.
/// - Parameter value: A `String` for the hashing the be applied
/// - Returns: A hashed `String`
public func hashPassword(_ value: String) -> String {
    let data = Data(value.utf8)
    let hashedString = checksumHex(data: data)
    let endIndex = hashedString.index(hashedString.startIndex, offsetBy: min(value.count, 5))
    return String(hashedString[..<endIndex])
}
