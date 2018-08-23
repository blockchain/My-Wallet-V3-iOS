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

    let status: TradeStatus
    let assetType: AssetType
    let transactionDate: Date
    let displayValue: String

    init(with trade: ExchangeTrade) {
        status = TradeStatus(shapeshift: trade.status)
        transactionDate = trade.date
        displayValue = trade.displayAmount() ?? ""
        if let asset = AssetType(stringValue: trade.withdrawalCurrency()) {
            assetType = asset
        } else {
            fatalError("Failed to map \(trade.withdrawalCurrency())")
        }
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case currency = "currency"
        case createdAt = "createdAt"
        case quantity = "quantity"
        case status = "state"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        transactionDate = try values.decode(Date.self, forKey: .createdAt)
        let asset = try values.decode(String.self, forKey: .currency)
        displayValue = try values.decode(String.self, forKey: .quantity)
        let statusValue = try values.decode(String.self, forKey: .status)
        status = TradeStatus(homebrew: statusValue)
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
        lhs.displayValue == rhs.displayValue &&
        lhs.status == rhs.status &&
        lhs.transactionDate == rhs.transactionDate
    }
}

extension ExchangeTradeCellModel: Hashable {
    var hashValue: Int {
        return assetType.hashValue ^
        displayValue.hashValue ^
        status.hashValue ^
        transactionDate.hashValue
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

    fileprivate func displayAmount() -> String? {
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
            return "\(NumberFormatter.localFormattedString(withdrawalAmount.stringValue)) \(toAsset))"
        }
    }

}
