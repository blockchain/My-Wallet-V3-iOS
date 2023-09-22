// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import NetworkKit
import PlatformKit
import ToolKit

typealias FeatureInterestDataAPIClient =
    InterestAccountBalanceClientAPI &
    InterestAccountLimitsClientAPI &
    InterestAccountRateClientAPI &
    InterestAccountTransferClientAPI &
    InterestAccountWithdrawClientAPI

final class APIClient: FeatureInterestDataAPIClient {

    private enum Path {
        static let withdraw = ["savings", "withdrawals"]
        static let balance = ["accounts", "savings"]
        static let rate = ["savings", "rates"]
        static let limits = ["savings", "limits"]
        static let transfer = ["custodial", "transfer"]
    }

    private enum Parameter {
        static let currency = "currency"
        static let ccy = "ccy"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func createInterestAccountWithdrawal(
        _ amount: MoneyValue,
        address: String,
        currencyCode: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let body = InterestAccountWithdrawRequest(
            withdrawalAddress: address,
            amount: amount.minorString,
            currency: currencyCode
        )
        let request = requestBuilder.post(
            path: Path.withdraw,
            body: try? body.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchBalanceWithFiatCurrency(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountBalanceResponse?, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.balance,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchInterestAccountLimitsResponseForFiatCurrency(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountLimitsResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.limits,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchAllInterestAccountRates()
        -> AnyPublisher<SupportedInterestAccountRatesResponse, NabuNetworkError>
    {
        let request = requestBuilder.get(
            path: Path.rate,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchInterestAccountRateForCurrencyCode(
        _ currencyCode: String
    ) -> AnyPublisher<InterestAccountRateResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.ccy,
                value: currencyCode
            )
        ]
        let request = requestBuilder.get(
            path: Path.rate,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func createInterestAccountCustodialTransfer(
        _ amount: MoneyValue
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let body = InterestAccountTransferRequest
            .createTransferRequestWithAmount(
                amount.minorString,
                currencyCode: amount.code
            )

        let request = requestBuilder
            .post(
                path: Path.transfer,
                body: try? body.encode(),
                authenticated: true
            )!

        return networkAdapter
            .perform(request: request)
    }

    func createInterestAccountCustodialWithdraw(
        _ amount: MoneyValue
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let body = InterestAccountTransferRequest
            .createWithdrawRequestWithAmount(
                amount.minorString,
                currencyCode: amount.code
            )

        let request = requestBuilder
            .post(
                path: Path.transfer,
                body: try? body.encode(),
                authenticated: true
            )!

        return networkAdapter
            .perform(request: request)
    }
}
