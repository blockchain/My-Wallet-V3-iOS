// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import Dependencies
import DIKit
import Errors
import MoneyKit
import NetworkKit
import ToolKit

public protocol TradingBalanceClientAPI: AnyObject {
    var balance: AnyPublisher<CustodialBalanceResponse?, NabuNetworkError> { get }
    var externalBrokerageBalance: AnyPublisher<CustodialBalanceResponse?, NabuNetworkError> { get }

    func balance(
        for currencyType: CurrencyType
    ) -> AnyPublisher<CustodialBalanceResponse?, NabuNetworkError>
}

final class CustodialClient: TradingBalanceClientAPI,
    CustodialPaymentAccountClientAPI,
    CustodialPendingDepositClientAPI
{

    @Dependency(\.app) var app

    // MARK: - Types

    private enum Path {
        static let withdrawal = ["payments", "withdrawals"]
        static let paymentAccount = ["payments", "accounts", "simplebuy"]
        static let custodialBalance = ["accounts", "simplebuy"]
        static let externalBalance = ["accounts", "external_brokerage"]
    }

    // MARK: - Properties

    var balance: AnyPublisher<CustodialBalanceResponse?, NabuNetworkError> {
        let path = Path.custodialBalance
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return networkAdapter
            .performOptional(
                request: request,
                responseType: CustodialBalanceResponse.self
            )
    }

    var externalBrokerageBalance: AnyPublisher<CustodialBalanceResponse?, NabuNetworkError> {
        let path = Path.externalBalance
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return networkAdapter
            .performOptional(
                request: request,
                responseType: CustodialBalanceResponse.self
            )
    }

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

    // MARK: - CustodialPendingDepositClientAPI

    func createPendingDeposit(
        body: CreatePendingDepositRequestBody
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let request = requestBuilder.post(
            path: Path.withdrawal,
            body: try? body.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - TradingBalanceClientAPI

    func balance(
        for currencyType: CurrencyType
    ) -> AnyPublisher<CustodialBalanceResponse?, NabuNetworkError> {
        balance
    }

    // MARK: - CustodialPaymentAccountClientAPI

    func custodialPaymentAccount(
        for cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<PaymentAccount.Response, NabuNetworkError> {
        struct Payload: Encodable {
            let currency: String
        }

        let payload = Payload(currency: cryptoCurrency.code)
        let request = requestBuilder.put(
            path: Path.paymentAccount,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
