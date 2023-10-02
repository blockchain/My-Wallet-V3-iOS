// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public protocol PlaidClientAPI {

    /// 1- In order to create a new plaid/ACH account, the client should first obtain a link_token from payments gateway.

    func getLinkToken(
    ) -> AnyPublisher<LinkTokenResponse, NabuError>

    func getLinkToken(
        body: LinkTokenRequest
    ) -> AnyPublisher<LinkTokenResponse, NabuError>

    ///  2 - A public_token as well as an account_id (representing the single selected account in Link) are provided in Link's onSuccess callback.
    ///  The client should provide these values in the update call to activate the plaid account.

    func updatePlaidAccount(
        _ accountId: String,
        body: UpdatePlaidAccountRequest
    ) -> AnyPublisher<UpdatePlaidAccountResponse, NabuError>

    /// 3 - Existing Yodlee accounts will be migrated to Plaid when they attempt payment through an interface that now supports Plaid.
    /// This flow will reuse components of the refresh flow described above for existing Plaid accounts.

    func getLinkToken(
        accountId: String
    ) -> AnyPublisher<LinkTokenResponse, NabuError>

    func getLinkToken(
        accountId: String,
        body: LinkTokenRequest
    ) -> AnyPublisher<LinkTokenResponse, NabuError>

    /// Wait for recently added/updated/migrated bank to be active, so that it can be used during buy/deposit flow

    func getLinkedBanks(
    ) -> AnyPublisher<[LinkedBankResponse], NabuError>

    func getSettlementInfo(
        accountId: String,
        amount: String,
        product: String
    ) -> AnyPublisher<SettlementInfoResponse, NabuError>

    func getPaymentsDepositTerms(
        amount: MoneyValue,
        paymentMethodId: String
    ) -> AnyPublisher<PaymentsDepositTermsResponse, NabuError>
}
