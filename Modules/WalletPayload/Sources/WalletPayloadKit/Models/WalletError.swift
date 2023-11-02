// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MetadataKit
import ToolKit

public enum WalletError: LocalizedError, Equatable {
    case unknown
    case payloadNotFound
    case initialization(WalletInitializationError)
    case decryption(WalletDecryptionError)
    case encryption(WalletEncodingError)
    case recovery(WalletRecoverError)
    case upgrade(WalletUpgradeError)
    case sync(WalletSyncError)

    public var errorDescription: String? {
        switch self {
        case .payloadNotFound:
            LocalizationConstants.WalletPayloadKit.Error.payloadNotFound
        case .decryption(let error):
            error.errorDescription
        case .initialization(let error):
            error.errorDescription
        case .recovery(let error):
            error.errorDescription
        case .encryption(let error):
            error.errorDescription
        case .upgrade(let error):
            error.errorDescription
        case .sync(let error):
            error.errorDescription
        case .unknown:
            LocalizationConstants.WalletPayloadKit.Error.unknown
        }
    }

    static func map(from error: PayloadCryptoError) -> WalletError {
        switch error {
        case .decodingFailed:
            .decryption(.genericDecodeError)
        case .noPassword:
            .initialization(.invalidSecondPassword)
        case .keyDerivationFailed:
            .initialization(.invalidSecondPassword)
        case .encryptionFailed:
            .initialization(.invalidSecondPassword)
        case .decryptionFailed:
            .initialization(.invalidSecondPassword)
        case .unknown:
            .unknown
        case .noEncryptedWalletData:
            .unknown
        case .unsupportedPayloadVersion:
            .unknown
        case .failedToDecryptV1Payload:
            .unknown
        }
    }
}

public enum WalletInitializationError: LocalizedError, Equatable {
    case unknown
    case missingWallet
    case missingSeedHex
    case metadataInitialization(MetadataInitialisationError)
    case metadataInitializationRecovery(MetadataInitialisationAndRecoveryError)
    case needsSecondPassword
    case invalidSecondPassword

    public var errorDescription: String? {
        switch self {
        case .unknown:
            LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.unknown
        case .missingWallet:
            LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.missingWallet
        case .missingSeedHex:
            LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.missingSeedHex
        case .metadataInitialization(let underlyingError):
            String(
                format: LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.metadataInitialization,
                underlyingError.errorDescription ?? "unknown error occurred"
            )
        case .metadataInitializationRecovery(let underlyingError):
            String(
                format: LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.metadataInitialization,
                underlyingError.errorDescription ?? "unknown error occurred"
            )
        case .needsSecondPassword:
            LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.needsSecondPassword
        case .invalidSecondPassword:
            LocalizationConstants.WalletPayloadKit.WalletInitializationConstants.invalidSecondPassword
        }
    }
}

public enum WalletRecoverError: LocalizedError, Equatable {
    case unknown
    case invalidMnemonic
    case unableToRecoverFromMetadata
    case failedToRecoverWallet

    public var errorDescription: String? {
        switch self {
        case .unknown:
            LocalizationConstants.WalletPayloadKit.WalletRecoverErrorConstants.unknown
        case .invalidMnemonic:
            LocalizationConstants.WalletPayloadKit.WalletRecoverErrorConstants.invalidMnemonic
        case .failedToRecoverWallet:
            LocalizationConstants.WalletPayloadKit.WalletRecoverErrorConstants.failedToRecoverWallet
        case .unableToRecoverFromMetadata:
            // Intentionally nil
            // This error indicates that the wallet from a mnemonic was not previously created by Blockchain.com
            // but another wallet provider, so in this case we will import a wallet and create a new account.
            nil
        }
    }
}

public enum WalletDecryptionError: LocalizedError, Equatable {
    case decryptionError
    case decodeError(DecodingError)
    case genericDecodeError
    case hdWalletCreation

    public var errorDescription: String? {
        switch self {
        case .decryptionError:
            LocalizationConstants.WalletPayloadKit.Error.decryptionFailed
        case .decodeError(let error):
            error.formattedDescription
        case .genericDecodeError:
            LocalizationConstants.WalletPayloadKit.Error.unknown
        case .hdWalletCreation:
            unimplemented("WalletCore failure when creating HDWallet from seedHex")
        }
    }

    public static func == (lhs: WalletDecryptionError, rhs: WalletDecryptionError) -> Bool {
        switch (lhs, rhs) {
        case (.decryptionError, decryptionError):
            true
        case (.decodeError(let lhsError), .decodeError(let rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        case (.genericDecodeError, .genericDecodeError):
            true
        default:
            false
        }
    }
}

public enum WalletEncodingError: LocalizedError, Equatable {
    case encryptionFailure
    case encodingError(EncodingError)
    case genericFailure
    case expectedEncryptedPayload

    public var errorDescription: String? {
        switch self {
        case .encryptionFailure:
            LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.encryptionFailure
        case .encodingError(let encodingError):
            String(
                format: LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.encodingError,
                encodingError.formattedDescription
            )
        case .genericFailure:
            LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.genericFailure
        case .expectedEncryptedPayload:
            LocalizationConstants.WalletPayloadKit.WalletEncodingErrorConstants.expectedEncryptedPayload
        }
    }

    public static func == (lhs: WalletEncodingError, rhs: WalletEncodingError) -> Bool {
        switch (lhs, rhs) {
        case (.encryptionFailure, encryptionFailure):
            true
        case (.genericFailure, genericFailure):
            true
        case (.expectedEncryptedPayload, expectedEncryptedPayload):
            true
        case (.encodingError(let lhsError), .encodingError(let rhsError)):
            lhsError.errorDescription == rhsError.errorDescription
        default:
            false
        }
    }
}
