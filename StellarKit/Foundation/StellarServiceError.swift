//
//  StellarServiceError.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

public enum StellarServiceError: Error {
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

extension HorizonRequestError {
    func toStellarServiceError() -> StellarServiceError {
        switch self {
        case .notFound:
            return .noDefaultAccount
        case .rateLimitExceeded:
            return .rateLimitExceeded
        case .internalServerError:
            return .internalError
        case .parsingResponseFailed:
            return .parsingError
        case .forbidden:
            return .forbidden
        default:
            return .unknown
        }
    }
}
