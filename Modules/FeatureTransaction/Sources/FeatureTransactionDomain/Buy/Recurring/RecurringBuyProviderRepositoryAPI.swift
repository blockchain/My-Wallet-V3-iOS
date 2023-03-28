// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public protocol RecurringBuyProviderRepositoryAPI {
    func fetchRecurringBuysForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency?
    ) -> AnyPublisher<[RecurringBuy], NabuNetworkError>

    func fetchRecurringBuyWithRecurringBuyId(
        _ recurringBuyId: String
    ) -> AnyPublisher<RecurringBuy, NabuNetworkError>
}
