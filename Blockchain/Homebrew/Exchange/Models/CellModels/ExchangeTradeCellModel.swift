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
        case .partner(let model):
            return model.destination
        case .homebrew(let model):
            return model.withdrawalAddress
        }
    }
    
    var feeDisplayValue: String {
        switch self {
        case .partner(let model):
            return model.minerFee
        case .homebrew(let model):
            return model.withdrawalFee.value + " " + model.withdrawalFee.symbol
        }
    }

    var amountFiatValue: String {
        switch self {
        case .partner(let model):
            return model.amountReceivedFiatValue
        case .homebrew(let model):
            return model.fiatValue.value
        }
    }
    
    var amountFiatSymbol: String {
        switch self {
        case .partner:
            return ""
        case .homebrew(let model):
            return model.fiatValue.symbol
        }
    }
    
    var amountDepositedCrypto: String {
        switch self {
        case .partner(let model):
            return model.amountDepositedCryptoValue
        case .homebrew(let model):
            return model.deposit.value + " " + model.deposit.symbol
        }
    }
    
    var amountReceivedCrypto: String {
        switch self {
        case .partner(let model):
            return model.amountReceivedCryptoValue
        case .homebrew(let model):
            if let value = model.withdrawal?.value, let symbol = model.withdrawal?.symbol {
                return value + " " + symbol
            } else {
                return ""
            }
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
    let destination: String
    let deposit: String
    let minerFee: String
    let transactionDate: Date
    let amountReceivedCryptoValue: String
    let amountReceivedFiatValue: String
    let amountDepositedCryptoValue: String
    let amountDepositedFiatValue: String
    
    init(with trade: ExchangeTrade) {
        identifier = trade.orderID
        status = TradeStatus(shapeshift: trade.status)
        transactionDate = trade.date
        destination = trade.withdrawal
        deposit = trade.deposit
        
        if let value = trade.minerFeeCryptoAmount() {
            minerFee = value
        } else {
            fatalError("Failed to map minerFee")
        }
        
        if let pairType = TradingPair(string: trade.pair) {
            pair = pairType
        } else {
            fatalError("Failed to map pair")
        }
        
        if let value = trade.inboundCryptoAmount() {
            amountReceivedCryptoValue = value
        } else {
            fatalError("Failed to map amountReceivedCryptoValue)")
        }
        
        if let value = trade.inboundFiatAmount() {
            amountReceivedFiatValue = value
        } else {
            fatalError("Failed to map amountReceivedFiatValue)")
        }
        
        if let value = trade.outboundCryptoAmount() {
            amountDepositedCryptoValue = value
        } else {
            fatalError("Failed to map amountDepositedCryptoValue)")
        }
        
        if let value = trade.outboundFiatAmount() {
            amountDepositedFiatValue = value
        } else {
            fatalError("Failed to map amountDepositedFiatValue)")
        }
        
        if let asset = AssetType(stringValue: trade.withdrawalCurrency()) {
            assetType = asset
        } else {
            fatalError("Failed to map assetType")
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
    let rate: String?
    let depositAddress: String
    let deposit: SymbolValue
    let withdrawalAddress: String
    let withdrawal: SymbolValue?
    let withdrawalFee: SymbolValue
    let fiatValue: SymbolValue
    let depositTxHash: String?
    let withdrawalTxHash: String?

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
        let legacyFormatter = DateFormatter.iso8601Format
        
        /// Some trades don't have a consistant date format. Some
        /// use the same format as what we use for establishing a
        /// secure session, some use ISO8601.
        if let transactionResult = formatter.date(from: inserted) {
            createdAt = transactionResult
        } else if let transactionResult = legacyFormatter.date(from: inserted) {
            createdAt = transactionResult
        } else {
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
        rate = try values.decodeIfPresent(String.self, forKey: .rate)
        depositAddress = try values.decode(String.self, forKey: .depositAddress)
        deposit = try values.decode(SymbolValue.self, forKey: .deposit)
        withdrawalAddress = try values.decode(String.self, forKey: .withdrawalAddress)
        withdrawal = try values.decodeIfPresent(SymbolValue.self, forKey: .withdrawal)
        withdrawalFee = try values.decode(SymbolValue.self, forKey: .withdrawalFee)
        fiatValue = try values.decode(SymbolValue.self, forKey: .fiatValue)
        depositTxHash = try values.decodeIfPresent(String.self, forKey: .depositTxHash)
        withdrawalTxHash = try values.decodeIfPresent(String.self, forKey: .withdrawalTxHash)
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
    
    fileprivate func minerFeeCryptoAmount() -> String? {
        guard let assetType = AssetType(stringValue: minerCurrency()) else { return nil }
        return assetType.toCrypto(amount: minerFee as Decimal)
    }
    
    fileprivate func inboundFiatAmount() -> String? {
        guard let toAsset = pair.components(separatedBy: "_").last else { return nil }
        guard let assetType = AssetType(stringValue: toAsset) else { return nil }
        return assetType.toFiat(amount: withdrawalAmount as Decimal)
    }
    
    fileprivate func inboundCryptoAmount() -> String? {
        guard let currencySymbol = withdrawalCurrency() else { return nil }
        guard let assetType = AssetType(stringValue: currencySymbol) else { return nil }
        return assetType.toCrypto(amount: withdrawalAmount as Decimal)
    }
    
    fileprivate func outboundFiatAmount() -> String? {
        guard let fromAsset = pair.components(separatedBy: "_").first else { return nil }
        guard let assetType = AssetType(stringValue: fromAsset) else { return nil }
        return assetType.toFiat(amount: depositAmount as Decimal)
    }
    
    fileprivate func outboundCryptoAmount() -> String? {
        guard let currencySymbol = depositCurrency() else { return nil }
        guard let assetType = AssetType(stringValue: currencySymbol) else { return nil }
        return assetType.toCrypto(amount: depositAmount as Decimal)
    }
}
