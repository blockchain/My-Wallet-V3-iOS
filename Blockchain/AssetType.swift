//
//  AssetType.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The asset type is used to distinguish between different types of digital assets.
@objc public enum AssetType: Int {
    case bitcoin, bitcoinCash, ethereum
}

extension AssetType {
    static func from(legacyAssetType: LegacyAssetType) -> AssetType {
        switch legacyAssetType {
        case .bitcoin:
            return AssetType.bitcoin
        case .bitcoinCash:
            return AssetType.bitcoinCash
        case .ether:
            return AssetType.ethereum
        }
    }

    init(stringValue: String) {
        switch stringValue {
        case "BTC":
            self = .bitcoin
        case "BCH":
            self = .bitcoinCash
        case "ETH":
            self = .ethereum
        default:
            assertionFailure("\(stringValue) is not a supported type")
            self = .bitcoin
        }
    }

    var legacy: LegacyAssetType {
        switch self {
        case .bitcoin:
            return LegacyAssetType.bitcoin
        case .bitcoinCash:
            return LegacyAssetType.bitcoinCash
        case .ethereum:
            return LegacyAssetType.ether
        }
    }
}

extension AssetType {
    var description: String {
        switch self {
        case .bitcoin:
            return "Bitcoin"
        case .bitcoinCash:
            return "Bitcoin Cash"
        case .ethereum:
            return "Ether"
        }
    }

    var symbol: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .bitcoinCash:
            return "BCH"
        case .ethereum:
            return "ETH"
        }
    }
}
