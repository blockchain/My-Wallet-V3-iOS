//
//  BlockchainAPI+URLSuffix.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: implement ethereum case

extension BlockchainAPI {
    func suffixURL(address: AssetAddress) -> String? {
        switch address.assetType {
        case .bitcoin:
            return "\(walletUrl)/address/\(address)?format=json"
        case .bitcoinCash:
            return "\(walletUrl)/bch/multiaddr?active=\(address)"
        default:
            return nil
        }
    }
}
