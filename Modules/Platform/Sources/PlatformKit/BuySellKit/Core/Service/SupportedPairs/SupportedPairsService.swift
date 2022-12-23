// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import ToolKit

public protocol SupportedPairsServiceAPI: AnyObject {

    /// Fetches `pairs` using the specified filter
    func fetchPairs(for option: SupportedPairsFilterOption) -> AnyPublisher<SupportedPairs, NabuNetworkError>
}

extension SupportedPairsServiceAPI {

    /// Fetches a list of supported crypto currencies for trading
    public func fetchSupportedTradingCryptoCurrencies() -> AnyPublisher<[CryptoCurrency], NabuNetworkError> {
        fetchPairs(for: .all)
            .map(\.cryptoCurrencies)
            .eraseToAnyPublisher()
    }
}

final class SupportedPairsService: SupportedPairsServiceAPI {

    private typealias ThisCachedValue = CachedValueNew<SupportedPairsFilterOption, SupportedPairs, NabuNetworkError>

    // MARK: - Injected

    private let cachedValue: ThisCachedValue
    private let client: SupportedPairsClientAPI

    // MARK: - Setup

    init(client: SupportedPairsClientAPI = resolve()) {
        self.client = client

        let cache = InMemoryCache<SupportedPairsFilterOption, SupportedPairs>(
            configuration: .onUserStateChanged(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()

        self.cachedValue = ThisCachedValue(
            cache: cache,
            fetch: { key in
                client.supportedPairs(with: key)
                    .map { SupportedPairs(response: $0, filterOption: key) }
                    .eraseToAnyPublisher()
            }
        )
    }

    // MARK: - SupportedPairsServiceAPI

    func fetchPairs(for option: SupportedPairsFilterOption) -> AnyPublisher<SupportedPairs, NabuNetworkError> {
        cachedValue.get(key: option)
    }
}
