//
//  StellarOperation.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public enum StellarOperation: HistoricalTransaction, Tokenized {

    public typealias Address = StellarAssetAddress

    public var fee: CryptoValue? {
        switch self {
        case .accountCreated(let value):
            guard let fee = value.fee else { return nil }
            return CryptoValue.lumensFromStroops(int: fee)
        case .payment(let value):
            guard let fee = value.fee else { return nil }
            return CryptoValue.lumensFromStroops(int: fee)
        }
    }
    
    public var memo: String? {
        switch self {
        case .accountCreated(let value):
            return value.memo
        case .payment(let value):
            return value.memo
        }
    }
    
    public var identifier: String {
        switch self {
        case .accountCreated(let value):
            return value.identifier
        case .payment(let value):
            return value.identifier
        }
    }
    
    public var token: String {
        switch self {
        case .accountCreated(let value):
            return value.identifier
        case .payment(let value):
            return value.identifier
        }
    }
    
    public var fromAddress: Address {
        switch self {
        case .accountCreated(let value):
            return StellarAssetAddress(publicKey: value.funder)
        case .payment(let value):
            return StellarAssetAddress(publicKey: value.fromAccount)
        }
    }
    
    public var toAddress: Address {
        switch self {
        case .accountCreated(let value):
            return StellarAssetAddress(publicKey: value.account)
        case .payment(let value):
            return StellarAssetAddress(publicKey: value.toAccount)
        }
    }
    
    public var direction: Direction {
        switch self {
        case .accountCreated(let value):
            return value.direction
        case .payment(let value):
            return value.direction
        }
    }
    
    public var amount: String {
        switch self {
        case .accountCreated(let value):
            return String(describing: value.balance)
        case .payment(let value):
            return value.amount
        }
    }
    
    public var transactionHash: String {
        switch self {
        case .accountCreated(let value):
            return value.transactionHash
        case .payment(let value):
            return value.transactionHash
        }
    }
    
    public var createdAt: Date {
        switch self {
        case .accountCreated(let value):
            return value.createdAt
        case .payment(let value):
            return value.createdAt
        }
    }
    
    case accountCreated(AccountCreated)
    case payment(Payment)
    
    public struct AccountCreated {
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
    
    public struct Payment {
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
