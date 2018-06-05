//
//  BitcoinCashURLPayload.swift
//  Blockchain
//
//  Created by kevinwu on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Encapsulates the payload of a "bitcoincash:" URL payload
@objc class BitcoinCashURLPayload: NSObject, BIP21URI {

    static var scheme: String {
        return Constants.Schemes.bitcoinCash
    }

    @objc var address: String

    @objc var amount: String?

    @objc required init(address: String, amount: String?) {
        self.address = address
        self.amount = amount
    }
}
