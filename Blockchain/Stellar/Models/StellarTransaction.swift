//
//  StellarTransaction.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum StellarTransactionError: Int, Error {
    case failed = -1
    case tooEarly = -2
    case tooLate = -3
    case missingOperation = -4
    case badSequenceNumber = -5
    case badAuthentication = -6
    case insufficientBalance = -7
    case noAccount = -8
    case insufficientFee = -9
    case tooManySignatures = -10
    case internalError = -11
}

struct StellarTransactionResponse {
    
    enum Result {
        case success
        case error(StellarTransactionError)
    }
    
    let identifier: String
    let result: Result
    let transactionHash: String
    let createdAt: Date
    let sourceAccount: String
    let feePaid: Int
    let memo: String?
}
