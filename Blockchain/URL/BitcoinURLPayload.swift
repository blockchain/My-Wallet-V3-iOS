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

<<<<<<< Updated upstream
        let queryArgs = url.queryArgs

        let address = url.host ?? queryArgs["address"]
        let amount = queryArgs["amount"]

        self.init(address: address, amount: amount)
=======
        let urlString = url.absoluteString
        if urlString.contains("//") {
            let queryArgs = url.queryArgs

            self.address = url.host ?? queryArgs["address"]
            self.amount = queryArgs["amount"]
        } else if let commaIndex = urlString.index(of: ":") {
            // Handle web format (e.g. "bitcoin:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
            self.address = String(urlString[urlString.index(after: commaIndex)..<urlString.endIndex])
            self.amount = nil
        } else {
            self.address = nil
            self.amount = nil
        }
>>>>>>> Stashed changes
    }
}
