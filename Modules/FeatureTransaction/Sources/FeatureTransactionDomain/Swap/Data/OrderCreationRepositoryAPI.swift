// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

public protocol OrderCreationRepositoryAPI {

    func createOrder(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        destinationAddress: String?,
        refundAddress: String?
    ) -> AnyPublisher<SwapOrder, NabuNetworkError>

    func createOrder(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        ccy: String?,
        refundAddress: String?
    ) -> AnyPublisher<SellOrder, NabuNetworkError>
}

public protocol OrderUpdateRepositoryAPI {

    func updateOrder(
        identifier: String,
        success: Bool
    ) -> AnyPublisher<Void, NabuNetworkError>
}
