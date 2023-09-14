// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import ToolKit

/// Type alias representing fees data for specific crypto currencies.
public typealias CryptoFeeType = Decodable & TransactionFee

/// Service that provides fees of its associated type.
public protocol CryptoFeeRepositoryAPI {
    associatedtype FeeType: CryptoFeeType

    /// Streams a single CryptoFeeType of the associated type.
    /// This represent current fees to transact a crypto currency.
    /// Never fails, uses default Fee values if network call fails.
    var fees: AnyPublisher<FeeType, Never> { get }
}

public final class CryptoFeeRepository<FeeType: TransactionFee & Decodable>: CryptoFeeRepositoryAPI {

    private struct Key: Hashable {}

    // MARK: - CryptoFeeRepositoryAPI

    public var fees: AnyPublisher<FeeType, Never> {
        cachedValue.get(key: Key())
            .replaceError(with: FeeType.default)
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let client: CryptoFeeClient<FeeType>

    private let cachedValue: CachedValueNew<
        Key,
        FeeType,
        NetworkError
    >

    // MARK: - Init

    init(client: CryptoFeeClient<FeeType>) {
        self.client = client

        let feeCache = InMemoryCache<Key, FeeType>(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(
                refreshInterval: .minutes(1)
            )
        )
        .eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: feeCache,
            fetch: { [client] _ in
                client.fees
            }
        )
    }

    public convenience init() {
        self.init(client: CryptoFeeClient<FeeType>())
    }
}

/// Type-erasure for CryptoFeeRepository.
public struct AnyCryptoFeeRepository<FeeType: CryptoFeeType>: CryptoFeeRepositoryAPI {

    public var fees: AnyPublisher<FeeType, Never> {
        _fees()
    }

    private let _fees: () -> AnyPublisher<FeeType, Never>

    public init<API: CryptoFeeRepositoryAPI>(repository: API) where API.FeeType == FeeType {
        self._fees = { repository.fees }
    }
}
