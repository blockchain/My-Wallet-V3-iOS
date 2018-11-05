//
//  StellarServiceError.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum StellarServiceError: Error {
    case insufficientFundsForNewAccount
    case noDefaultAccount
    case noXLMAccount
    case rateLimitExceeded
    case internalError
    case parsingError
    case unauthorized
    case forbidden
    case amountTooLow
    case unknown
}
