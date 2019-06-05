//
//  EtherTransaction+Extensions.swift
//  Blockchain
//
//  Created by Jack on 29/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

import EthereumKit
import PlatformKit

extension EtherTransaction {
    enum TxType: String {
        case sent
        case received
        case transfer
        
        var platformDirection: PlatformKit.Direction {
            switch self {
            case .received:
                return .credit
            case .sent:
                return .debit
            case .transfer:
                return .transfer
            }
        }
    }
    
    convenience init(transaction: EthereumHistoricalTransaction?) {
        self.init()
        
        guard let transaction = transaction else { return }
        
        self.amount = transaction.amount
        self.amountTruncated = EtherTransaction.truncatedAmount(transaction.amount)
        let transactionFee = transaction.fee ?? CryptoValue.etherFromGwei(string: "0")
        self.fee = transactionFee?.toDisplayString(includeSymbol: false)
        self.from = transaction.fromAddress.publicKey
        self.to = transaction.toAddress.publicKey
        self.myHash = transaction.transactionHash
        self.note = transaction.memo
        self.txType = transaction.direction.txType.rawValue
        self.time = UInt64(transaction.createdAt.timeIntervalSince1970)
        self.confirmations = UInt(transaction.confirmations)
        self.fiatAmountsAtTime = [:]
    }
    
    public var transaction: EthereumHistoricalTransaction? {
        return EtherTransaction.mapToTransaction(self)
    }
    
    public static func mapToTransaction(_ legacyTransaction: EtherTransaction) -> EthereumHistoricalTransaction? {
        guard let from = legacyTransaction.from,
            let to = legacyTransaction.to,
            let amount = legacyTransaction.amount,
            let myHash = legacyTransaction.myHash,
            let txType = legacyTransaction.txType else {
                return nil
        }
        
        let fromAddress = EthereumAssetAddress(
            publicKey: from
        )
        
        let toAddress = EthereumAssetAddress(
            publicKey:  to
        )
        
        guard let direction = TxType(rawValue: txType)?.platformDirection,
            let f = legacyTransaction.fee else {
                return nil
        }
        
        // Convert from Ether to GWei
        let feeGwei: Int = NSDecimalNumber(string: f)
            .multiplying(
                byPowerOf10: 9,
                withBehavior: NSDecimalNumberHandler(
                    roundingMode: .bankers,
                    scale: 2,
                    raiseOnExactness: true,
                    raiseOnOverflow: true,
                    raiseOnUnderflow: true,
                    raiseOnDivideByZero: true
                )
            )
            .intValue
        
        return EthereumHistoricalTransaction(
            identifier: myHash,
            fromAddress: fromAddress,
            toAddress: toAddress,
            direction: direction,
            amount: amount,
            transactionHash: myHash,
            createdAt: Date(timeIntervalSince1970: TimeInterval(legacyTransaction.time)),
            fee: CryptoValue.etherFromGwei(string: "\(feeGwei)"),
            memo: legacyTransaction.note,
            confirmations: Int(legacyTransaction.confirmations)
        )
    }
}

extension EthereumHistoricalTransaction {
    var legacyTransaction: EtherTransaction? {
        return EtherTransaction(transaction: self)
    }
}

extension PlatformKit.Direction {
    var txType: EtherTransaction.TxType {
        switch self {
        case .credit:
            return .received
        case .debit:
            return .sent
        case .transfer:
            return .transfer
        }
    }
}
