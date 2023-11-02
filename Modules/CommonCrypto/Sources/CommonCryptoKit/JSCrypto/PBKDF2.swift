// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCrypto
import Foundation

public enum PBKDF2Error: Error {
    case keyDerivationError
}

public class PBKDF2 {

    public enum PBKDFAlgorithm {
        case sha1
        case sha512

        fileprivate var commonCryptoAlgorithm: CCPBKDFAlgorithm {
            switch self {
            case .sha1:
                CCPBKDFAlgorithm(kCCPRFHmacAlgSHA1)
            case .sha512:
                CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512)
            }
        }
    }

    public class func deriveSHA1Result(password: String, salt: Data, iterations: UInt32, keySizeBytes: UInt) -> Result<Data, PBKDF2Error> {
        deriveResult(
            password: password,
            salt: salt,
            iterations: iterations,
            keySizeBytes: keySizeBytes,
            algorithm: .sha1
        )
    }

    public class func derive(password: String, salt: Data, iterations: UInt32, keySizeBytes: UInt, algorithm: PBKDFAlgorithm) -> Data? {
        let derivation = PBKDF2.deriveResult(
            password: password,
            salt: salt,
            iterations: iterations,
            keySizeBytes: keySizeBytes,
            algorithm: algorithm
        )
        guard case .success(let key) = derivation else {
            return nil
        }
        return key
    }

    private class func deriveResult(
        password: String,
        salt: Data,
        iterations: UInt32,
        keySizeBytes: UInt,
        algorithm: PBKDFAlgorithm
    ) -> Result<Data, PBKDF2Error> {

        func derive(with password: String, salt: Data, iterations: UInt32, keySizeBytes: UInt, algorithm: CCPBKDFAlgorithm) throws -> Data {
            var derivedKeyData = Data(repeating: 0, count: Int(keySizeBytes))
            let derivedKeyDataCount = derivedKeyData.count
            try derivedKeyData.withUnsafeMutableBytes { (outputBytes: UnsafeMutableRawBufferPointer) in
                let status = CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password,
                    password.utf8.count,
                    salt.bytes,
                    salt.bytes.count,
                    algorithm,
                    iterations,
                    outputBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    derivedKeyDataCount
                )
                guard status == kCCSuccess else {
                    throw PBKDF2Error.keyDerivationError
                }
            }
            return derivedKeyData
        }

        return Result {
            try derive(
                with: password,
                salt: salt,
                iterations: iterations,
                keySizeBytes: keySizeBytes,
                algorithm: algorithm.commonCryptoAlgorithm
            )
        }
        .mapError { _ in PBKDF2Error.keyDerivationError }
    }
}
