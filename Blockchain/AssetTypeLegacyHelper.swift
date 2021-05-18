//
//  AssetTypeLegacyHelper.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Helper to convert between CryptoCurrency <-> LegacyAssetType.
// To be deprecated once LegacyAssetType has been removed.
@objc class AssetTypeLegacyHelper: NSObject {

    @objc
    static func displayCode(for type: LegacyAssetType) -> String {
        CryptoCurrency(legacyAssetType: type).displayCode
    }
}
