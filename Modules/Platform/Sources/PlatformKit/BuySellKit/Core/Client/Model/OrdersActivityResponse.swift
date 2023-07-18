// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct OrdersActivityResponse: Decodable, Equatable {
    struct Item: Decodable, Equatable {
        struct ExtraAttributes: Decodable, Equatable {
            struct Beneficiary: Decodable, Equatable {
                let accountRef: String?
            }

            let beneficiary: Beneficiary?
        }

        struct Amount: Decodable, Equatable {
            let symbol: String
        }

        let id: String
        let amount: Amount
        let amountMinor: String
        let feeMinor: String?
        let insertedAt: String
        let type: String
        let state: String
        let extraAttributes: ExtraAttributes?
        let txHash: String?
        let error: String?
    }

    let items: [Item]
}

extension OrdersActivityResponse.Item {

    /// Helper that maps `OrdersActivityResponse.Item.insertedAt`property into a `Date`.
    var insertedAtDate: Date {
        let date = DateFormatter.sessionDateFormat.date(from: insertedAt)
            ?? DateFormatter.sessionDateFormatWithoutMilliseconds.date(from: insertedAt)
            ?? DateFormatter.iso8601Format.date(from: insertedAt)
        guard let date else { assertionFailure("Could not parse date from activity \(insertedAt)"); return Date() }
        return date
    }
}
