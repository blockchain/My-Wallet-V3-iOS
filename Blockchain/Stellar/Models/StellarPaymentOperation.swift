//
//  StellarPaymentOperation.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum StellarPaymentOperationError: Int, Error  {
    case keyMisMatch
}

struct StellarPaymentOperation {
    let destinationAccountId: String
    let amountInXlm: Decimal
    let sourceAccount: WalletXlmAccount
    let feeInXlm: Decimal
}
