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
        return AssetType(from: type)
    }

    @objc static func convert(toLegacy type: AssetType) -> LegacyAssetType {
        return type.legacy
    }

    @objc static func description(for type: AssetType) -> String {
        return type.description
    }

    @objc static func color(for type: LegacyAssetType) -> UIColor {
        return AssetType(from: type).brandColor
    }

    @objc static func symbol(for type: LegacyAssetType) -> String {
        return AssetType(from: type).symbol
    }
}
