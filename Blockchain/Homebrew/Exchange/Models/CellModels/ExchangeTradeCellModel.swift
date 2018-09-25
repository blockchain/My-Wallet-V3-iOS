//
//  ExchangeTradeCellModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum ExchangeTradeModel {
    case partner(PartnerTrade)
    case homebrew(ExchangeTradeCellModel)
    
    enum TradeStatus {
        case noDeposits
        case complete
        case resolved
        case inProgress
        case pendingRefund
        case refunded
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
                 "FINISHED_DEPOSIT",
                 "PENDING_WITHDRAWAL":
                self = .inProgress
            case "PENDING_REFUND":
                self = .pendingRefund
            case "REFUNDED":
                self = .refunded
            case "FINISHED":
                self = .complete
            case "FAILED":
                self = .failed
            case "EXPIRED":
                self = .expired
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
}

extension ExchangeTradeModel {
    var withdrawalAddress: String {
        switch self {
        case .partner:
            // Not in ExchangeTableViewCell
            return ""
        case .homebrew(let model):
            return model.withdrawalAddress
        }
    }

    var amountFeeSymbol: String {
        switch self {
        case .partner:
            // Not in ExchangeTableViewCell
            return ""
        case .homebrew(let model):
            return model.withdrawalFee.symbol
        }
    }

    var amountFeeValue: String {
        switch self {
        case .partner:
            // Not in ExchangeTableViewCell
            return ""
        case .homebrew(let model):
            return model.withdrawalFee.value
        }
    }

    var amountFiatValue: String {
        switch self {
        case .partner:
            // Currently calculated in ExchangeTableViewCell based on latest rates
            return ""
        case .homebrew(let model):
            return model.fiatValue.value
        }
    }
    
    var amountFiatSymbol: String {
        switch self {
        case .partner:
            // Currently calculated in ExchangeTableViewCell cell based on latest rates
            return ""
        case .homebrew(let model):
            return model.fiatValue.symbol
        }
    }

    var amountDepositedCryptoValue: String {
        switch self {
        case .partner(let model):
            return model.amountDepositedCryptoValue
        case .homebrew(let model):
            return model.deposit.value
        }
    }
    
    var amountDepositedCryptoSymbol: String {
        switch self {
        case .partner(let model):
            return model.pair.from.symbol
        case .homebrew(let model):
            return model.deposit.symbol
        }
    }

    var amountReceivedCryptoSymbol: String {
        switch self {
        case .partner(let model):
            return model.pair.to.symbol
        case .homebrew(let model):
            return model.withdrawal.symbol
        }
    }

    var amountReceivedCryptoValue: String {
        switch self {
        case .partner(let model):
            return model.amountReceivedCryptoValue
        case .homebrew(let model):
            return model.withdrawal.value
        }
    }
    
    var transactionDate: Date {
        switch self {
        case .partner(let model):
            return model.transactionDate
        case .homebrew(let model):
            return model.createdAt
        }
    }
    
    var formattedDate: String {
        switch self {
        case .partner(let model):
            return DateFormatter.timeAgoString(from: model.transactionDate)
        case .homebrew(let model):
            return DateFormatter.timeAgoString(from: model.createdAt)
        }
    }
    
    var status: ExchangeTradeModel.TradeStatus {
        switch self {
        case .partner(let model):
            return model.status
        case .homebrew(let model):
            return model.status
        }
    }
    
    var identifier: String {
        switch self {
        case .partner(let model):
            return model.identifier
        case .homebrew(let model):
            return model.identifier
        }
    }
}

struct PartnerTrade {
    
    typealias TradeStatus = ExchangeTradeModel.TradeStatus
    
    let identifier: String
    let status: TradeStatus
    let assetType: AssetType
    let pair: TradingPair
    let transactionDate: Date
    let amountReceivedCryptoValue: String
    let amountDepositedCryptoValue: String
    
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
            amountReceivedCryptoValue = value
        } else {
            fatalError("Failed to map \(trade.inboundDisplayAmount() ?? "")")
        }
        
        if let value = trade.outboundDisplayAmount() {
            amountDepositedCryptoValue = value
        } else {
            fatalError("Failed to map \(trade.outboundDisplayAmount() ?? "")")
        }
        
        if let asset = AssetType(stringValue: trade.withdrawalCurrency()) {
            assetType = asset
        } else {
            fatalError("Failed to map \(trade.withdrawalCurrency())")
        }
    }
}

