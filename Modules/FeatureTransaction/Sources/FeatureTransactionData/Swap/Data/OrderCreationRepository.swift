// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class OrderCreationRepository: OrderCreationRepositoryAPI {

    // MARK: - Properties

    private let client: OrderCreationClientAPI

    // MARK: - Setup

    init(client: OrderCreationClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - OrderCreationServiceAPI

    func createOrder(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        destinationAddress: String?,
        refundAddress: String?
    ) -> AnyPublisher<SwapOrder, NabuNetworkError> {
        client
            .create(
                direction: direction,
                quoteIdentifier: quoteIdentifier,
                volume: volume,
                destinationAddress: destinationAddress,
                refundAddress: refundAddress
            )
            .map(SwapOrder.init)
            .eraseToAnyPublisher()
    }

    func createOrder(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        ccy: String?,
        refundAddress: String?
    ) -> AnyPublisher<SellOrder, NabuNetworkError> {
        client
            .create(
                direction: direction,
                quoteIdentifier: quoteIdentifier,
                volume: volume,
                ccy: ccy,
                refundAddress: refundAddress
            )
            .map(SellOrder.init)
            .eraseToAnyPublisher()
    }
}

extension SwapOrder {

    fileprivate init(response: SwapActivityItemEvent) {
        self.init(
            identifier: response.identifier,
            state: response.status,
            depositAddress: response.kind.depositAddress
        )
    }
}

extension SellOrder {

    fileprivate init(response: SwapActivityItemEvent) {
        self.init(
            identifier: response.identifier,
            state: response.status,
            ccy: response.ccy,
            depositAddress: response.kind.depositAddress
        )
    }
}
