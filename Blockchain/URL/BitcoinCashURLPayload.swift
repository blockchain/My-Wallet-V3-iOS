//
//  BitcoinCashURLPayload.swift
//  Blockchain
//
//  Created by kevinwu on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Encapsulates the payload of a "bitcoincash://" URL payload
@objc class BitcoinCashURLPayload: NSObject {

    /// The bitcoin cash address
    @objc let address: String?

    @objc init(address: String?) {
        self.address = address
    }
}

extension BitcoinCashURLPayload {
    @objc convenience init?(url: URL) {
        guard let scheme = url.scheme else {
            return nil
        }

        guard scheme == Constants.Schemes.bitcoinCash else {
            return nil
        }

        let urlString = url.absoluteString
        let address: String?

        if let commaIndex = urlString.index(of: ":") {
            // Handle web format (e.g. "bitcoincash:qp3gpp53evw2gv7am7pj3nhaeujgpmx68q53amwrnt")
            address = String(urlString[urlString.index(after: commaIndex)..<urlString.endIndex])
        } else {
            address = nil
        }

        self.init(address: address)
    }
}
