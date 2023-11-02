// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import ToolKit

public enum NabuUserServiceError: Error, Equatable {
    case failedToFetchUser(NabuNetworkError)
    case failedToSetAddress(NabuNetworkError)
}

extension NabuUserServiceError {

    public var nabu: Nabu.Error {
        switch self {
        case .failedToFetchUser(let error), .failedToSetAddress(let error):
            error
        }
    }
}

public protocol NabuUserServiceAPI: AnyObject {

    var user: AnyPublisher<NabuUser, NabuUserServiceError> { get }

    func fetchUser() -> AnyPublisher<NabuUser, NabuUserServiceError>

    func setInitialResidentialInfo(
        country: String,
        state: String?
    ) -> AnyPublisher<Void, NabuUserServiceError>

    func setTradingCurrency(
        _ currency: FiatCurrency
    ) -> AnyPublisher<Void, Nabu.Error>
}

final class NabuUserService: NabuUserServiceAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    // MARK: - Exposed Properties

    var user: AnyPublisher<NabuUser, NabuUserServiceError> {
        cachedValue
            .get(key: Key())
    }

    // MARK: - Properties

    private let client: KYCClientAPI
    private let siftService: SiftServiceAPI
    private let cachedValue: CachedValueNew<
        Key,
        NabuUser,
        NabuUserServiceError
    >

    // MARK: - Setup

    init(
        client: KYCClientAPI = resolve(),
        siftService: SiftServiceAPI = resolve()
    ) {
        self.client = client
        self.siftService = siftService

        let cache: AnyCache<Key, NabuUser> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client, siftService] _ in
                client
                    .fetchUser()
                    .handleEvents(
                        receiveOutput: { nabuUser in
                            DispatchQueue.main.async {
                                siftService.set(userId: nabuUser.identifier)
                            }
                        }
                    )
                    .mapError(NabuUserServiceError.failedToFetchUser)
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetchUser() -> AnyPublisher<NabuUser, NabuUserServiceError> {
        cachedValue
            .get(key: Key(), forceFetch: true)
    }

    func setInitialResidentialInfo(
        country: String,
        state: String?
    ) -> AnyPublisher<Void, NabuUserServiceError> {
        client
            .setInitialResidentialInfo(country: country, state: state)
            .mapError(NabuUserServiceError.failedToSetAddress)
            .eraseToAnyPublisher()
    }

    func setTradingCurrency(_ currency: FiatCurrency) -> AnyPublisher<Void, Nabu.Error> {
        client.setTradingCurrency(currency.code)
    }
}
