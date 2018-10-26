//
//  PriceServiceClient.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol PriceServiceAPI {
    func fiatPrice(forAssetType assetType: AssetType, fiatSymbol: String) -> Single<PriceInFiat>
}

/// Class for interacting with Blockchain's Service-Price backend service. This
/// service is in charge of all price related data (e.g. crypto to fiat prices, etc.)
/// Spec: https://api.blockchain.info/price/specs
class PriceServiceClient: PriceServiceAPI {

    typealias AssetTypesToPrices = [AssetType: PriceInFiat]

    func fiatPrice(forAssetType assetType: AssetType, fiatSymbol: String) -> Single<PriceInFiat> {
        guard let baseUrl = URL(string: BlockchainAPI.shared.servicePriceUrl) else {
            return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        guard let url = URL.endpoint(
            baseUrl,
            pathComponents: ["index"],
            queryParameters: ["base": assetType.symbol, "quote": fiatSymbol]
        ) else {
            return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        return NetworkRequest.GET(url: url, type: PriceInFiat.self)
    }

    /// Returns a Single that emits a mapping between an AssetType and it's price in fiat
    ///
    /// - Parameter fiatSymbol: the fiat to convert to
    /// - Returns: a Single emitting an AssetTypesToPrices
    func allPrices(fiatSymbol: String) -> Single<AssetTypesToPrices> {
        let fiatPrices: [Single<(AssetType, PriceInFiat)>] = AssetType.all.map { assetType in
            return fiatPrice(
                forAssetType: assetType,
                fiatSymbol: fiatSymbol
            ).catchError { error -> Single<PriceInFiat> in
                // If there's an error with the network call, just return "0" for the price
                Logger.shared.error("Failed to fetch fiat price for asset type \(assetType.symbol). Error: \(error)")
                return Single.just(PriceInFiat.empty)
            }.map { priceInFiat -> (AssetType, PriceInFiat) in
                return (assetType, priceInFiat)
            }
        }
        return Single.zip(fiatPrices, { results -> AssetTypesToPrices in
            var assetTypesToPrices: [AssetType: PriceInFiat] = [:]
            results.forEach { assetType, priceInFiat in
                assetTypesToPrices[assetType] = priceInFiat
            }
            return assetTypesToPrices
        })
    }
}
