// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

protocol OrdersActivityClientAPI: AnyObject {

    /// Fetch order activity response
    func activityResponse(
        currency: Currency,
        product: String
    ) -> AnyPublisher<OrdersActivityResponse, NabuNetworkError>
}
