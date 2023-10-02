// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Errors
import MoneyKit
import ToolKit

public protocol OrdersActivityServiceAPI: AnyObject {

    func activity(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[CustodialActivityEvent.Fiat], NabuNetworkError>

    func activity(
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[CustodialActivityEvent.Crypto], NabuNetworkError>
}

final class OrdersActivityService: OrdersActivityServiceAPI {

    private let client: OrdersActivityClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let cachedValue: CachedValueNew<
        CurrencyType,
        OrdersActivityResponse,
        NabuNetworkError
    >

    init(
        app: AppProtocol,
        client: OrdersActivityClientAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        priceService: PriceServiceAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.enabledCurrenciesService = enabledCurrenciesService

        let cache = InMemoryCache<CurrencyType, OrdersActivityResponse>(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 90)
        )
        .eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [app] key in
                app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
                    .replaceError(with: false)
                    .flatMap { isEligible in
                        client.activityResponse(currency: key, product: isEligible ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY")
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func activity(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[CustodialActivityEvent.Fiat], NabuNetworkError> {
        cachedValue
            .get(key: fiatCurrency.currencyType)
            .map(\.items)
            .map { items in
                items
                    .compactMap(CustodialActivityEvent.Fiat.init)
                    .filter { $0.paymentError == nil }
            }
            .eraseToAnyPublisher()
    }

    func activity(
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[CustodialActivityEvent.Crypto], NabuNetworkError> {
        cachedValue
            .get(key: cryptoCurrency.currencyType)
            .map(\.items)
            .flatMap { [fiatCurrencyService, priceService, enabledCurrenciesService] items in
                items
                    .map { item in
                        // Get the display currency:
                        fiatCurrencyService
                            .displayCurrency
                            .flatMap { [priceService] fiatCurrency in
                                // Get price of activity currency at each activity time:
                                priceService
                                    .price(
                                        of: cryptoCurrency,
                                        in: fiatCurrency,
                                        at: .time(item.insertedAtDate)
                                    )
                                    .optional()
                                    .replaceError(with: nil)
                            }
                            // Map to CustodialActivityEvent.Crypto
                            .compactMap { [enabledCurrenciesService] price in
                                guard let fiatPrice = price?.moneyValue.fiatValue else {
                                    return nil
                                }
                                return CustodialActivityEvent.Crypto(
                                    item: item,
                                    price: fiatPrice,
                                    enabledCurrenciesService: enabledCurrenciesService
                                )
                            }
                    }
                    .zip()
            }
            .eraseToAnyPublisher()
    }
}
