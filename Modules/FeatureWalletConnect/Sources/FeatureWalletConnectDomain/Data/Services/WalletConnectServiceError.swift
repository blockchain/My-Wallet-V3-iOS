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
            LocalizationConstants.WalletConnect.ServiceError.missingSession
        case .unknownNetwork:
            LocalizationConstants.WalletConnect.ServiceError.unknownNetwork
        case .invalidTxCompletion:
            nil
        case .invalidTxTarget:
            LocalizationConstants.WalletConnect.ServiceError.invalidTxTarget
        case .unsupportedMethod:
            LocalizationConstants.WalletConnect.ServiceError.unsupportedMethod
        case .unknown:
            LocalizationConstants.WalletConnect.ServiceError.unknown
        }
    }
}
