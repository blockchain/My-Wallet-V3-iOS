// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

enum WalletConnectServiceError: LocalizedError {
    case missingSession
    case unknownNetwork
    case invalidTxCompletion
    case invalidTxTarget
    case unsupportedMethod
    case unknown

    var errorDescription: String? {
        switch self {
        case .missingSession:
            return LocalizationConstants.WalletConnect.ServiceError.missingSession
        case .unknownNetwork:
            return LocalizationConstants.WalletConnect.ServiceError.unknownNetwork
        case .invalidTxCompletion:
            return nil
        case .invalidTxTarget:
            return LocalizationConstants.WalletConnect.ServiceError.invalidTxTarget
        case .unsupportedMethod:
            return LocalizationConstants.WalletConnect.ServiceError.unsupportedMethod
        case .unknown:
            return LocalizationConstants.WalletConnect.ServiceError.unknown
        }
    }
}
