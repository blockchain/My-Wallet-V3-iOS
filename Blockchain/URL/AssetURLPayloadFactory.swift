//
//  AssetURLPayloadFactory.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AssetURLPayloadFactory: NSObject {

    @objc static func create(fromString string: String, legacyAssetType: LegacyAssetType) -> AssetURLPayload? {
        if string.contains(":") {
            guard let url = URL(string: string) else {
                print("Could not create payload from URL \(string)")
                return nil
            }
            return create(from: url)
        } else {
            switch legacyAssetType {
            case .bitcoin:
                return BitcoinURLPayload(address: string, amount: nil)
            case .bitcoinCash:
                return BitcoinCashURLPayload(address: string, amount: nil)
            default:
                return nil
            }
        }
    }

    @objc static func create(from url: URL) -> AssetURLPayload? {
        guard let scheme = url.scheme else {
            print("Cannot create AssetURLPayload. Scheme is nil.")
            return nil
        }

        switch scheme {
        case BitcoinURLPayload.scheme:
            return BitcoinURLPayload(url: url)
        case BitcoinCashURLPayload.scheme:
            return BitcoinCashURLPayload(url: url)
        default:
            return nil
        }
    }
}
