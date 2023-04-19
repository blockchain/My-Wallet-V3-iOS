// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

final class RecurringBuyProviderService: RecurringBuyProviderServiceAPI {

    private let repository: RecurringBuyProviderRepositoryAPI

    init(repository: RecurringBuyProviderRepositoryAPI) {
        self.repository = repository
    }

    // MARK: - RecurringBuyServiceAPI

    func fetchRecurringBuysForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency?
    ) -> AnyPublisher<[RecurringBuy], NabuNetworkError> {
        repository
            .fetchRecurringBuysForCryptoCurrency(cryptoCurrency)
    }

    func fetchRecurringBuyWithRecurringBuyId(
        _ recurringBuyId: String
    ) -> AnyPublisher<RecurringBuy, NabuNetworkError> {
        repository
            .fetchRecurringBuyWithRecurringBuyId(recurringBuyId)
    }
}
