// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyDomainKit
import NetworkKit
import ToolKit

// MARK: - PriceRequest

enum PriceRequest {
    enum IndexMulti {}
    enum IndexSeries {}
    enum Symbols {}
}

// MARK: - IndexSeries

extension PriceRequest.IndexSeries {

    struct Key: Hashable {

        let base: CryptoCurrency
        let quote: FiatCurrency
        let window: PriceWindow

        init(base: CryptoCurrency, quote: FiatCurrency, window: PriceWindow) {
            self.base = base
            self.quote = quote
            self.window = window
        }
    }

    static func request(
        requestBuilder: RequestBuilder,
        base: String,
        quote: String,
        start: String,
        scale: String
    ) -> NetworkRequest? {
        requestBuilder.get(
            path: "/price/index-series",
            parameters: [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "quote", value: quote),
                URLQueryItem(name: "start", value: start),
                URLQueryItem(name: "scale", value: scale)
            ]
        )
    }
}

// MARK: - IndexMulti

extension PriceRequest.IndexMulti {

    struct Key: Hashable {
        let base: Set<String>
        let quote: CurrencyType
        let time: PriceTime

        init(base: Set<String>, quote: CurrencyType, time: PriceTime) {
            self.base = base
            self.quote = quote
            self.time = time
        }
    }

    private struct Pair: Encodable {
        let base: String
        let quote: String
    }

    /// Aggregated call for multiple price quotes.
    /// - parameter base: Base fiat currency code. Must be supported in https://api.blockchain.info/price/symbols
    /// - parameter quote: Currencies to quote, fiat or crypto.
    /// - parameter time: The epoch seconds used to locate a time in the past.
    static func request(
        requestBuilder: RequestBuilder,
        bases: Set<String>,
        quote: String,
        time: String?
    ) -> NetworkRequest? {
        requestBuilder.post(
            path: "/price/index-multi",
            parameters: time.flatMap { [URLQueryItem(name: "time", value: $0)] },
            body: try? bases.map { Pair(base: $0, quote: quote) }.encode()
        )
    }
}

// MARK: - Symbols

extension PriceRequest.Symbols {

    struct Key: Hashable {}

    /// Aggregated call for multiple price quotes.
    /// - parameter base: Base fiat currency code. Must be supported in https://api.blockchain.info/price/symbols
    /// - parameter quote: Currencies to quote, fiat or crypto.
    /// - parameter time: The epoch seconds used to locate a time in the past.
    static func request(
        requestBuilder: RequestBuilder
    ) -> NetworkRequest? {
        requestBuilder.get(
            path: "/price/symbols"
        )
    }
}
