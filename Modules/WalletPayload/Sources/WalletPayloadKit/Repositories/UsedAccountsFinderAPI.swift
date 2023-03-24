// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public typealias XpubRetriever = (_ type: WalletPayloadKit.DerivationType, _ index: UInt) -> String

public enum UsedAccountsFinderError: LocalizedError, Equatable {
    case networkError(NetworkError)

    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return error.description
        }
    }
}

/// When the master seed is imported from an external source we should start to discover accounts
/// with existing transactions.
public protocol UsedAccountsFinderAPI {

    /// Finds the number of accounts that are used based on their transaction status
    /// - Returns: `AnyPublisher<Int, Never>`
    func findUsedAccounts(
        batch: UInt,
        xpubRetriever: @escaping XpubRetriever
    ) -> AnyPublisher<Int, UsedAccountsFinderError>
}
