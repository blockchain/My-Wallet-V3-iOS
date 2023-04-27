// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

/// A client that interacts with `Service-Price` in order to fetch all price related data (quoted prices and historical price series from crypto to fiat).
/// Read the [API Spec](https://api.blockchain.com/price/specs) for more information.
protocol PriceClientAPI {

    /// Fetches collection of supported symbols.
    func symbols() -> AnyPublisher<PriceResponse.Symbols.Response, NetworkError>

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
    ) -> AnyPublisher<[PriceResponse.Item], NetworkError>
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

    func symbols() -> AnyPublisher<PriceResponse.Symbols.Response, NetworkError> {
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

    func priceSeries(
        of base: String,
        in quote: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[PriceResponse.Item], NetworkError> {
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
