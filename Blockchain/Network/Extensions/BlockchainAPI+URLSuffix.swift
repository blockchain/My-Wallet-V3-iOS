//
//  BlockchainAPI+URLSuffix.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension BlockchainAPI {
    func suffixURL(address: AssetAddress) -> String? {
        guard let description = address.description else { return nil }
        switch address.assetType {
        case .bitcoin:
            guard let url = walletUrl else { return nil }
            return String(format: "%@/address/%@?format=json", url, description)
        case .bitcoinCash:
            guard let url = apiUrl else { return nil }
            return String(format: "%@/bch/multiaddr?active=%@", url, description)
        default:
            return nil
        }
    }
}
