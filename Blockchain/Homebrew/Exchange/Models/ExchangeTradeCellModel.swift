//
//  ExchangeTradeCellModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ExchangeTradeCellModel {

    enum TradeStatus: String {
        case noDeposits = "no_deposits"
        case received = "received"
        case complete = "complete"
        case resolved = "resolved"
        case inProgress = "IN_PROGRESS"
        case cancelled = "CANCELLED"
        case failed = "failed"
        case expired = "EXPIRED"
    }

    let status: TradeStatus
    let transactionDate: Date
    let displayValue: String

    init(with trade: ExchangeTrade) {
        status = TradeStatus(rawValue: trade.status) ?? .failed
        transactionDate = trade.date
        displayValue = trade.displayAmount() ?? ""
    }
}

extension ExchangeTradeCellModel {
    var formattedDate: String {
        return DateFormatter.timeAgoString(from: transactionDate)
    }
}

extension ExchangeTradeCellModel.TradeStatus {
    
    var tintColor: UIColor {
        switch self {
        case .complete:
            return .green
        case .noDeposits,
             .received,
             .inProgress:
            return .grayBlue
        case .cancelled,
             .failed,
             .expired,
             .resolved:
            return .red
        }
    }

    var displayValue: String {
        switch self {
        case .complete:
            return NSLocalizedString("Complete", comment: "").uppercased()
        case .noDeposits,
             .received,
             .inProgress:
            return NSLocalizedString("In Progress", comment: "").uppercased()
        case .cancelled,
             .failed,
             .expired,
             .resolved:
            return NSLocalizedString("Trade Refunded", comment: "").uppercased()
        }
    }
}

fileprivate extension ExchangeTrade {

    fileprivate func displayAmount() -> String? {
        if BlockchainSettings.sharedAppInstance().symbolLocal {
            let currencySymbol = withdrawalCurrency()
            switch currencySymbol {
            case "BTC":
                let value = NumberFormatter.parseBtcValue(from: withdrawalAmount.stringValue)
                return NumberFormatter.formatMoney(value.magnitude)
            case "ETH":
                guard let exchangeRate = WalletManager.shared.wallet.latestEthExchangeRate else { return nil }
                return NumberFormatter.formatEth(
                    withLocalSymbol: withdrawalAmount.stringValue,
                    exchangeRate: exchangeRate
                )
            case "BCH":
                let value = NumberFormatter.parseBtcValue(from: withdrawalAmount.stringValue)
                return NumberFormatter.formatBch(withSymbol: value.magnitude)
            default:
                Logger.shared.warning("Unsupported withdrawal currency for trade \(withdrawalCurrency())")
                return nil
            }
        } else {
            guard let toAsset = pair.components(separatedBy: "_").last else { return nil }
            return "\(NumberFormatter.localFormattedString(withdrawalAmount.stringValue)) \(toAsset))"
        }
    }

}
