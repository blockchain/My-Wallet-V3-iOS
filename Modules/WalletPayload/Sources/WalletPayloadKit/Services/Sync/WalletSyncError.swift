// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation
import Localization
import ToolKit

public enum WalletSyncError: LocalizedError, Equatable {
    case unknown
    case encodingError(WalletEncodingError)
    case verificationFailure(EncryptAndVerifyError)
    case networkFailure(NetworkError)
    case syncPubKeysFailure(SyncPubKeysAddressesProviderError)
    case mnemonicFailure

    public var errorDescription: String? {
        switch self {
        case .unknown:
            LocalizationConstants.WalletPayloadKit.Error.unknown
        case .encodingError(let walletEncodingError):
            walletEncodingError.errorDescription
        case .verificationFailure(let encryptAndVerifyError):
            encryptAndVerifyError.errorDescription
        case .networkFailure(let networkError):
            networkError.description
        case .syncPubKeysFailure(let error):
            error.localizedDescription
        case .mnemonicFailure:
            WalletError.initialization(.missingSeedHex).localizedDescription
        }
    }
}
