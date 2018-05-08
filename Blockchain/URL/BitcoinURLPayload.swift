//
//  BitcoinURLPayload.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Encapsulates the payload of a "bitcoin://" URL payload
struct BitcoinURLPayload {

    /// The bitcoin address
    let address: String?

    /// An optional amount in bitcoin
    let amount: String?
}

extension BitcoinURLPayload {
    init?(url: URL) {
        guard let scheme = url.scheme else {
            return nil
        }

        guard scheme == Constants.Schemes.bitcoin else {
            return nil
        }

        let queryArgs = url.queryArgs

        self.address = url.host ?? queryArgs["address"]
        self.amount = queryArgs["amount"]
    }
}
