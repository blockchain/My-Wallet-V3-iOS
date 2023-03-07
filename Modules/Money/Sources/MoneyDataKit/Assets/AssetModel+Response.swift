// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyDomainKit

extension AssetModel {

    /// Creates an AssetModel asset.
    ///
    /// - Parameters:
    ///   - assetResponse: A supported AssetsResponse.Asset object.
    ///   - sortIndex:     A sorting index.
    init?(assetResponse: AssetsResponse.Asset, sortIndex: Int, sanitizeEVMAssets: Bool) {
        let code = assetResponse.symbol
        let displayCode = assetResponse.displaySymbol ?? assetResponse.symbol
        let name = Self.name(assetResponse, sanitizeEVMAssets: sanitizeEVMAssets)
        let precision = assetResponse.precision
        let logoPngUrl = assetResponse.type.logoPngUrl.flatMap(URL.init)
        let spotColor = assetResponse.type.spotColor

        guard let assetModelType = assetResponse.type.assetModelType else {
            return nil
        }
        let sortIndex = assetModelType.baseSortIndex + sortIndex

        var products = assetResponse.products.compactMap(AssetModelProduct.init)
        if assetModelType.isCoin, ERC20ParentChainName.allCases.map(\.nativeAsset).contains(code) {
            products.append(.privateKey)
        }

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

    /// Used only for name sanitizing while UI is not ready.
    private enum ERC20ParentChainName: String, CaseIterable {
        case avax = "AVAX"
        case bnb = "BNB"
        case ethereum = "ETH"
        case polygon = "MATIC"

        var name: String {
            switch self {
            case .avax:
                return "Avalanche"
            case .bnb:
                return "BSC"
            case .ethereum:
                return "Ethereum"
            case .polygon:
                return "Polygon"
            }
        }

        var nativeAsset: String {
            switch self {
            case .avax:
                return "AVAX"
            case .bnb:
                return "BNB"
            case .ethereum:
                return "ETH"
            case .polygon:
                return "MATIC.MATIC"
            }
        }
    }

    static func name(
        _ response: AssetsResponse.Asset,
        sanitizeEVMAssets: Bool
    ) -> String {
        let name = response.name
        guard sanitizeEVMAssets else {
            return name
        }
        guard response.type.name == AssetsResponse.Asset.AssetType.Name.erc20.rawValue else {
            return name
        }
        guard let network = response.type.parentChain.flatMap(ERC20ParentChainName.init(rawValue:)) else {
            return name
        }
        guard network != .ethereum, network != .polygon else {
            return name
        }
        let evmAssetNameSuffix = " - \(network.name)"
        guard !name.hasSuffix(evmAssetNameSuffix) else {
            return name
        }
        return name + evmAssetNameSuffix
    }
}

extension AssetsResponse.Asset.AssetType {
    fileprivate var assetModelType: AssetModelType? {
        switch name {
        case Self.Name.fiat.rawValue:
            return .fiat
        case Self.Name.celoToken.rawValue:
            return .celoToken(parentChain: .celo)
        case Self.Name.coin.rawValue:
            return .coin(
                minimumOnChainConfirmations: minimumOnChainConfirmations ?? 0
            )
        case Self.Name.erc20.rawValue:
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
        default:
            return nil
        }
    }
}

extension AssetModelType {
    fileprivate var baseSortIndex: Int {
        switch self {
        case .celoToken:
            return 100
        case .coin:
            return 10
        case .erc20:
            return 10000
        case .fiat:
            return 0
        }
    }
}
