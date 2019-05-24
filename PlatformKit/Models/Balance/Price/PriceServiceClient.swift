//
//  PriceServiceClient.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol PriceServiceAPI {
    func fiatPrice(forCurrency cryptoCurrency: CryptoCurrency, fiatSymbol: String) -> Single<PriceInFiatValue>
    func fiatPrice(forCurrency cryptoCurrency: CryptoCurrency, fiatSymbol: String, timestamp: Date) -> Single<PriceInFiatValue>
}

/// Class for interacting with Blockchain's Service-Price backend service. This
/// service is in charge of all price related data (e.g. crypto to fiat prices, etc.)
/// Spec: https://api.blockchain.info/price/specs
public class PriceServiceClient: PriceServiceAPI {

    public typealias CryptoCurrencyToPrices = [CryptoCurrency: PriceInFiatValue]
    
    public init() { }
    
    public func fiatPrice(forCurrency cryptoCurrency: CryptoCurrency, fiatSymbol: String, timestamp: Date) -> Single<PriceInFiatValue> {
        return fetchFiatPrice(forCurrency: cryptoCurrency, fiatSymbol: fiatSymbol, timestamp: timestamp)
    }

    public func fiatPrice(forCurrency cryptoCurrency: CryptoCurrency, fiatSymbol: String) -> Single<PriceInFiatValue> {
        return fetchFiatPrice(forCurrency: cryptoCurrency, fiatSymbol: fiatSymbol)
    }
    
    private func fetchFiatPrice(forCurrency cryptoCurrency: CryptoCurrency, fiatSymbol: String, timestamp: Date? = nil) -> Single<PriceInFiatValue> {
        guard let baseUrl = URL(string: BlockchainAPI.shared.servicePriceUrl) else {
            return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        var parameters = ["base": cryptoCurrency.symbol, "quote": fiatSymbol]
        if let time = timestamp {
            parameters["time"] = "\(time.timeIntervalSince1970)"
        }
        guard let url = URL.endpoint(
            baseUrl,
            pathComponents: ["index"],
            queryParameters: parameters
            ) else {
                return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        return NetworkRequest.GET(url: url, type: PriceInFiat.self).map {
            $0.toPriceInFiatValue(currencyCode: fiatSymbol)
        }
    }

    /// Returns a Single that emits a mapping between an AssetType and it's price in fiat
    ///
    /// - Parameter fiatSymbol: the fiat to convert to
    /// - Returns: a Single emitting an AssetTypesToPrices
    public func allPrices(fiatSymbol: String) -> Single<CryptoCurrencyToPrices> {
        let fiatPrices: [Single<(CryptoCurrency, PriceInFiatValue)>] = CryptoCurrency.all.map { currency in
            return fiatPrice(
                forCurrency: currency,
                fiatSymbol: fiatSymbol
            ).catchError { error -> Single<PriceInFiatValue> in
                // If there's an error with the network call, just return "0" for the price
                Logger.shared.error("Failed to fetch fiat price for asset type \(currency.symbol). Error: \(error)")
                return Single.just(
                    PriceInFiat.empty.toPriceInFiatValue(currencyCode: fiatSymbol)
                )
            }.map { priceInFiat -> (CryptoCurrency, PriceInFiatValue) in
                return (currency, priceInFiat)
            }
        }
        return Single.zip(fiatPrices, { results -> CryptoCurrencyToPrices in
            var currencyToPrices: [CryptoCurrency: PriceInFiatValue] = [:]
            results.forEach { currency, priceInFiat in
                currencyToPrices[currency] = priceInFiat
            }
            return currencyToPrices
        })
    }
}
