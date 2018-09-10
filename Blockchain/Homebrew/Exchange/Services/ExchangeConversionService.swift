//
//  ExchangeConversionService.swift
//  Blockchain
//
//  Created by kevinwu on 9/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias ConversionResult = (input: String, output: String)

protocol ExchangeConversionAPI {
    func update(with conversion: Conversion)
    var input: String { get }
    var output: String { get }
}

class ExchangeConversionService: ExchangeConversionAPI {
    var input: String = ""
    var output: String = ""

    func update(with conversion: Conversion) {
        let currencyRatio = conversion.currencyRatio
        let fix = conversion.fix
        switch fix {
        case .base:
            input = "\(currencyRatio.base.crypto.value)"
            output = "\(currencyRatio.base.fiat.value)"
        case .baseInFiat:
            input = "\(currencyRatio.base.fiat.value)"
            output = "\(currencyRatio.base.crypto.value)"
        case .counter:
            input = "\(currencyRatio.counter.crypto.value)"
            output = "\(currencyRatio.counter.fiat.value)"
        case .counterInFiat:
            input = "\(currencyRatio.counter.fiat.value)"
            output = "\(currencyRatio.counter.crypto.value)"
        }
    }
}
