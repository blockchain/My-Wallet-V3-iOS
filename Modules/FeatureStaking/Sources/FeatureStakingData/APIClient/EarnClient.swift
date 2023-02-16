// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import FeatureStakingDomain
import NetworkKit

public final class EarnClient {

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    let product: String

    // MARK: - Setup

    public init(
        product: String,
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.product = product
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func balances() -> AnyPublisher<EarnAccounts, Nabu.Error> {
        networkAdapter.perform(
            request: requestBuilder.get(
                path: ["accounts", product],
                authenticated: true
            )!
        )
    }

    public func eligibility() -> AnyPublisher<EarnEligibility, Nabu.Error> {
        networkAdapter.perform(
            request: requestBuilder.get(
                path: ["earn", "eligible"],
                parameters: [
                    URLQueryItem(name: "product", value: product)
                ],
                authenticated: true
            )!
        )
    }

    public func userRates() -> AnyPublisher<EarnUserRates, Nabu.Error> {
        networkAdapter.perform(
            request: requestBuilder.get(
                path: ["earn", "rates-user"],
                parameters: [
                    URLQueryItem(name: "product", value: product)
                ],
                authenticated: true
            )!
        )
    }

    public func limits(currency: FiatCurrency) -> AnyPublisher<EarnLimits, Nabu.Error> {
        let response: AnyPublisher<[String: EarnLimits], Nabu.Error> = networkAdapter.perform(
            request: requestBuilder.get(
                path: ["earn", "limits"],
                parameters: [
                    URLQueryItem(name: "product", value: product),
                    URLQueryItem(name: "currency", value: currency.code)
                ],
                authenticated: true
            )!
        )
        return response.compactMap(\.["limits"]).eraseToAnyPublisher()
    }

    public func address(currency: CryptoCurrency) -> AnyPublisher<EarnAddress, Nabu.Error> {
        networkAdapter.perform(
            request: requestBuilder.get(
                path: ["payments", "accounts", product],
                parameters: [.init(name: "ccy", value: currency.code)],
                authenticated: true
            )!
        )
    }

    public func activity(currency: CryptoCurrency) -> AnyPublisher<[EarnActivity], Nabu.Error> {
        let request: AnyPublisher<EarnActivityList, Nabu.Error> = networkAdapter.perform(
            request: requestBuilder.get(
                path: ["payments", "transactions"],
                parameters: [
                    URLQueryItem(
                        name: "currency",
                        value: currency.code
                    ),
                    URLQueryItem(
                        name: "product",
                        value: product
                    )
                ],
                authenticated: true
            )!
        )
        return request.map(\.items).eraseToAnyPublisher()
    }

    public func deposit(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error> {
        networkAdapter.perform(
            request: requestBuilder
                .post(
                    path: ["custodial", "transfer"],
                    body: try? [
                        "amount": amount.minorString,
                        "currency": amount.code,
                        "origin": "SIMPLEBUY",
                        "destination": product.uppercased()
                    ].encode(),
                    authenticated: true
                )!
        )
    }

    public func withdraw(amount: MoneyValue) -> AnyPublisher<Void, Nabu.Error> {
        networkAdapter.perform(
            request: requestBuilder
                .post(
                    path: ["custodial", "transfer"],
                    body: try? [
                        "amount": amount.minorString,
                        "currency": amount.code,
                        "origin": product.uppercased(),
                        "destination": "SIMPLEBUY"
                    ].encode(),
                    authenticated: true
                )!
        )
    }
}
