//
//  MarketsModel.swift
//  Blockchain
//
//  Created by kevinwu on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `MarketPair` is to keep track of what accounts
/// the user is transferring from and to. We originally
/// used just a `TradingPair` but some users may have
/// multiple wallets of the same asset type.
struct MarketPair {
    let fromAccount: AssetAccount
    let toAccount: AssetAccount
}

extension MarketPair {
    var pair: TradingPair {
        let fromType = fromAccount.address.assetType
        let toType = toAccount.address.assetType
        return TradingPair(from: fromType, to: toType)!
    }

    func swapped() -> MarketPair {
        return MarketPair(fromAccount: self.toAccount, toAccount: self.fromAccount)
    }
}

// State model for interacting with the MarketsService
class MarketsModel {
    var marketPair: MarketPair
    var fiatCurrencyCode: String
    var fiatCurrencySymbol: String
    var fix: Fix
    var volume: String
    var lastConversion: Conversion?

    init(marketPair: MarketPair,
         fiatCurrencyCode: String,
         fiatCurrencySymbol: String,
         fix: Fix,
         volume: String) {
        self.marketPair = marketPair
        self.fiatCurrencyCode = fiatCurrencyCode
        self.fiatCurrencySymbol = fiatCurrencySymbol
        self.fix = fix
        self.volume = volume
    }
}

extension MarketsModel {
    var pair: TradingPair {
        return marketPair.pair
    }
}

extension MarketsModel {
    var isUsingFiat: Bool {
        return fix == .baseInFiat || fix == .counterInFiat
    }

    var isUsingBase: Bool {
        return fix == .base || fix == .baseInFiat
    }

    func toggleFiatInput() {
        switch fix {
        case .base:
            fix = .baseInFiat
        case .baseInFiat:
            fix = .base
        case .counter:
            fix = .counterInFiat
        case .counterInFiat:
            fix = .counter
        }
    }

    func swapPairs() {
        marketPair = marketPair.swapped()
    }
}

extension MarketsModel: Equatable {
    // Do not compare lastConversion
    static func == (lhs: MarketsModel, rhs: MarketsModel) -> Bool {
        return lhs.pair == rhs.pair &&
        lhs.fiatCurrencyCode == rhs.fiatCurrencyCode &&
        lhs.fiatCurrencySymbol == rhs.fiatCurrencySymbol &&
        lhs.fix == rhs.fix &&
        lhs.volume == rhs.volume
    }
}
