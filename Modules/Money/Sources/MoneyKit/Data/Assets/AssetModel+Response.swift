// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension AssetModel {

    /// Creates an AssetModel asset.
    ///
    /// - Parameters:
    ///   - assetResponse: A supported AssetsResponse.Asset object.
    ///   - sortIndex:     A sorting index.
    init?(assetResponse: AssetsResponse.Asset, sortIndex: Int) {
        let code = assetResponse.symbol
        let displayCode = assetResponse.displaySymbol ?? assetResponse.symbol
        let name = assetResponse.name
        let precision = assetResponse.precision
        let logoPngUrl = assetResponse.type.logoPngUrl.flatMap(URL.init)
        let spotColor = assetResponse.type.spotColor

        guard let assetModelType = assetResponse.type.assetModelType else {
            return nil
        }
        let sortIndex = assetModelType.baseSortIndex + sortIndex
        let products = assetResponse.products.compactMap(AssetModelProduct.init)

        self.init(
            code: code,
            displayCode: displayCode,
            kind: assetModelType,
            name: name,
            precision: precision,
            products: products.unique,
            logoPngUrl: logoPngUrl,
            spotColor: spotColor,
            sortIndex: sortIndex
        )
    }
}

extension AssetsResponse.Asset.AssetType {
    fileprivate var assetModelType: AssetModelType? {
        switch Name(rawValue: name) {
        case .fiat:
            return .fiat
        case .celoToken:
            return .celoToken(parentChain: .celo)
        case .coin:
            let confirmations = minimumOnChainConfirmations ?? 0
            return .coin(minimumOnChainConfirmations: confirmations)
        case .erc20:
            guard let erc20Address else {
                return nil
            }
            guard let parentChain else {
                return nil
            }
            return .erc20(
                contractAddress: erc20Address,
                parentChain: parentChain
            )
        case nil:
            return nil
        }
    }
}

extension AssetModelType {
    fileprivate var baseSortIndex: Int {
        switch self {
        case .fiat:
            return 0
        case .coin:
            return 10000
        case .celoToken:
            return 20000
        case .erc20:
            return 30000
        }
    }
}
