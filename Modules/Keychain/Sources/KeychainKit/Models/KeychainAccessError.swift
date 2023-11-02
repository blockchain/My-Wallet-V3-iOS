// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A specialized error that provides KeychainAccess errors
public enum KeychainAccessError: LocalizedError, Equatable {
    case writeFailure(KeychainWriterError)
    case readFailure(KeychainReaderError)

    var errorDescription: String {
        switch self {
        case .writeFailure(let error):
            error.errorDescription
        case .readFailure(let error):
            error.errorDescription
        }
    }
}

/// A specialized error that provides KeychainWriter errors
public enum KeychainReaderError: LocalizedError, Equatable {
    case itemNotFound(account: String)
    case readFailed(account: String, status: OSStatus)
    case dataCorrupted(account: String)

    var errorDescription: String {
        switch self {
        case .itemNotFound(let account):
            "[KeychainAccess]: Item not found for: \(account)"
        case .readFailed(let account, let status):
            "[KeychainAccess]: Read failure for \(account), error: \(status)"
        case .dataCorrupted(let account):
            "[KeychainAccess]: Data is corrupted for: \(account)"
        }
    }
}

/// A specialized error that provides KeychainWriter errors
public enum KeychainWriterError: LocalizedError, Equatable {
    case writeFailed(account: String, status: OSStatus)
    case removalFailed(account: String, status: OSStatus)

    var errorDescription: String {
        switch self {
        case .writeFailed(let account, let status):
            "[KeychainAccess]: Could not write item for: \(account), error: \(status)"
        case .removalFailed(let message, let status):
            "[KeychainAccess]: Read failure, message \(message), error: \(status)"
        }
    }
}
