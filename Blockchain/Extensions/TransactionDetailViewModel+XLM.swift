//
//  TransactionDetailViewModel+XLM.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

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

        amountString = xlmTransaction.amount
        decimalAmount = 0
        feeString = "feeString"

        txType = xlmTransaction.direction == .credit ? Constants.TransactionTypes.receive : Constants.TransactionTypes.sent
        hasFromLabel = txType == Constants.TransactionTypes.sent
        hasToLabel = txType == Constants.TransactionTypes.receive
        myHash = xlmTransaction.transactionHash
        confirmed = true
        dateString = DateFormatter.verboseString(from: xlmTransaction.createdAt)
        detailButtonTitle = String(format: LocalizationConstants.Stellar.viewOnArgument, BlockchainAPI.PartnerHosts.stellarchain.rawValue)
        detailButtonLink = BlockchainAPI.shared.stellarchainUrl
    }
}
