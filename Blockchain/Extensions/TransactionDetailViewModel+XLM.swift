//
//  TransactionDetailViewModel+XLM.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

// If TransactionDetailViewModel is converted to Swift, it should implement
// methods like the ones in this file to allow configuration with Swift classes/structs
extension TransactionDetailViewModel {
    convenience init(xlmTransaction: StellarOperation.Payment) {
        self.init()

        assetType = .stellar

        fromString = xlmTransaction.fromAccount
        fromAddress = xlmTransaction.fromAccount
        to = [xlmTransaction.toAccount]
        toString = xlmTransaction.toAccount
        
        hideNote = xlmTransaction.memo == nil
        note = xlmTransaction.memo
        txDescription = xlmTransaction.memo
        
        time = UInt64(xlmTransaction.createdAt.timeIntervalSince1970)

        if let fee = xlmTransaction.fee,
            let amount = Decimal(string: xlmTransaction.amount),
            let feeInWholeUnit = NumberFormatter.integerToWholeUnit(amount: fee, assetType: AssetType.from(legacyAssetType: assetType)) {
            feeString = String(describing: feeInWholeUnit).appendAssetSymbol(for: AssetTypeLegacyHelper.convert(fromLegacy: assetType))

            // Fee is not fetched until tapping on a transaction cell because the SDK only provides a method
            // for fetching the fee for a single transaction. In the meantime we are hardcoding it for outgoing transactions.
            let displayAmount = xlmTransaction.direction == .credit ? amount : amount + feeInWholeUnit
            amountString = "\(displayAmount)".appendAssetSymbol(for: AssetTypeLegacyHelper.convert(fromLegacy: assetType))
        } else {
            amountString = "\(xlmTransaction.amount)".appendAssetSymbol(for: AssetTypeLegacyHelper.convert(fromLegacy: assetType))
        }

        decimalAmount = NSDecimalNumber(string: amountString)

        txType = xlmTransaction.direction == .credit ? Constants.TransactionTypes.receive : Constants.TransactionTypes.sent
        hasFromLabel = txType == Constants.TransactionTypes.sent
        hasToLabel = txType == Constants.TransactionTypes.receive
        myHash = xlmTransaction.transactionHash
        confirmed = true
        dateString = DateFormatter.verboseString(from: xlmTransaction.createdAt)
        detailButtonTitle = String(format: LocalizationConstants.Stellar.viewOnArgument, BlockchainAPI.PartnerHosts.stellarchain.rawValue).uppercased()
        guard let base = URL(string: BlockchainAPI.shared.stellarchainUrl) else { return }
        let stellarURL = URL.endpoint(
            base,
            pathComponents: ["tx", xlmTransaction.transactionHash],
            queryParameters: nil
        )
        detailButtonLink = stellarURL?.absoluteString
    }
    
    convenience init(xlmTransaction: StellarOperation.AccountCreated) {
        self.init()
        
        assetType = .stellar
        
        hideNote = xlmTransaction.memo == nil
        note = xlmTransaction.memo
        txDescription = xlmTransaction.memo
        
        fromString = xlmTransaction.funder
        fromAddress = xlmTransaction.funder
        to = [xlmTransaction.account]
        toString = xlmTransaction.account
        
        txDescription = xlmTransaction.memo
        
        time = UInt64(xlmTransaction.createdAt.timeIntervalSince1970)
        
        amountString = String(describing: xlmTransaction.balance)
        decimalAmount = xlmTransaction.balance as NSDecimalNumber
        
        if let fee = xlmTransaction.fee,
            let feeInWholeUnit = NumberFormatter.integerToWholeUnit(amount: fee, assetType: AssetType.from(legacyAssetType: assetType)) {
            feeString = String(describing: feeInWholeUnit).appendAssetSymbol(for: AssetTypeLegacyHelper.convert(fromLegacy: assetType))

            // Fee is not fetched until tapping on a transaction cell because the SDK only provides a method
            // for fetching the fee for a single transaction. In the meantime we are hardcoding it for outgoing transactions.
            let displayAmount = xlmTransaction.direction == .credit ? xlmTransaction.balance : xlmTransaction.balance + feeInWholeUnit
            amountString = "\(displayAmount)".appendAssetSymbol(for: AssetTypeLegacyHelper.convert(fromLegacy: assetType))
        } else {
            amountString = "\(xlmTransaction.balance)".appendAssetSymbol(for: AssetTypeLegacyHelper.convert(fromLegacy: assetType))
        }

        decimalAmount = NSDecimalNumber(string: amountString)
        
        txType = xlmTransaction.direction == .credit ? Constants.TransactionTypes.receive : Constants.TransactionTypes.sent
        hasFromLabel = txType == Constants.TransactionTypes.sent
        hasToLabel = txType == Constants.TransactionTypes.receive
        myHash = xlmTransaction.transactionHash
        confirmed = true
        dateString = DateFormatter.verboseString(from: xlmTransaction.createdAt)
        detailButtonTitle = String(format: LocalizationConstants.Stellar.viewOnArgument, BlockchainAPI.PartnerHosts.stellarchain.rawValue).uppercased()
        guard let base = URL(string: BlockchainAPI.shared.stellarchainUrl) else { return }
        let stellarURL = URL.endpoint(
            base,
            pathComponents: ["tx", xlmTransaction.transactionHash],
            queryParameters: nil
        )
        detailButtonLink = stellarURL?.absoluteString
    }
}
