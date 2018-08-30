//
//  ExchangeCreateContracts.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeCreateInterface: class {
    func expandRatesView()
    func updateInputLabels(primary: String?, secondary: String?)
    func updateRates(first: String, second: String, third: String)
}

protocol ExchangeCreateInput: NumberKeypadViewDelegate {
    func toggleFiatInput()
    func ratesButtonTapped()
    func useMinimumButtonTapped()
    func useMaximumButtonTapped()
}

protocol ExchangeCreateOutput: class {
    func updatedInput(primary: String?, secondary: String?)
    func updatedRates(first: String, second: String, third: String)
}
