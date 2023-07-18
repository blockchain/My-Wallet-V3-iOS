// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

final class NoOpPriceService: PriceServiceAPI {

    func symbols() -> AnyPublisher<MoneyKit.CurrencySymbols, MoneyKit.PriceServiceError> {
        Empty().eraseToAnyPublisher()
    }

    func stream(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<Result<PriceQuoteAtTime, PriceServiceError>, Never> {
        Empty().eraseToAnyPublisher()
    }

    func stream(
        quote: Currency,
        at time: PriceTime,
        skipStale: Bool
    ) -> AnyPublisher<Result<[String: PriceQuoteAtTime], NetworkError>, Never> {
        Empty().eraseToAnyPublisher()
    }

    func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, PriceServiceError> {
        Empty().eraseToAnyPublisher()
    }

    func price(
        of base: Currency,
        in quote: Currency
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        Empty().eraseToAnyPublisher()
    }

    func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        Empty().eraseToAnyPublisher()
    }

    func priceSeries(
        of base: CryptoCurrency,
        in quote: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, PriceServiceError> {
        Empty().eraseToAnyPublisher()
    }

    func prices(
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<[String: PriceQuoteAtTime], PriceServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
