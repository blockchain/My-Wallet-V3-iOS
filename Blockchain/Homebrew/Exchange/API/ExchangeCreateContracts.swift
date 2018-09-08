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
    func updateInputLabels(primary: String?, secondary: String?)
    func updateRateLabels(first: String, second: String, third: String)
}

// Conforms to NumberKeypadViewDelegate to avoid redundancy of keypad input methods
protocol ExchangeCreateInput: NumberKeypadViewDelegate {
    func viewLoaded()
    func displayInputTypeTapped()
    func ratesViewTapped()
    func useMinimumAmount()
    func useMaximumAmount()
}

protocol ExchangeCreateOutput: class {
    func updatedInput(primary: String?, secondary: String?)
    func updatedRates(first: String, second: String, third: String)
}
