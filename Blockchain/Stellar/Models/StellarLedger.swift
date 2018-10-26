//
//  StellarLedger.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// The `baseFeeInStroops` the network charges per operation in a transaction.
// This field is in stroops, which are 1/10,000,000th of a lumen.
// The `baseReserveInStroops` is what the network uses when
// calculating an account’s minimum balance.
struct StellarLedger {
    let identifier: String
    let token: String
    let sequence: Int
    let transactionCount: Int
    let operationCount: Int
    let closedAt: Date
    let totalCoins: String
    let feePool: String
    let baseFeeInStroops: Int?
    let baseReserveInStroops: Int?
}

extension StellarLedger: Equatable {
    static func == (lhs: StellarLedger, rhs: StellarLedger) -> Bool {
        return lhs.baseFeeInStroops == rhs.baseFeeInStroops &&
        lhs.baseReserveInStroops == rhs.baseReserveInStroops
    }
}
