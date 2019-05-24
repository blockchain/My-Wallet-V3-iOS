//
//  TransactionDetailViewModel+ERC20Transaction.swift
//  Blockchain
//
//  Created by AlexM on 5/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import ERC20Kit

extension TransactionDetailViewModel {
    convenience init<Token: ERC20Token>(transaction: ERC20HistoricalTransaction<Token>) {
        self.init()
        
        assetType = .pax
        
        fromString = transaction.fromAddress.publicKey
        fromAddress = transaction.fromAddress.publicKey
        to = [transaction.toAddress.publicKey]
        toString = transaction.toAddress.publicKey
        
        hideNote = transaction.memo == nil
        note = transaction.memo
        txDescription = transaction.memo
        
        time = UInt64(transaction.createdAt.timeIntervalSince1970)
        
        if let fee = transaction.fee {
            feeString = fee.toDisplayString(includeSymbol: true)
        }
        
        amountString = transaction.cryptoAmount.toDisplayString(includeSymbol: true)
        decimalAmount = NSDecimalNumber(string: amountString)
        if let priceInFiat = transaction.historicalFiatValue {
            fiatAmountsAtTime = [BlockchainSettings.App.shared.fiatCurrencyCode.lowercased() : priceInFiat.toDisplayString(includeSymbol: false, locale: Locale.current)]
        }
        txType = transaction.direction == .credit ? Constants.TransactionTypes.receive : Constants.TransactionTypes.sent
        hasFromLabel = txType == Constants.TransactionTypes.sent
        hasToLabel = txType == Constants.TransactionTypes.receive
        myHash = transaction.transactionHash
        confirmed = true
        dateString = DateFormatter.verboseString(from: transaction.createdAt)
        detailButtonTitle = String(format: LocalizationConstants.Stellar.viewOnArgument, BlockchainAPI.Hosts.blockchainDotCom.rawValue).uppercased()
        detailButtonLink = BlockchainAPI.shared.transactionDetailURL(for: myHash, assetType: .pax)
    }
}
