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
    func removeInsignificantCharacters(input: String) -> String
}

class ExchangeConversionService: ExchangeConversionAPI {
    var input: String = ""
    var output: String = ""

    func update(with conversion: Conversion) {
        let currencyRatio = conversion.currencyRatio
        let fix = conversion.fix
        switch fix {
        case .base:
            input = format(cryptoValue: currencyRatio.base.crypto.value)
            output = format(fiatValue: currencyRatio.base.fiat.value)
        case .baseInFiat:
            input = format(fiatValue: currencyRatio.base.fiat.value)
            output = format(cryptoValue: currencyRatio.base.crypto.value)
        case .counter:
            input = format(cryptoValue: currencyRatio.counter.crypto.value)
            output = format(fiatValue: currencyRatio.counter.fiat.value)
        case .counterInFiat:
            input = format(fiatValue: currencyRatio.counter.fiat.value)
            output = format(cryptoValue: currencyRatio.counter.crypto.value)
        }
    }
}

private extension ExchangeConversionService {
    func format(fiatValue: Decimal) -> String {
        return NumberFormatter.localCurrencyFormatterWithUSLocale.string(from: NSDecimalNumber(decimal: fiatValue))!
    }

    func format(cryptoValue: Decimal) -> String {
        return NumberFormatter.assetFormatterWithUSLocale.string(from: NSDecimalNumber(decimal: cryptoValue))!
    }
}

extension ExchangeConversionService {
    func removeInsignificantCharacters(input: String) -> String {
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."

        if !input.contains(decimalSeparator) {
            // All characters are significant
            return input
        }

        var inputCopy = input.copy() as! String

        // Remove trailing zeros
        while inputCopy.hasSuffix("0") {
            inputCopy = String(inputCopy.dropLast())
        }

        // Remove trailing decimal place
        if inputCopy.hasSuffix(decimalSeparator) {
            inputCopy = String(inputCopy.dropLast())
        }

        return inputCopy
    }
}
