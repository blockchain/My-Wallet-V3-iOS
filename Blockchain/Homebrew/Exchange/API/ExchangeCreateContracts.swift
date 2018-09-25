//
//  ExchangeCreateContracts.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeCreateInterface: class {
    func wigglePrimaryLabel()
    func wiggleInputLabels()
    func styleTemplate() -> ExchangeStyleTemplate
    func conversionViewVisibility(_ visibility: Visibility, animated: Bool)
    func ratesViewVisibility(_ visibility: Visibility, animated: Bool)
    func keypadViewVisibility(_ visibility: Visibility, animated: Bool)
    func exchangeButtonVisibility(_ visibility: Visibility, animated: Bool)
    func ratesChevronButtonVisibility(_ visibility: Visibility, animated: Bool)
    func updateAttributedPrimary(_ primary: NSAttributedString?, secondary: String?)
    func updateInputLabels(primary: String?, primaryDecimal: String?, secondary: String?)
    func updateRateLabels(first: String, second: String, third: String)
    func updateTradingPairViewValues(left: String, right: String)
    func updateTradingPairView(pair: TradingPair, fix: Fix)
    func loadingVisibility(_ visibility: Visibility, action: ExchangeCreateViewController.Action)
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion)
    func showTemporaryInputLabelsColor(color: UIColor)
    func clearInputLabelAnimations()
}

// Conforms to NumberKeypadViewDelegate to avoid redundancy of keypad input methods
protocol ExchangeCreateInput: NumberKeypadViewDelegate {
    func viewLoaded()
    func displayInputTypeTapped()
    func ratesViewTapped()
    func useMinimumAmount(assetAccount: AssetAccount)
    func useMaximumAmount(assetAccount: AssetAccount)
    func confirmConversion()
    func changeTradingPair(tradingPair: TradingPair)
}

protocol ExchangeCreateOutput: class {
    func entryRejected()
    func styleTemplate() -> ExchangeStyleTemplate
    func updatedInput(primary: NSAttributedString?, secondary: String?)
    func updatedInput(primary: String?, primaryDecimal: String?, secondary: String?)
    func updatedRates(first: String, second: String, third: String)
    func updateTradingPairValues(left: String, right: String)
    func updateTradingPair(pair: TradingPair, fix: Fix)
    func loadingVisibility(_ visibility: Visibility, action: ExchangeCreateViewController.Action)
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion)
    func showInputError()
}
