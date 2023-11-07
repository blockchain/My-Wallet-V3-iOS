// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation

public enum SyncPubKeysAddressesProviderError: LocalizedError, Equatable {
    case failureProvidingAddresses(Error)

    public var errorDescription: String? {
        switch self {
        case .failureProvidingAddresses(let error):
            error.localizedDescription
        }
    }

    public static func == (lhs: SyncPubKeysAddressesProviderError, rhs: SyncPubKeysAddressesProviderError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}

public protocol SyncPubKeysAddressesProviderAPI {
    /// Provides all of the wallet active addresses, hd in a formatted string of `{address}|{address}...`
    func provideAddresses(
        mnemonic: String,
        active: [String],
        accounts: [Account]
    ) -> AnyPublisher<String, SyncPubKeysAddressesProviderError>
}
