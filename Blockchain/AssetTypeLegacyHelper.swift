//
//  AssetTypeLegacyHelper.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Helper to convert between AssetType <-> LegacyAssetType.
// To be deprecated once LegacyAssetType has been removed.
@objc class AssetTypeLegacyHelper: NSObject {
    @objc static func convert(fromLegacy type: LegacyAssetType) -> AssetType {
        switch type {
        case .bitcoin:
            return .bitcoin
        case .ether:
            return .ethereum
        case .bitcoinCash:
            return .bitcoinCash
        }
    }

    @objc static func convert(toLegacy type: AssetType) -> LegacyAssetType {
        switch type {
        case .bitcoin:
            return .bitcoin
        case .ethereum:
            return .ether
        case .bitcoinCash:
            return .bitcoinCash
        }
    }

    @objc static func description(for type: AssetType) -> String {
        return type.description
    }
}
