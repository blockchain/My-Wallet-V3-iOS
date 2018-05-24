//
//  BitcoinURLPayload.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Encapsulates the payload of a "bitcoin://" URL payload
@objc class BitcoinURLPayload: NSObject {

    /// The bitcoin address
    @objc let address: String?

    /// An optional amount in bitcoin
    @objc let amount: String?

    @objc init(address: String?, amount: String?) {
        self.address = address
        self.amount = amount
    }
}

extension BitcoinURLPayload {
    @objc convenience init?(url: URL) {
        guard let scheme = url.scheme else {
            return nil
        }

        guard scheme == Constants.Schemes.bitcoin else {
            return nil
        }

        let address: String?
        let amount: String?
        let urlString = url.absoluteString
        
        if urlString.contains("//") {
            let queryArgs = url.queryArgs

            address = url.host ?? queryArgs["address"]
            amount = queryArgs["amount"]
        } else if let commaIndex = urlString.index(of: ":") {
            // Handle web format (e.g. "bitcoin:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
            address = String(urlString[urlString.index(after: commaIndex)..<urlString.endIndex])
            amount = nil
        } else {
            address = nil
            amount = nil
        }

        self.init(address: address, amount: amount)
    }
}
