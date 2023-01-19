// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

public final class PriceServiceMock: PriceServiceAPI {

    public struct StubbedResults {
        public var moneyValuePair = MoneyValuePair(
            base: .one(currency: .bitcoin),
            quote: MoneyValue.create(minor: 10000000, currency: .fiat(.USD))
        )
        public var historicalPriceSeries = HistoricalPriceSeries(
            currency: .bitcoin,
            prices: [
                PriceQuoteAtTime(
                    timestamp: Date(),
                    moneyValue: MoneyValue.create(minor: 10000000, currency: .fiat(.USD))
                )
            ]
        )
        public var priceQuoteAtTime = PriceQuoteAtTime(
            timestamp: Date(),
            moneyValue: MoneyValue.create(minor: 10000000, currency: .fiat(.USD))
        )
    }

    public var stubbedResults = StubbedResults()

    public init() {}

    public func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, PriceServiceError> {
        .just(stubbedResults.moneyValuePair)
    }

    public func price(
        of base: Currency,
        in quote: Currency
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        .just(stubbedResults.priceQuoteAtTime)
    }

    public func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        .just(stubbedResults.priceQuoteAtTime)
    }

    public func priceSeries(
        of baseCurrency: CryptoCurrency,
        in quoteCurrency: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, PriceServiceError> {
        .just(stubbedResults.historicalPriceSeries)
    }

    public func stream(quote: Currency) -> AnyPublisher<Result<[String: PriceQuoteAtTime], NetworkError>, Never> {
        .just(.success([:]))
    }

    public func prices(
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<[String: PriceQuoteAtTime], PriceServiceError> {
        .just([:])
    }
}
