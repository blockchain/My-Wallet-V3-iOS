// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public enum DIKitPriceContext: String {
    case volume
}

protocol PriceRepositoryAPI {

    func symbols() -> AnyPublisher<CurrencySymbols, NetworkError>

    /// Gets the quoted price of all given base `Currency` in the given quote `Currency`, at the given time.
    ///
    /// - parameter bases: Array of base currencies which prices will be fetched.
    /// - parameter quote: `Currency` in which to quote price in.
    /// - parameter time: `PriceTime` of the required price.
    /// - returns: Publisher emitting a map of currency pair and `PriceQuoteAtTime`.
    ///   The currency pair `String` key follow the format `"<base>-<quote>"` (eg `"BTC-USD"`)
    func prices(
        of bases: [Currency],
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<[String: PriceQuoteAtTime], NetworkError>

    /// Gets the historical price series of the given `CryptoCurrency`-`FiatCurrency` pair, within the given price window.
    ///
    /// - parameter base: Base currency which price will be fetched.
    /// - parameter quote: `Currency` in which to quote price in.
    /// - parameter window: `PriceWindow` of the required price.
    /// - returns: Publisher emitting a `HistoricalPriceSeries`.
    func priceSeries(
        of base: CryptoCurrency,
        in quote: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, NetworkError>

    /// Streams the quoted price of all supported currencies in the given quote `Currency`, at the given time.
    ///
    /// - parameter bases: Array of base currencies which prices will be fetched.
    /// - parameter quote: `Currency` in which to quote price in.
    /// - parameter time: `PriceTime` of the required price.
    /// - returns: Publisher emitting a map of currency pair and `PriceQuoteAtTime`.
    ///   The currency pair `String` key follow the format `"<base>-<quote>"` (eg `"BTC-USD"`)
    func stream(
        bases: [Currency],
        quote: Currency,
        at time: PriceTime,
        skipStale: Bool
    ) -> AnyPublisher<Result<[String: PriceQuoteAtTime], NetworkError>, Never>
}
