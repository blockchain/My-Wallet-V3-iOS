// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public struct AccountCredentials: Equatable {
    public let nabuUserId: String
    public let nabuLifetimeToken: String
    public let exchangeUserId: String?
    public let exchangeLifetimeToken: String?

    public init(
        nabuUserId: String,
        nabuLifetimeToken: String,
        exchangeUserId: String?,
        exchangeLifetimeToken: String?
    ) {
        self.nabuUserId = nabuUserId
        self.nabuLifetimeToken = nabuLifetimeToken
        self.exchangeUserId = exchangeUserId
        self.exchangeLifetimeToken = exchangeLifetimeToken
    }

    static func from(entry: AccountCredentialsEntryPayload) -> Self {
        AccountCredentials(
            nabuUserId: entry.nabuUserId,
            nabuLifetimeToken: entry.nabuLifetimeToken,
            exchangeUserId: entry.exchangeUserId,
            exchangeLifetimeToken: entry.exchangeLifetimeToken
        )
    }

    func toEntry() -> AccountCredentialsEntryPayload {
        AccountCredentialsEntryPayload(
            nabuUserId: nabuUserId,
            nabuLifetimeToken: nabuLifetimeToken,
            exchangeUserId: exchangeUserId,
            exchangeLifetimeToken: exchangeLifetimeToken
        )
    }
}

public protocol AccountCredentialsFetcherAPI {
    /// Fetches the `UserCredentials` from Wallet metadata
    func fetchAccountCredentials(forceFetch: Bool) -> AnyPublisher<AccountCredentials, WalletAssetFetchError>

    /// Stores the passed UserCredentials to metadata
    /// - Parameter credentials: A `UserCredentials` value
    func store(credentials: AccountCredentials) -> AnyPublisher<EmptyValue, WalletAssetSaveError>
}

final class AccountCredentialsFetcher: AccountCredentialsFetcherAPI {
    private struct Key: Hashable {}

    private let metadataEntryService: WalletMetadataEntryServiceAPI
    private let userCredentialsFetcher: UserCredentialsFetcherAPI

    private let cachedValue: CachedValueNew<Key, AccountCredentials, WalletAssetFetchError>

    init(
        metadataEntryService: WalletMetadataEntryServiceAPI,
        userCredentialsFetcher: UserCredentialsFetcherAPI
    ) {
        self.metadataEntryService = metadataEntryService
        self.userCredentialsFetcher = userCredentialsFetcher

        let cache = InMemoryCache<Key, AccountCredentials>(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [userCredentialsFetcher, metadataEntryService] _ in
                doFetchAccountCredentials(
                    forceFetch: true,
                    metadataEntryService: metadataEntryService,
                    userCredentialsFetcher: userCredentialsFetcher
                )
            }
        )
    }

    func fetchAccountCredentials(forceFetch: Bool) -> AnyPublisher<AccountCredentials, WalletAssetFetchError> {
        cachedValue.get(
            key: Key(),
            forceFetch: forceFetch
        )
    }

    func store(credentials: AccountCredentials) -> AnyPublisher<EmptyValue, WalletAssetSaveError> {
        doSave(
            credentials: credentials,
            metadataEntryService: metadataEntryService,
            userCredentialsFetcher: userCredentialsFetcher
        )
    }
}

private func doFetchAccountCredentials(
    forceFetch: Bool,
    metadataEntryService: WalletMetadataEntryServiceAPI,
    userCredentialsFetcher: UserCredentialsFetcherAPI
) -> AnyPublisher<AccountCredentials, WalletAssetFetchError> {
    metadataEntryService.fetchEntry(type: AccountCredentialsEntryPayload.self)
        .map(AccountCredentials.from(entry:))
        .zip(userCredentialsFetcher.fetchUserCredentials(forceFetch: forceFetch))
        .map { accountCredentials, userCredentials in
            guard !accountCredentials.nabuUserId.isEmpty,
                  !accountCredentials.nabuLifetimeToken.isEmpty
            else {
                return AccountCredentials(
                    nabuUserId: userCredentials.userId,
                    nabuLifetimeToken: userCredentials.lifetimeToken,
                    exchangeUserId: nil,
                    exchangeLifetimeToken: nil
                )
            }
            return accountCredentials
        }
        .eraseToAnyPublisher()
}

private func doSave(
    credentials: AccountCredentials,
    metadataEntryService: WalletMetadataEntryServiceAPI,
    userCredentialsFetcher: UserCredentialsFetcherAPI
) -> AnyPublisher<EmptyValue, WalletAssetSaveError> {
    // we're also saving to the old entry (10) as well as the new one
    let userCredentials = UserCredentials(
        userId: credentials.nabuUserId,
        lifetimeToken: credentials.nabuLifetimeToken
    )
    return metadataEntryService.save(node: credentials.toEntry())
        .zip(userCredentialsFetcher.store(credentials: userCredentials))
        .map { _ in .noValue }
        .eraseToAnyPublisher()
}
