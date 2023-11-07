// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Localization
import ToolKit

public enum EncryptAndVerifyError: LocalizedError, Equatable {
    case expectedEncodedPayload
    case genericFailure
    case encryptionFailure
    case encodingError(WalletEncodingError)

    public var errorDescription: String? {
        switch self {
        case .expectedEncodedPayload:
            LocalizationConstants.WalletPayloadKit.EncryptAndVerifyErrorConstants.expectedEncryptedPayload
        case .genericFailure:
            LocalizationConstants.WalletPayloadKit.Error.unknown
        case .encryptionFailure:
            LocalizationConstants.WalletPayloadKit.EncryptAndVerifyErrorConstants.encryptionFailure
        case .encodingError(let walletEncodingError):
            walletEncodingError.errorDescription
        }
    }
}

/// Encrypts and verify the given wrapper with the provided password
/// We first encrypt the wrapper and we immediately decrypt it
/// we then compare the pre-encrypted value with the decrypted one.
func encryptAndVerifyWrapper(
    walletEncoder: WalletEncodingAPI,
    encryptor: PayloadCryptoAPI,
    logger: NativeWalletLoggerAPI,
    password: String,
    wrapper: Wrapper
) -> AnyPublisher<EncodedWalletPayload, EncryptAndVerifyError> {
    walletEncoder.transform(wrapper: wrapper)
        .logMessageOnOutput(logger: logger, message: { payload in
            let jsonPayload = String(data: payload.payloadContext.value, encoding: .utf8)
            return "[Sync] Wallet json to be synced:\n \(String(describing: jsonPayload))"
        })
        .mapError(EncryptAndVerifyError.encodingError)
        .flatMap { encodedPayload -> AnyPublisher<EncodedWalletPayload, EncryptAndVerifyError> in
            guard case .encoded(let payload) = encodedPayload.payloadContext else {
                return .failure(.encodingError(.expectedEncryptedPayload))
            }
            guard let payloadValue = String(data: payload, encoding: .utf8) else {
                return .failure(.genericFailure)
            }
            return encryptor.encrypt(
                data: payloadValue,
                with: password,
                pbkdf2Iterations: wrapper.pbkdf2Iterations
            )
            .publisher
            .mapError { _ in EncryptAndVerifyError.encryptionFailure }
            .eraseToAnyPublisher()
            .flatMap { encryptedPayload -> AnyPublisher<String, EncryptAndVerifyError> in
                encryptor.decrypt(
                    data: encryptedPayload,
                    with: password,
                    pbkdf2Iterations: wrapper.pbkdf2Iterations
                )
                .publisher
                .mapError { _ in EncryptAndVerifyError.encryptionFailure }
                .crashOnError()
                .flatMap { decryptedPayload -> AnyPublisher<String, EncryptAndVerifyError> in
                    guard decryptedPayload == payloadValue else {
                        fatalError(
                            "wallet verification error: mismatch between encrypted and decrypted payload"
                        )
                    }
                    return .just(encryptedPayload)
                }
                .eraseToAnyPublisher()
            }
            .map { encryptedPayload in
                EncodedWalletPayload(
                    payloadContext: .encrypted(Data(encryptedPayload.utf8)),
                    wrapper: wrapper
                )
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

extension Publisher {

    func crashOnError() -> AnyPublisher<Output, Never> {
        self.catch { error -> AnyPublisher<Output, Never> in
            fatalError(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}
