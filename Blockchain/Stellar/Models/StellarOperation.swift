//
//  StellarTradeResponse.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum StellarOperation: Identifiable {
    
    var identifier: String {
        return token
    }
    
    func cellType() -> TransactionTableCell.Type {
        return TransactionTableCell.self
    }
    
    enum Direction {
        case credit
        case debit
    }
    
    case accountCreated(AccountCreated)
    case payment(Payment)
    case unknown
    
    struct AccountCreated {
        let identifier: String
        let funder: String
        let account: String
        let direction: Direction
        let balance: Decimal
        let token: String
        let sourceAccountID: String
        let transactionHash: String
        let createdAt: Date
        var fee: Int?
        var memo: String?
    }
    
    struct Payment {
        let token: String
        let identifier: String
        let fromAccount: String
        let toAccount: String
        let direction: Direction
        let amount: String
        let transactionHash: String
        let createdAt: Date
        var fee: Int?
        var memo: String?
    }
}

extension StellarOperation: Hashable {
    static func == (lhs: StellarOperation, rhs: StellarOperation) -> Bool {
        switch (lhs, rhs) {
        case (.payment(let lhsValue), .payment(let rhsValue)):
            return lhsValue.transactionHash == rhsValue.transactionHash &&
            lhsValue.memo == rhsValue.memo &&
            lhsValue.fee == rhsValue.fee
        case (.accountCreated(let lhsValue), .accountCreated(let rhsValue)):
            return lhsValue.transactionHash == rhsValue.transactionHash &&
                lhsValue.memo == rhsValue.memo &&
                lhsValue.fee == rhsValue.fee
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
    
    var hashValue: Int {
        switch self {
        case .accountCreated(let created):
            return created.account.hashValue ^
            created.balance.hashValue ^
            created.createdAt.hashValue ^
            created.direction.hashValue ^
            created.funder.hashValue ^
            created.identifier.hashValue ^
            created.transactionHash.hashValue
        case .payment(let payment):
            return payment.toAccount.hashValue ^
                payment.fromAccount.hashValue ^
                payment.createdAt.hashValue ^
                payment.direction.hashValue ^
                payment.amount.hashValue ^
                payment.identifier.hashValue ^
                payment.transactionHash.hashValue ^
                payment.token.hashValue
        case .unknown:
            return 0
        }
    }
}

extension StellarOperation {
    
    var transactionHash: String {
        switch self {
        case .accountCreated(let model):
            return model.transactionHash
        case .payment(let model):
            return model.transactionHash
        case .unknown:
            Logger.shared.error("Unknown Operation Type")
            return ""
        }
    }
    
    var token: String {
        switch self {
        case .accountCreated(let model):
            return model.token
        case .payment(let model):
            return model.token
        default:
            Logger.shared.error("Unknown Operation Type")
            return ""
        }
    }
    
}
