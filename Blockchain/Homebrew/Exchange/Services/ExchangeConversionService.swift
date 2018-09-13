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
    // Given a conversion, update the input, output, and opposing fix
    func update(with conversion: Conversion)

    // The amount being typed in by the user (what goes in the primary or larger, more prominent label)
    var input: String { get }

    // The conversion result amount from the input amount (what goes in the secondary or smaller, less prominent label)
    var output: String { get }

    // The base output is what should be displayed on the left hand side of the trading pair view.
    var baseOutput: String { get }

    // The counter fix output is what should be displayed on the right hand side of the trading pair view.
    var counterOutput: String { get }

    // Method used to remove trailing zeros and decimals for true value comparison
    // Primariy used to allow the user to keep typing uninterrupted
    func removeInsignificantCharacters(input: String) -> String
}

class ExchangeConversionService: ExchangeConversionAPI {
    var input: String = ""
    var output: String = ""
    var baseOutput: String = ""
    var counterOutput: String = ""

    func update(with conversion: Conversion) {
        let quote = conversion.quote
        let currencyRatio = quote.currencyRatio
        let fix = quote.fix
        switch fix {
        case .base:
            input = formatDecimalPlaces(cryptoValue: currencyRatio.base.crypto.value)
            output = formatDecimalPlaces(fiatValue: currencyRatio.base.fiat.value)
            baseOutput = input
            counterOutput = formatDecimalPlaces(cryptoValue: currencyRatio.counter.crypto.value)
        case .baseInFiat:
            input = formatDecimalPlaces(fiatValue: currencyRatio.base.fiat.value)
            output = formatDecimalPlaces(cryptoValue: currencyRatio.base.crypto.value)
            baseOutput = output
            counterOutput = formatDecimalPlaces(cryptoValue: currencyRatio.counter.crypto.value)
        case .counter:
            input = formatDecimalPlaces(cryptoValue: currencyRatio.counter.crypto.value)
            output = formatDecimalPlaces(fiatValue: currencyRatio.counter.fiat.value)
            baseOutput = formatDecimalPlaces(cryptoValue: currencyRatio.base.crypto.value)
            counterOutput = input
        case .counterInFiat:
            input = formatDecimalPlaces(fiatValue: currencyRatio.counter.fiat.value)
            output = formatDecimalPlaces(cryptoValue: currencyRatio.counter.crypto.value)
            baseOutput = formatDecimalPlaces(cryptoValue: currencyRatio.base.crypto.value)
            counterOutput = output
        }
    }
}

private extension ExchangeConversionService {
    func formatDecimalPlaces(fiatValue: String) -> String {
        return NumberFormatter.localCurrencyFormatterWithUSLocale.string(from: NSDecimalNumber(string: fiatValue))!
    }

    func formatDecimalPlaces(cryptoValue: String) -> String {
        return NumberFormatter.assetFormatterWithUSLocale.string(from: NSDecimalNumber(string: cryptoValue))!
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
