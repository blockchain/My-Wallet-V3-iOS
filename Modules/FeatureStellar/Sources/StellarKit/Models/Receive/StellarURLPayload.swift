// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import stellarsdk

struct SEP7URI {

    private static let scheme: String = "web+stellar"

    let cryptoCurrency: CryptoCurrency = .stellar
    let address: String
    let amount: CryptoValue?
    let memo: String?

    var absoluteString: String {
        URIScheme().getPayOperationURI(
            destination: address,
            amount: amount?.displayMajorValue,
            memo: memo
        )
    }

    init(address: String, amount: String?, memo: String?) {
        self.address = address
        self.amount = amount.flatMap { .create(major: $0, currency: .stellar) }
        self.memo = memo
    }

    init?(url: URL) {
        // Scheme must 'be web+stellar'
        guard Self.scheme == url.scheme else {
            return nil
        }

        // Get query arguments after "web+stellar:pay?". We do not support actions other than 'pay'.
        guard let arguments = url.absoluteString.components(separatedBy: "\(Self.scheme):\(PayOperation)").last else {
            return nil
        }
        let queryArguments = arguments.queryArgs
        // We must have an destination
        guard let destination = queryArguments["\(PayOperationParams.destination)"] else {
            return nil
        }

        // Optionally retrieve payment amount.
        let amount: String? = queryArguments["\(PayOperationParams.amount)"]

        // Optionally retrieve memo if memo type is text.
        var memo: String?
        let memoType: String? = queryArguments["\(PayOperationParams.memo_type)"]
        if memoType == nil || memoType == "MEMO_TEXT" {
            memo = queryArguments["\(PayOperationParams.memo)"]
        }

        self.init(address: destination, amount: amount, memo: memo)
    }
}
