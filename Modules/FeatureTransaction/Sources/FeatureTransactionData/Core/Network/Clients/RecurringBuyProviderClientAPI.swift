import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

protocol RecurringBuyProviderClientAPI {
    func fetchRecurringBuysForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency?
    ) -> AnyPublisher<[RecurringBuyResponse], NabuNetworkError>

    func fetchRecurringBuysWithRecurringBuyId(
        _ recurringBuyId: String
    ) -> AnyPublisher<[RecurringBuyResponse], NabuNetworkError>
}
