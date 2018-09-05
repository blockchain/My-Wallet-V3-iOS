//
//  ExchangeTradeCellModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ExchangeTradeCellModel: Decodable {

    enum TradeStatus {
        case noDeposits
        case complete
        case resolved
        case inProgress
        case cancelled
        case failed
        case expired
        case none

        /// This isn't ideal but `Homebrew` and `Shapeshift` map their
        /// trade status values differently.
        init(homebrew: String) {
            switch homebrew {
            case "NONE":
                self = .none
            case "PENDING_EXECUTION",
                 "PENDING_DEPOSIT",
                 "PENDING_REFUND",
                 "PENDING_WITHDRAWAL":
                self = .inProgress
            case "FINISHED":
                self = .complete
            case "FAILED":
                self = .failed
            case "REFUNDED":
                self = .cancelled
            default:
                self = .none
            }
        }

        init(shapeshift: String) {
            switch shapeshift {
            case "no_deposits",
                 "received":
                self = .inProgress
            case "complete":
                self = .complete
            case "resolved":
                self = .resolved
            case "CANCELLED":
                self = .cancelled
            case "failed":
                self = .failed
            case "EXPIRED":
                self = .expired
            default:
                self = .none
            }
        }
    }

    let identifier: String
    let status: TradeStatus
    let assetType: AssetType
    let pair: TradingPair
    let transactionDate: Date
    let amountReceivedDisplayValue: String
    let amountDepositedDisplayValue: String

    init(with trade: ExchangeTrade) {
        identifier = trade.orderID
        status = TradeStatus(shapeshift: trade.status)
        transactionDate = trade.date
        if let pairType = TradingPair(string: trade.pair) {
            pair = pairType
        } else {
            fatalError("Failed to map \(trade.pair)")
        }
        
        if let value = trade.inboundDisplayAmount() {
            amountReceivedDisplayValue = value
        } else {
            fatalError("Failed to map \(trade.inboundDisplayAmount() ?? "")")
        }
        
        if let value = trade.outboundDisplayAmount() {
            amountDepositedDisplayValue = value
        } else {
            fatalError("Failed to map \(trade.outboundDisplayAmount() ?? "")")
        }
        
        if let asset = AssetType(stringValue: trade.withdrawalCurrency()) {
            assetType = asset
        } else {
            fatalError("Failed to map \(trade.withdrawalCurrency())")
        }
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case currency = "currency"
        case createdAt = "createdAt"
        case quantity = "quantity"
        case depositQuantity = "depositQuantity"
        case pair = "pair"
        case status = "state"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        transactionDate = try values.decode(Date.self, forKey: .createdAt)
        identifier = try values.decode(String.self, forKey: .identifier)
        let asset = try values.decode(String.self, forKey: .currency)
        let pairValue = try values.decode(String.self, forKey: .pair)
        amountReceivedDisplayValue = try values.decode(String.self, forKey: .quantity)
        amountDepositedDisplayValue = try values.decode(String.self, forKey: .depositQuantity)
        let statusValue = try values.decode(String.self, forKey: .status)
        status = TradeStatus(homebrew: statusValue)
        
        if let pairType = TradingPair(string: pairValue) {
            pair = pairType
        } else {
            fatalError("Failed to map \(pairValue)")
        }
        
        if let asset = AssetType(stringValue: asset) {
            assetType = asset
        } else {
            // TODO: Show error alert
            fatalError("Failed to map \(asset)")
        }
    }
}

extension ExchangeTradeCellModel: Equatable {
    static func ==(lhs: ExchangeTradeCellModel, rhs: ExchangeTradeCellModel) -> Bool {
        return lhs.assetType == rhs.assetType &&
        lhs.amountReceivedDisplayValue == rhs.amountReceivedDisplayValue &&
        lhs.status == rhs.status &&
        lhs.transactionDate == rhs.transactionDate &&
        lhs.pair == rhs.pair
    }
}

extension ExchangeTradeCellModel: Hashable {
    var hashValue: Int {
        return assetType.hashValue ^
        amountReceivedDisplayValue.hashValue ^
        status.hashValue ^
        transactionDate.hashValue ^
        pair.hashValue
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
             .inProgress,
             .none:
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
            return LocalizationConstants.Exchange.complete
        case .noDeposits,
             .inProgress,
             .none:
            return LocalizationConstants.Exchange.inProgress
        case .cancelled,
             .failed,
             .expired,
             .resolved:
            return LocalizationConstants.Exchange.tradeRefunded
        }
    }
}

fileprivate extension ExchangeTrade {
    
    fileprivate func inboundDisplayAmount() -> String? {
        if BlockchainSettings.sharedAppInstance().symbolLocal {
            guard let currencySymbol = withdrawalCurrency() else { return nil }
            guard let assetType = AssetType(stringValue: currencySymbol) else { return nil }
            switch assetType {
            case .bitcoin:
                let value = NumberFormatter.parseBtcValue(from: withdrawalAmount.stringValue)
                return NumberFormatter.formatMoney(value.magnitude)
            case .ethereum:
                guard let exchangeRate = WalletManager.shared.wallet.latestEthExchangeRate else { return nil }
                return NumberFormatter.formatEth(
                    withLocalSymbol: withdrawalAmount.stringValue,
                    exchangeRate: exchangeRate
                )
            case .bitcoinCash:
                let value = NumberFormatter.parseBtcValue(from: withdrawalAmount.stringValue)
                return NumberFormatter.formatBch(withSymbol: value.magnitude)
            }
        } else {
            guard let toAsset = pair.components(separatedBy: "_").last else { return nil }
            let formatted = toAsset.uppercased()
            guard let amount = NumberFormatter.localFormattedString(withdrawalAmount.stringValue) else { return nil }
            return amount + " " + formatted
        }
    }
    
    fileprivate func outboundDisplayAmount() -> String? {
        if BlockchainSettings.sharedAppInstance().symbolLocal {
            guard let currencySymbol = depositCurrency() else { return nil }
            guard let assetType = AssetType(stringValue: currencySymbol) else { return nil }
            switch assetType {
            case .bitcoin:
                let value = NumberFormatter.parseBtcValue(from: depositAmount.stringValue)
                return NumberFormatter.formatMoney(value.magnitude)
            case .ethereum:
                guard let exchangeRate = WalletManager.shared.wallet.latestEthExchangeRate else { return nil }
                return NumberFormatter.formatEth(
                    withLocalSymbol: depositAmount.stringValue,
                    exchangeRate: exchangeRate
                )
            case .bitcoinCash:
                let value = NumberFormatter.parseBtcValue(from: depositAmount.stringValue)
                return NumberFormatter.formatBch(withSymbol: value.magnitude)
            }
        } else {
            guard let fromAsset = pair.components(separatedBy: "_").first else { return nil }
            let formatted = fromAsset.uppercased()
            guard let amount = NumberFormatter.localFormattedString(depositAmount.stringValue) else { return nil }
            return amount + " " + formatted
        }
    }
}
