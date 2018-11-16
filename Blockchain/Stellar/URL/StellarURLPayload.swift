//
//  StellarURLPayload.swift
//  Blockchain
//
//  Created by kevinwu on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

/// Encapsulates the payload of a "web+stellar:" URL payload
class StellarURLPayload: SEP7URI {

    static var scheme: String {
        return Constants.Schemes.stellar
    }

    static var payOperation: String {
        return "\(PayOperation)"
    }

    var schemeCompat: String {
        return StellarURLPayload.scheme
    }

    var absoluteString: String {
        let uriScheme = URIScheme()
        var amountInDecimal: Decimal?
        if let amount = amount {
            amountInDecimal = Decimal(string: amount)
        }
        return uriScheme.getPayOperationURI(accountID: address, amount: amountInDecimal)
    }

    var address: String

    var amount: String?

    required init(address: String, amount: String? = nil) {
        self.address = address
        self.amount = amount
    }
}
