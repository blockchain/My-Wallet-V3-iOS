//
//  BlockchainAPI+URLSuffix.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension BlockchainAPI {
    static func suffixURL(btcAddress: BitcoinAddress) -> String? {
        guard
            let address = btcAddress.address,
            let walletUrl = shared.walletUrl else {
            return nil
        }
        return String(format: "%@/address/%@?format=json", walletUrl, address)
    }

    static func suffixURL(bchAddress: BitcoinCashAddress) -> String? {
        guard
            let address = bchAddress.address,
            let apiUrl = shared.apiUrl else {
                return nil
        }
        return String(format: "/bch/multiaddr?active=%@", apiUrl, address)
    }
}