struct ExchangeTradeCellModel: Decodable {
    
    typealias TradeStatus = ExchangeTradeModel.TradeStatus

    let identifier: String
    let status: TradeStatus
    let createdAt: Date
    let updatedAt: Date
    let pair: TradingPair
    let refundAddress: String
    let rate: String
    let depositAddress: String
    let deposit: SymbolValue
    let withdrawalAddress: String
    let withdrawal: SymbolValue
    let withdrawalFee: SymbolValue
    let fiatValue: SymbolValue
    let depositTxHash: String
    let withdrawalTxHash: String

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case status = "state"
        case createdAt
        case updatedAt
        case pair
        case refundAddress
        case rate
        case depositAddress
        case deposit
        case withdrawalAddress
        case withdrawal
        case withdrawalFee
        case fiatValue
        case depositTxHash
        case withdrawalTxHash
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let updated = try values.decode(String.self, forKey: .updatedAt)
        let inserted = try values.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter.sessionDateFormat
        
        guard let transactionResult = formatter.date(from: inserted) else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: values,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
        guard let updatedResult = formatter.date(from: updated) else {
            throw DecodingError.dataCorruptedError(
                forKey: .updatedAt,
                in: values,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
        
        createdAt = transactionResult
        updatedAt = updatedResult
        
        identifier = try values.decode(String.self, forKey: .identifier)
        let pairValue = try values.decode(String.self, forKey: .pair)
        let statusValue = try values.decode(String.self, forKey: .status)
        status = TradeStatus(homebrew: statusValue)
        
        if let pairType = TradingPair(string: pairValue) {
            pair = pairType
        } else {
            fatalError("Failed to map \(pairValue)")
        }
        
        refundAddress = try values.decode(String.self, forKey: .refundAddress)
        rate = try values.decode(String.self, forKey: .rate)
        depositAddress = try values.decode(String.self, forKey: .depositAddress)
        deposit = try values.decode(SymbolValue.self, forKey: .deposit)
        withdrawalAddress = try values.decode(String.self, forKey: .withdrawalAddress)
        withdrawal = try values.decode(SymbolValue.self, forKey: .withdrawal)
        withdrawalFee = try values.decode(SymbolValue.self, forKey: .withdrawalFee)
        fiatValue = try values.decode(SymbolValue.self, forKey: .fiatValue)
        depositTxHash = try values.decode(String.self, forKey: .depositTxHash)
        withdrawalTxHash = try values.decode(String.self, forKey: .withdrawalTxHash)
    }
}

extension ExchangeTradeCellModel: Equatable {
    static func ==(lhs: ExchangeTradeCellModel, rhs: ExchangeTradeCellModel) -> Bool {
        return lhs.status == rhs.status &&
        lhs.createdAt == rhs.createdAt &&
        lhs.pair == rhs.pair
    }
}

extension ExchangeTradeCellModel: Hashable {
    var hashValue: Int {
        return status.hashValue ^
        createdAt.hashValue ^
        pair.hashValue
    }
}

extension ExchangeTradeCellModel {
    var formattedDate: String {
        return DateFormatter.timeAgoString(from: createdAt)
    }
}

extension ExchangeTradeModel.TradeStatus {
    
    var tintColor: UIColor {
        switch self {
        case .complete,
             .refunded,
             .resolved,
             .cancelled:
            return .green
        case .inProgress,
             .noDeposits:
           return #colorLiteral(red: 0.96, green: 0.65, blue: 0.14, alpha: 1)
        case .pendingRefund:
            return #colorLiteral(red: 0.96, green: 0.65, blue: 0.14, alpha: 1)
        case .failed:
           return #colorLiteral(red: 0.95, green: 0.42, blue: 0.44, alpha: 1)
        case .expired,
             .none:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }

    var displayValue: String {
        switch self {
        case .complete,
             .resolved:
            return LocalizationConstants.Exchange.complete
        case .pendingRefund:
            return LocalizationConstants.Exchange.refundInProgress
        case .refunded,
             .cancelled:
            return LocalizationConstants.Exchange.refunded
        case .failed:
            return LocalizationConstants.Exchange.failed
        case .expired:
            return LocalizationConstants.Exchange.expired
        case .inProgress,
             .noDeposits,
             .none:
            return LocalizationConstants.Exchange.inProgress
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
