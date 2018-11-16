//
//  SEP7URI.swift
//  Blockchain
//
//  Created by kevinwu on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

/// A URI scheme that conforms to SEP 0007 (https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0007.md)
protocol SEP7URI: AssetURLPayload {
    init(address: String, amount: String?)

    init?(url: URL)
}

extension SEP7URI {
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

        if let argsString = urlString.components(separatedBy: "\(Self.scheme):\(PayOperation)").last {
            let queryArgs = argsString.queryArgs
            address = queryArgs["\(PayOperationParams.destination)"]
            amount = queryArgs["\(PayOperationParams.amount)"]
        } else {
            address = urlString
            amount = nil
        }

        guard address != nil else {
            return nil
        }

        self.init(address: address!, amount: amount)
    }
}
