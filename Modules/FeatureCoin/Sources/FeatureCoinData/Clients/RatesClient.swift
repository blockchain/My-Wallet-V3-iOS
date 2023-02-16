// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public protocol RatesClientAPI {

    func fetchInterestAccountRateForCurrencyCode(
        _ currencyCode: String
    ) -> AnyPublisher<InterestAccountRateResponse, NetworkError>

    func fetchStakingAccountRateForCurrencyCode() -> AnyPublisher<StakingUserRatesResponse, NetworkError>
    func fetchActiveRewardsAccountRateForCurrencyCode() -> AnyPublisher<StakingUserRatesResponse, NetworkError>
}

public struct RatesClient: RatesClientAPI {

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchInterestAccountRateForCurrencyCode(
        _ currencyCode: String
    ) -> AnyPublisher<InterestAccountRateResponse, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: "ccy",
                value: currencyCode
            )
        ]
        let request = requestBuilder.get(
            path: "/savings/rates",
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    public func fetchStakingAccountRateForCurrencyCode() -> AnyPublisher<StakingUserRatesResponse, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: "product",
                value: "staking"
            )
        ]
        let request = requestBuilder.get(
            path: "/earn/rates-user",
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    public func fetchActiveRewardsAccountRateForCurrencyCode() -> AnyPublisher<StakingUserRatesResponse, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: "product",
                value: "EARN_CC1W"
            )
        ]
        let request = requestBuilder.get(
            path: "/earn/rates-user",
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
