//
//  ExchangeCreateContracts.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeCreateInterface: class {
    func ratesViewVisibility(_ visibility: Visibility)
    func updateInputLabels(primary: String?, primaryDecimal: String?, secondary: String?)
    func updateRateLabels(first: String, second: String, third: String)
    func updateTradingPairViewValues(left: String, right: String)
    func updateTradingPairView(pair: TradingPair, fix: Fix)
    func showSummary(conversion: Conversion)
}

// Conforms to NumberKeypadViewDelegate to avoid redundancy of keypad input methods
protocol ExchangeCreateInput: NumberKeypadViewDelegate {
    func viewLoaded()
    func displayInputTypeTapped()
    func ratesViewTapped()
    func useMinimumAmount()
    func useMaximumAmount()
    func confirmConversion()
}

protocol ExchangeCreateOutput: class {
    func updatedInput(primary: String?, primaryDecimal: String?, secondary: String?)
    func updatedRates(first: String, second: String, third: String)
    func updateTradingPairValues(left: String, right: String)
    func updateTradingPair(pair: TradingPair, fix: Fix)
    func confirm(conversion: Conversion)
}
