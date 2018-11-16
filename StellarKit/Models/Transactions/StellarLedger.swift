//
//  StellarLedger.swift
//  StellarKit
//
//  Created by AlexM on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// The `baseFeeInStroops` the network charges per operation in a transaction.
// This field is in stroops, which are 1/10,000,000th of a lumen.
// The `baseReserveInStroops` is what the network uses when
// calculating an account’s minimum balance.
public struct StellarLedger {
    public let identifier: String
    public let token: String
    public let sequence: Int
    public let transactionCount: Int
    public let operationCount: Int
    public let closedAt: Date
    public let totalCoins: String
    public let feePool: String
    public let baseFeeInStroops: Int?
    public let baseReserveInStroops: Int?
}

extension StellarLedger: Equatable {
    public static func == (lhs: StellarLedger, rhs: StellarLedger) -> Bool {
        return lhs.baseFeeInStroops == rhs.baseFeeInStroops &&
            lhs.baseReserveInStroops == rhs.baseReserveInStroops
    }
}

public extension StellarLedger {
    public var baseFeeInXlm: Decimal? {
        guard let feeInStroops = baseFeeInStroops else {
            return nil
        }
        return Decimal(feeInStroops) / Decimal(Int(1e7))
    }
    
    public var baseReserveInXlm: Decimal? {
        guard let reserveInStroops = baseReserveInStroops else {
            return nil
        }
        return Decimal(reserveInStroops) / Decimal(Int(1e7))
    }
}
