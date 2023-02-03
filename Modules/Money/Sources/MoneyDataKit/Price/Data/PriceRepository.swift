// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import Foundation
import MoneyDomainKit
import ToolKit

final class PriceRepository: PriceRepositoryAPI {

    // MARK: - Setup

    private let client: PriceClientAPI
    private let indexMultiCachedValue: CachedValueNew<
        PriceRequest.IndexMulti.Key,
        [String: PriceQuoteAtTime],
        NetworkError
    >
    private let symbolsCachedValue: CachedValueNew<
        PriceRequest.Symbols.Key,
        Set<String>,
        NetworkError
    >

    // MARK: - Setup

    init(
        client: PriceClientAPI,
        refreshControl: CacheRefreshControl = PeriodicCacheRefreshControl(refreshInterval: 60)
    ) {
        self.client = client
        let indexMultiCache = InMemoryCache<PriceRequest.IndexMulti.Key, [String: PriceQuoteAtTime]>(
            configuration: .default(),
            refreshControl: refreshControl
        )
        .eraseToAnyCache()
        self.indexMultiCachedValue = CachedValueNew(
            cache: indexMultiCache,
            fetch: { key in
                client
                    .price(of: key.base, in: key.quote.code, time: key.time.timestamp)
                    .map(\.entries)
                    .map { entries in
                        entries.compactMapValues { item in
                            item
                                .flatMap {
                                    PriceQuoteAtTime(
                                        response: $0,
                                        currency: key.quote.currencyType
                                    )
                                }
                        }
                    }
                    .eraseToAnyPublisher()
            }
        )
        let symbolsCache = InMemoryCache<PriceRequest.Symbols.Key, Set<String>>(
            configuration: .default(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()
        self.symbolsCachedValue = CachedValueNew(
            cache: symbolsCache,
            fetch: { _ in
                client.symbols()
                    .map(\.base.keys)
                    .map(Set.init)
                    .eraseToAnyPublisher()
            }
        )
    }

    func stream(
        bases: [Currency],
        quote: Currency,
        at time: PriceTime,
        skipStale: Bool
    ) -> AnyPublisher<Result<[String: PriceQuoteAtTime], NetworkError>, Never> {
        let bases = Set(bases.map(\.code))
        return symbolsCachedValue
            .stream(
                key: PriceRequest.Symbols.Key(),
                skipStale: skipStale
            )
            .flatMap { [indexMultiCachedValue] symbols -> AnyPublisher<Result<[String: PriceQuoteAtTime], NetworkError>, Never> in
                indexMultiCachedValue.stream(
                    key: PriceRequest.IndexMulti.Key(
                        base: Set(symbols).intersection(bases),
                        quote: quote.currencyType,
                        time: time
                    ),
                    skipStale: skipStale
                )
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func prices(
        of bases: [Currency],
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<[String: PriceQuoteAtTime], NetworkError> {
        stream(bases: bases, quote: quote, at: time, skipStale: true)
            .first()
            .get()
            .eraseToAnyPublisher()
    }

    func priceSeries(
        of base: CryptoCurrency,
        in quote: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, NetworkError> {
        let start: TimeInterval = window.timeIntervalSince1970(
            calendar: .current,
            date: Date()
        )
        return client
            .priceSeries(
                of: base.code,
                in: quote.code,
                start: start.string(with: 0),
                scale: String(window.scale)
            )
            .map { response in
                HistoricalPriceSeries(baseCurrency: base, quoteCurrency: quote, prices: response)
            }
            .eraseToAnyPublisher()
    }
}

extension HistoricalPriceSeries {

    init(baseCurrency: CryptoCurrency, quoteCurrency: Currency, prices: [PriceResponse.Item]) {
        self.init(
            currency: baseCurrency,
            prices: prices.compactMap { item in
                PriceQuoteAtTime(response: item, currency: quoteCurrency)
            }
        )
    }
}

extension PriceQuoteAtTime {

    init?(response: PriceResponse.Item, currency: Currency) {
        guard let price = response.price else {
            return nil
        }
        self.init(
            timestamp: response.timestamp,
            moneyValue: .create(
                major: price,
                currency: currency.currencyType
            ),
            marketCap: response.marketCap,
            volume24h: response.volume24h
        )
    }
}
