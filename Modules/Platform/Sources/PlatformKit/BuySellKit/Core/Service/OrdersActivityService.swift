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

    func activityCryptoCurrency(
        displayCurrency: FiatCurrency
    ) -> AnyPublisher<[CustodialActivityEvent.Crypto], NabuNetworkError>

    func allActivity(
        displayCurrency: FiatCurrency
    ) -> AnyPublisher<[Either<CustodialActivityEvent.Fiat, CustodialActivityEvent.Crypto>], NabuNetworkError>
}

final class OrdersActivityService: OrdersActivityServiceAPI {

    private let client: OrdersActivityClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI
    private let currenciesService: EnabledCurrenciesServiceAPI
    private let cachedValue: CachedValueNew<
        Key,
        OrdersActivityResponse,
        NabuNetworkError
    >
    private enum Key: Hashable {
        case all
        case currency(CurrencyType)

        var currency: CurrencyType? {
            switch self {
            case .all:
                return nil
            case .currency(let value):
                return value
            }
        }
    }

    init(
        app: AppProtocol,
        client: OrdersActivityClientAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        priceService: PriceServiceAPI,
        currenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.currenciesService = currenciesService

        let cache = InMemoryCache<Key, OrdersActivityResponse>(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 40)
        )
        .eraseToAnyCache()
        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [app] key in
                app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
                    .replaceError(with: false)
                    .flatMap { isExternalBrokerage in
                        client
                            .activityResponse(
                                currency: key.currency,
                                product: isExternalBrokerage ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY"
                            )
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
            .get(key: .currency(fiatCurrency.currencyType))
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
            .get(key: .currency(cryptoCurrency.currencyType))
            .map(\.items)
            .flatMap { [fiatCurrencyService, priceService, currenciesService] items in
                fiatCurrencyService
                    .displayCurrency
                    .flatMap { displayCurrency in
                        mapCryptoItems(
                            items: items,
                            displayCurrency: displayCurrency,
                            priceService: priceService,
                            currenciesService: currenciesService
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    func activityCryptoCurrency(
        displayCurrency: FiatCurrency
    ) -> AnyPublisher<[CustodialActivityEvent.Crypto], NabuNetworkError> {
        cachedValue
            .get(key: .all)
            .map(\.items)
            .flatMap { [priceService, currenciesService] items in
                mapCryptoItems(
                    items: items,
                    displayCurrency: displayCurrency,
                    priceService: priceService,
                    currenciesService: currenciesService
                )
            }
            .eraseToAnyPublisher()
    }

    func allActivity(
        displayCurrency: FiatCurrency
    ) -> AnyPublisher<[Either<CustodialActivityEvent.Fiat, CustodialActivityEvent.Crypto>], NabuNetworkError> {
        cachedValue
            .get(key: .all)
            .map(\.items)
            .flatMap { [priceService, currenciesService] items in
                let fiatItems = items
                    .compactMap(CustodialActivityEvent.Fiat.init)
                    .filter { $0.paymentError == nil }
                    .map(Either<CustodialActivityEvent.Fiat, CustodialActivityEvent.Crypto>.left)

                return mapCryptoItems(
                    items: items,
                    displayCurrency: displayCurrency,
                    priceService: priceService,
                    currenciesService: currenciesService
                )
                .map { items in
                    items.map(Either<CustodialActivityEvent.Fiat, CustodialActivityEvent.Crypto>.right)
                        + fiatItems
                }
            }
            .eraseToAnyPublisher()
    }
}

private func mapCryptoItems(
    items: [OrdersActivityResponse.Item],
    displayCurrency: FiatCurrency,
    priceService: PriceServiceAPI,
    currenciesService: EnabledCurrenciesServiceAPI
) -> AnyPublisher<[CustodialActivityEvent.Crypto], Never> {
    items
        .compactMap { item -> AnyPublisher<CustodialActivityEvent.Crypto, Never>? in
            guard let cryptoCurrency = CryptoCurrency(code: item.amount.symbol, service: currenciesService) else {
                return nil
            }
            // Get price of activity currency at each activity time:
            return priceService
                .price(
                    of: cryptoCurrency,
                    in: displayCurrency,
                    at: .time(item.insertedAtDate)
                )
                .optional()
                .replaceError(with: nil)
                // Map to CustodialActivityEvent.Crypto:
                .compactMap { price in
                    CustodialActivityEvent.Crypto(
                        item: item,
                        price: price?.moneyValue.fiatValue,
                        enabledCurrenciesService: currenciesService
                    )
                }
                .eraseToAnyPublisher()
        }
        .zip()
}
