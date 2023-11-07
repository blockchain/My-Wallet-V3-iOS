// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataInitialisationAndRecoveryError: LocalizedError, Equatable {
    case failedToDeriveSecondPasswordNode(DeriveSecondPasswordNodeError)
    case failedToDeriveRemoteMetadataNode(MetadataDerivationError)
    case failedToDeriveMasterKey(MasterKeyError)
    case invalidMnemonic(MnemonicError)
    case failedToFetchCredentials(MetadataFetchError)

    public var errorDescription: String? {
        switch self {
        case .failedToDeriveSecondPasswordNode(let deriveSecondPasswordNodeError):
            deriveSecondPasswordNodeError.errorDescription
        case .failedToDeriveRemoteMetadataNode(let metadataDerivationError):
            metadataDerivationError.errorDescription
        case .failedToDeriveMasterKey(let masterKeyError):
            masterKeyError.errorDescription
        case .invalidMnemonic(let mnemonicError):
            mnemonicError.errorDescription
        case .failedToFetchCredentials(let metadataFetchError):
            metadataFetchError.errorDescription
        }
    }
}
