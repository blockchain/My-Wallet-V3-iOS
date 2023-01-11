// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCoinDomain
import Foundation
import MoneyKit
import ToolKit

public struct RatesRepository: RatesRepositoryAPI {

    private let client: RatesClientAPI

    private let cachedValue: CachedValueNew<
        String,
        EarnRates,
        NetworkError
    >

    public init(_ client: RatesClientAPI) {
        self.client = client

        let cache: AnyCache<String, EarnRates> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        )
        .eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] code -> AnyPublisher<EarnRates, NetworkError> in
                retrieveRates(
                    client: client,
                    code: code
                )
            }
        )
    }

    public func fetchEarnRates(
        code: String
    ) -> AnyPublisher<EarnRates, NetworkError> {
        cachedValue.get(key: code)
    }
}

private func retrieveRates(
    client: RatesClientAPI,
    code: String
) -> AnyPublisher<EarnRates, NetworkError> {
    let stakingRatePublisher = client.fetchStakingAccountRateForCurrencyCode()
        .map { $0[code]?.rate ?? 0 }
        .eraseToAnyPublisher()
    let activeRewardsRatePublisher = client.fetchActiveRewardsAccountRateForCurrencyCode()
        .map { $0[code]?.rate ?? 0 }
        .eraseToAnyPublisher()
    return client.fetchInterestAccountRateForCurrencyCode(code)
        .map(\.rate)
        .zip(stakingRatePublisher, activeRewardsRatePublisher)
        .map { interestRate, stakingRate, activeRewardsRate in
            EarnRates(
                stakingRate: stakingRate,
                interestRate: interestRate,
                activeRewardsRate: activeRewardsRate
            )
        }
        .eraseToAnyPublisher()
}
