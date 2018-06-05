//
//  AssetURLPayloadFactory.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AssetURLPayloadFactory: NSObject {
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
