// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BalanceResponse: Decodable {
    struct BalanceEntry: Decodable {
        struct Account: Decodable {
            let index: Int
            let name: String?
        }

        struct CurrencyAmount: Decodable {
            let amount: String
        }

        let price: Double?
        let account: Account
        let amount: CurrencyAmount?
        let ticker: String
    }

    struct NetworkEntry: Decodable {
        let ticker: String
        let errorLoadingBalances: Bool
    }

    let currencies: [BalanceEntry]
    let networks: [NetworkEntry]
}
