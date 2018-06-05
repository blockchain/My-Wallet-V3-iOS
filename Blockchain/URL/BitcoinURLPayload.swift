//
//  BitcoinURLPayload.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Encapsulates the payload of a "bitcoin:" URL payload
@objc class BitcoinURLPayload: NSObject, BIP21URI {

    static var scheme: String {
        return Constants.Schemes.bitcoin
    }

    @objc var address: String

    @objc var amount: String?

    @objc required init(address: String, amount: String?) {
        self.address = address
        self.amount = amount
    }
}
