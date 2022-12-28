// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BalanceResponse: Decodable {
    struct BalanceEntry: Decodable {
        struct Account: Decodable {
            let index: Int
            let name: String
        }

        struct CurrencyAmount: Decodable {
            let amount: String
            let precision: Int
        }

        let account: Account
        let amount: CurrencyAmount?
        let ticker: String
    }

    let currencies: [BalanceEntry]
}
