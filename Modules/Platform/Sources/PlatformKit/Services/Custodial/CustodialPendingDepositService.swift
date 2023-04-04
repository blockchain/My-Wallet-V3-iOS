// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MoneyKit
import RxSwift
import ToolKit

struct CreatePendingDepositRequestBody: Encodable {
    let currency: String
    let amount: String
    let depositAddress: String
    let txHash: String
    let product: String

    init(
        value: MoneyValue,
        destination: String,
        transactionHash: String,
        product: String
    ) {
        self.currency = value.code
        self.amount = value.minorString
        self.depositAddress = destination
        self.txHash = transactionHash
        self.product = product
    }
}

protocol CustodialPendingDepositClientAPI: AnyObject {
    func createPendingDeposit(
        body: CreatePendingDepositRequestBody
    ) -> AnyPublisher<Void, NabuNetworkError>
}

public protocol CustodialPendingDepositServiceAPI: AnyObject {

    func createPendingDeposit(
        value: MoneyValue,
        destination: String,
        transactionHash: String,
        product: String
    ) -> AnyPublisher<Void, NabuNetworkError>
}

final class CustodialPendingDepositService: CustodialPendingDepositServiceAPI {

    private let client: CustodialPendingDepositClientAPI

    // MARK: - Setup

    init(client: CustodialPendingDepositClientAPI = resolve()) {
        self.client = client
    }

    func createPendingDeposit(
        value: MoneyValue,
        destination: String,
        transactionHash: String,
        product: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let body = CreatePendingDepositRequestBody(
            value: value,
            destination: destination,
            transactionHash: transactionHash,
            product: product
        )
        return client.createPendingDeposit(body: body)
    }
}
