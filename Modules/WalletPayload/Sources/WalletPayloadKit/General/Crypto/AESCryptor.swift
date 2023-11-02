// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoSwift
import Foundation

struct AESOptions {

    enum BlockMode {
        case CBC
        case OFB

        fileprivate func cryptoSwiftBlockMode(iv: [UInt8]) -> CryptoSwift.BlockMode {
            switch self {
            case .CBC:
                CryptoSwift.CBC(iv: iv)
            case .OFB:
                CryptoSwift.OFB(iv: iv)
            }
        }
    }

    enum Padding {
        case iso10126
        case iso78164
        case noPadding

        fileprivate var cryptoSwiftPadding: CryptoSwift.Padding {
            switch self {
            case .iso10126:
                .iso10126
            case .iso78164:
                .iso78164
            case .noPadding:
                .noPadding
            }
        }
    }

    static let `default` = AESOptions(
        blockMode: .CBC,
        padding: .iso10126
    )

    let blockMode: BlockMode
    let padding: Padding
}

enum AESCryptorError: Error {
    case encoding
    case configuration(Error)
    case decryption(Error)
}

protocol AESCryptorAPI {

    func decryptUTF8String(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data,
        options: AESOptions
    ) -> Result<String, AESCryptorError>

    func decrypt(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data,
        options: AESOptions
    ) -> Result<[UInt8], AESCryptorError>

    func encrypt(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data,
        options: AESOptions
    ) -> Result<[UInt8], AESCryptorError>
}

extension AESCryptorAPI {

    func decryptUTF8String(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data
    ) -> Result<String, AESCryptorError> {
        decryptUTF8String(
            data: payloadData,
            with: keyData,
            iv: ivData,
            options: .default
        )
    }

    func decrypt(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data
    ) -> Result<[UInt8], AESCryptorError> {
        decrypt(
            data: payloadData,
            with: keyData,
            iv: ivData,
            options: .default
        )
    }

    func encrypt(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data
    ) -> Result<[UInt8], AESCryptorError> {
        encrypt(
            data: payloadData,
            with: keyData,
            iv: ivData,
            options: .default
        )
    }
}

final class AESCryptor: AESCryptorAPI {

    func decryptUTF8String(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data,
        options: AESOptions = .default
    ) -> Result<String, AESCryptorError> {
        decrypt(data: payloadData, with: keyData, iv: ivData, options: options)
            .map { Data($0) }
            .flatMap { decryptedData -> Result<String, AESCryptorError> in
                guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                    return .failure(AESCryptorError.encoding)
                }
                return .success(decryptedString)
            }
    }

    func decrypt(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data,
        options: AESOptions = .default
    ) -> Result<[UInt8], AESCryptorError> {
        let key: [UInt8] = keyData.bytes
        let iv: [UInt8] = ivData.bytes
        let pad = options.padding.cryptoSwiftPadding
        let blockMode = options.blockMode.cryptoSwiftBlockMode(iv: iv)
        let encrypted: [UInt8] = payloadData.bytes
        return Result { try AES(key: key, blockMode: blockMode, padding: pad) }
            .mapError(AESCryptorError.configuration)
            .flatMap { aes -> Result<[UInt8], AESCryptorError> in
                Result { try aes.decrypt(encrypted) }
                    .mapError(AESCryptorError.decryption)
            }
    }

    func encrypt(
        data payloadData: Data,
        with keyData: Data,
        iv ivData: Data,
        options: AESOptions = .default
    ) -> Result<[UInt8], AESCryptorError> {
        let key: [UInt8] = keyData.bytes
        let iv: [UInt8] = ivData.bytes
        let payload: [UInt8] = payloadData.bytes
        let pad = options.padding.cryptoSwiftPadding
        let blockMode = options.blockMode.cryptoSwiftBlockMode(iv: iv)
        return Result { try AES(key: key, blockMode: blockMode, padding: pad) }
            .mapError(AESCryptorError.configuration)
            .flatMap { aes -> Result<[UInt8], AESCryptorError> in
                Result { try aes.encrypt(payload) }
                    .mapError(AESCryptorError.decryption)
            }
    }
}
