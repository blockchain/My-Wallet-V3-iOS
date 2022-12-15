// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MoneyKit
import NetworkKit

public final class PlaidClient: PlaidClientAPI {
    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - Get Link Token For Linking a New Bank

    public func getLinkToken(
    ) -> AnyPublisher<LinkTokenResponse, NabuError> {
        getLinkToken(body: .init())
    }

    public func getLinkToken(
        body: LinkTokenRequest
    ) -> AnyPublisher<LinkTokenResponse, NabuError> {
        let request = requestBuilder.post(
            path: "/payments/banktransfer",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - Get Link Token For Migrating or relinking a Bank

    public func getLinkToken(
        accountId: String
    ) -> AnyPublisher<LinkTokenResponse, NabuError> {
        getLinkToken(accountId: accountId, body: .init())
    }

    public func getLinkToken(
        accountId: String,
        body: LinkTokenRequest
    ) -> AnyPublisher<LinkTokenResponse, NabuError> {
        let request = requestBuilder.post(
            path: "/payments/banktransfer/\(accountId)/refresh",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - Update Plaid Account

    public func updatePlaidAccount(
        _ accountId: String,
        body: UpdatePlaidAccountRequest
    ) -> AnyPublisher<UpdatePlaidAccountResponse, NabuError> {
        let request = requestBuilder.post(
            path: "/payments/banktransfer/\(accountId)/update",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - Wait for recently added/updated/migrated bank to be active

    public func getLinkedBanks(
    ) -> AnyPublisher<[LinkedBankResponse], NabuError> {
        let request = requestBuilder.get(
            path: "/payments/banktransfer",
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - Get settlement info to see if account needs to be renewed/migrated

    public func getSettlementInfo(
        accountId: String,
        amount: String
    ) -> AnyPublisher<SettlementInfoResponse, NabuError> {
        let body = SettlementInfoRequest(amount: amount)
        let request = requestBuilder.post(
            path: "/payments/banktransfer/\(accountId)/update",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - Get payments Deposit Terms

    public func getPaymentsDepositTerms(
        amount: MoneyValue,
        paymentMethodId: String
    ) -> AnyPublisher<PaymentsDepositTermsResponse, NabuError> {
        let body = PaymentsDepositTermsRequest(
            amount: .init(moneyValue: amount),
            paymentMethodId: paymentMethodId
        )
        let request = requestBuilder.put(
            path: "/payments/deposit/terms",
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
