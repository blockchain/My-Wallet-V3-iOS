// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCoinDomain
import Foundation
import MoneyKit

public struct HistoricalPriceRepository: HistoricalPriceRepositoryAPI {

    let client: HistoricalPriceClientAPI
    let prices: IndexMutiSeriesPriceService

    public init(_ client: HistoricalPriceClientAPI, prices: IndexMutiSeriesPriceService) {
        self.client = client
        self.prices = prices
    }

    public func fetchGraphData(
        base: CryptoCurrency,
        quote: FiatCurrency,
        series: Series,
        relativeTo: Date
    ) -> AnyPublisher<GraphData, NetworkError> {

        client.fetchPriceIndexes(base: base, quote: quote, series: series, relativeTo: relativeTo)
            .flatMap { [prices] data in
                prices.publisher(for: .init(base: base, quote: quote))
                    .compacted()
                    .map { price -> [PriceIndex] in
                        [PriceIndex(price: price.price ?? 0, timestamp: price.timestamp)]
                    }
                    .map { today in data + today }
                    .eraseToAnyPublisher()
            }
            .map { series in
                GraphData(
                    series: series.map { GraphData.Index(price: $0.price, timestamp: $0.timestamp) },
                    base: base,
                    quote: quote
                )
            }
            .eraseToAnyPublisher()
    }
}

extension HistoricalPriceClientAPI {
    fileprivate func fetchPriceIndexes(
        base: CryptoCurrency,
        quote: FiatCurrency,
        series: Series,
        relativeTo: Date
    ) -> AnyPublisher<[PriceIndex], NetworkError> {
        fetchPriceIndexes(
            baseCode: base.code,
            quoteCode: quote.code,
            window: .init(value: series.window.value, component: series.window.component),
            scale: series.scale.value,
            relativeTo: relativeTo
        )
    }
}
