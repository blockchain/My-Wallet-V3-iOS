//
//  BIP21URI.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A URI scheme that conforms to BIP 21 (https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki)
protocol BIP21URI: AssetURLPayload {

    /// An optional amount attached to the URI
    var amount: String? { get }

    init(address: String, amount: String?)

    init?(url: URL)
}

extension BIP21URI {
    init?(url: URL) {
        guard let urlScheme = url.scheme else {
            return nil
        }

        guard urlScheme == Self.scheme else {
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
            // Handle web format (e.g. "scheme:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
            address = String(urlString[urlString.index(after: commaIndex)..<urlString.endIndex])
            amount = nil
        } else {
            address = nil
            amount = nil
        }

        guard address != nil else {
            return nil
        }

        self.init(address: address!, amount: amount)
    }
}
