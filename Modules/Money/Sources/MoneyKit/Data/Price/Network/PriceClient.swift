// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

/// A client that interacts with `Service-Price` in order to fetch all price related data (quoted prices and historical price series from crypto to fiat).
/// Read the [API Spec](https://api.blockchain.com/price/specs) for more information.
public protocol PriceClientAPI {

    /// Fetches collection of supported symbols.
    func symbols() -> AnyPublisher<CurrencySymbols, NetworkError>

    /// Fetches the quoted price of the given base currencies, in the given quote currency, at the given time.
    ///
    /// - Parameters:
    ///   - bases: The array of fiat or crypto currency codes to fetch the price of. Must be supported in [symbols](https://api.blockchain.info/price/symbols).
    ///   - quote: The fiat currency code to fetch the price in.
    ///   - time:  The Unix time to fetch the price at. A value of `nil` will default to the current time.
    ///
    /// - Returns: A publisher that emits a `PriceResponse.IndexMulti.Response` on success, or a `NetworkError` on failure.
    func price(
        of bases: Set<String>,
        in quote: String,
        time: String?
    ) -> AnyPublisher<PriceResponse.IndexMulti.Response, NetworkError>

    /// Fetches the historical price series of the given `CryptoCurrency`-`FiatCurrency` pair, from the given start time to the current time, using the given scale.
    ///
    /// - Parameters:
    ///   - base:  The code of the crypto currency to fetch the price series of.
    ///   - quote: The code of the fiat currency to fetch the price series in.
    ///   - start: The start of the time range in Unix time.
    ///   - scale: The time interval in seconds between consecutive prices.
    ///
    /// - Returns: A publisher that emits an array of  `PriceResponse.Item`s on success, or a `NetworkError` on failure.
    func priceSeries(
        of base: String,
        in quote: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[Price], NetworkError>

    /// Fetches the quoted price of the given base currencies, in the given quote currency, at the given time - batched.
    func prices(
        of pairs: [CurrencyPairAndTime]
    ) -> AnyPublisher<[String: [Price]], NetworkError>

    /// Fetches the quoted price of the given base currencies, in the given quote currency - batched.
    func prices(
        of pairs: [CurrencyPair]
    ) -> AnyPublisher<[String: Price], NetworkError>
}

final class PriceClient: PriceClientAPI {

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func symbols() -> AnyPublisher<CurrencySymbols, NetworkError> {
        let request: NetworkRequest! = PriceRequest.Symbols.request(
            requestBuilder: requestBuilder
        )
        return networkAdapter.perform(request: request)
    }

    func price(
        of bases: Set<String>,
        in quote: String,
        time: String?
    ) -> AnyPublisher<PriceResponse.IndexMulti.Response, NetworkError> {
        let request: NetworkRequest! = PriceRequest.IndexMulti.request(
            requestBuilder: requestBuilder,
            bases: bases,
            quote: quote,
            time: time
        )
        return networkAdapter.perform(request: request)
    }

    func prices(
        of pairs: [CurrencyPair]
    ) -> AnyPublisher<[String: Price], NetworkError> {
        if pairs.isEmpty { return .just([:]) }
        let request: NetworkRequest! = PriceRequest.IndexMulti.request(
            requestBuilder: requestBuilder,
            pairs: pairs
        )
        return networkAdapter.perform(request: request)
    }

    func prices(
        of pairs: [CurrencyPairAndTime]
    ) -> AnyPublisher<[String: [Price]], NetworkError> {
        if pairs.isEmpty { return .just([:]) }
        let request: NetworkRequest! = PriceRequest.IndexMultiSeries.request(
            requestBuilder: requestBuilder,
            pairs: pairs
        )
        return networkAdapter.perform(request: request)
    }

    func priceSeries(
        of base: String,
        in quote: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[Price], NetworkError> {
        let request: NetworkRequest! = PriceRequest.IndexSeries.request(
            requestBuilder: requestBuilder,
            base: base,
            quote: quote,
            start: start,
            scale: scale
        )
        return networkAdapter.perform(request: request)
    }
}

struct IndexMultiSeriesRequest {

    let body: [CurrencyPairAndTime]

    func request(on session: URLSession, logger: NetworkDebugLogger?) async throws -> [CurrencyPair: [Price]] { // TODO: NetworkKit
        if body.isEmpty { return [:] }
        var request = URLRequest(url: "https://api.blockchain.info/price/index-multi-series")
        request.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(String(date.timeIntervalSince1970.i))
        }
        do {
            request.httpBody = try body.data(using: encoder)
            let (data, response) = try await session.data(for: request)
            logger?.storeRequest(request, response: response, error: nil, data: data, metrics: nil, session: session)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try data.decode(to: [String: [Price]].self, using: decoder).mapKeys(CurrencyPair.init)
        } catch {
            logger?.storeRequest(request, response: nil, error: error, data: nil, metrics: nil, session: session)
            throw error
        }
    }
}

struct IndexMultiRequest {

    let body: [CurrencyPair]

    func request(on session: URLSession, logger: NetworkDebugLogger?) async throws -> [CurrencyPair: Price] { // TODO: NetworkKit
        if body.isEmpty { return [:] }
        var request = URLRequest(url: "https://api.blockchain.info/price/index-multi")
        request.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(String(date.timeIntervalSince1970.i))
        }
        do {
            request.httpBody = try body.map { ["base": $0.base.code, "quote": $0.quote.code] }.data(using: encoder)
            let (data, response) = try await session.data(for: request)
            logger?.storeRequest(request, response: response, error: nil, data: data, metrics: nil, session: session)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try data.decode(to: [String: Price].self, using: decoder).mapKeys(CurrencyPair.init)
        } catch {
            logger?.storeRequest(request, response: nil, error: error, data: nil, metrics: nil, session: session)
            throw error
        }
    }
}
