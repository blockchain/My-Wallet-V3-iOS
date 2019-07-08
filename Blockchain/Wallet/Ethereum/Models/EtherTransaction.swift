//
//  EtherTransaction.swift
//  Blockchain
//
//  Created by Jack on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc public class EtherTransaction: NSObject, TransactionProtocol {
    
    private enum Keys: String {
        case amount
        case fee
        case from
        case to
        case time
        case txType
        case hash
        case confirmations
        case note
    }
    
    @objc public var amount: String?
    @objc public var amountTruncated: String?
    @objc public var fee: String?
    @objc public var from: String?
    @objc public var to: String?
    @objc public var myHash: String?
    @objc public var note: String?
    @objc public var txType: String?
    @objc public var time: UInt64
    @objc public var confirmations: UInt
    @objc public var fiatAmountsAtTime: NSMutableDictionary?
    
    @objc public override init() {
        self.time = 0
        self.confirmations = 0
        self.fiatAmountsAtTime = NSMutableDictionary()
        super.init()
    }
    
    @objc public class func fromJSON(dict: [String: AnyObject]) -> EtherTransaction {
        let transaction = EtherTransaction()
        
        if let amountDecimal = dict[Keys.amount.rawValue] as? NSNumber {
            let amount = amountDecimal.stringValue
            transaction.amount = amount
            transaction.amountTruncated = truncated(amount: amount)
        }
        
        if let fee = dict[Keys.fee.rawValue] as? String {
            transaction.fee = fee
        }
        
        if let from = dict[Keys.from.rawValue] as? String {
            transaction.from = from
        }
        
        if let to = dict[Keys.to.rawValue] as? String {
            transaction.to = to
        }
        
        if let myHash = dict[Keys.hash.rawValue] as? String {
            transaction.myHash = myHash
        }
        
        if let note = dict[Keys.note.rawValue] as? String {
            transaction.note = note
        }
        
        if let txType = dict[Keys.txType.rawValue] as? String {
            transaction.txType = txType
        }
        
        if let time = dict[Keys.time.rawValue] as? UInt64 {
            transaction.time = time
        }
        
        if let confirmations = dict[Keys.confirmations.rawValue] as? UInt {
            transaction.confirmations = confirmations
        }
        
        return transaction
    }
    
    @objc public class func truncated(amount amountString: String) -> String? {
        let number = NSDecimalNumber(string: amountString)
        let formatter = NumberFormatter.sharedEthereumTruncatedAmountFormatter
        return formatter.string(from: number)
    }
}

extension NumberFormatter {
    fileprivate static let sharedEthereumTruncatedAmountFormatter = NumberFormatter.ethereumTruncatedAmountFormatter()
    
    private class func ethereumTruncatedAmountFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.numberStyle = .decimal
        return formatter
    }
}
