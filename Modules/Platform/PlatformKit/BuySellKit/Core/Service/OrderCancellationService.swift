// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public protocol OrderCancellationServiceAPI: AnyObject {

    /// Cancels an order associated with the given id
    func cancel(order id: String) -> Completable
}

final class OrderCancellationService: OrderCancellationServiceAPI {

    // MARK: - Injected

    private let client: OrderCancellationClientAPI
    private let orderDetailsService: OrdersServiceAPI

    // MARK: - Setup

    init(client: OrderCancellationClientAPI = resolve(),
         orderDetailsService: OrdersServiceAPI = resolve()) {
        self.client = client
        self.orderDetailsService = orderDetailsService
    }

    // MARK: - Exposed

    public func cancel(order id: String) -> Completable {
            // Cancel the order
            self.client.cancel(order: id)
                // Fetch the orders anew
                .andThen(orderDetailsService.fetchOrders())
                .asCompletable()
    }
}
