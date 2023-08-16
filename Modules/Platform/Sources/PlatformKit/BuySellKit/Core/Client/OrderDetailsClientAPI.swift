// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

struct AccumulatedTradeDetails: Equatable, Decodable {

    enum TimePeriod: String, Equatable, Decodable {
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
        case all = "ALL"
    }

    let amount: MoneyValue
    let period: TimePeriod
}

protocol OrderDetailsClientAPI: AnyObject {

    func fetchAccumulatedTradeAmounts(products: String) -> AnyPublisher<[AccumulatedTradeDetails], NabuNetworkError>

    /// Fetch all Buy/Sell orders
    func orderDetails(
        pendingOnly: Bool
    ) -> AnyPublisher<[OrderPayload.Response], NabuNetworkError>

    /// Fetch a single Buy/Sell order
    func orderDetails(
        with identifier: String
    ) -> AnyPublisher<OrderPayload.Response, NabuNetworkError>
}
