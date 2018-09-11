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

    // The opposing fix is the 'counter' or 'opposite' to whatever is the input/output but with the same crypto/fiat
    // format as the input.
    // This will typically be displayed in the TradingPairView in the button above which the green dot is NOT visible.
    // If the Fix is .base or .baseInFiat, the opposing fix is .counter or .counterInFiat.
    // If the Fix is .counter or .counterInFiat, the opposing fix is .base or .baseInFiat.
    var opposingFix: String { get }

    // Method used to remove trailing zeros and decimals for true value comparison
    // Primariy used to allow the user to keep typing uninterrupted
    func removeInsignificantCharacters(input: String) -> String
}

class ExchangeConversionService: ExchangeConversionAPI {
    var input: String = ""
    var output: String = ""
    var opposingFix: String = ""

    func update(with conversion: Conversion) {
        let currencyRatio = conversion.currencyRatio
        let fix = conversion.fix
        switch fix {
        case .base:
            input = formatDecimalPlaces(cryptoValue: currencyRatio.base.crypto.value)
            output = formatDecimalPlaces(fiatValue: currencyRatio.base.fiat.value)
            opposingFix = formatDecimalPlaces(cryptoValue: currencyRatio.counter.crypto.value)
        case .baseInFiat:
            input = formatDecimalPlaces(fiatValue: currencyRatio.base.fiat.value)
            output = formatDecimalPlaces(cryptoValue: currencyRatio.base.crypto.value)
            opposingFix = formatDecimalPlaces(fiatValue: currencyRatio.counter.fiat.value)
        case .counter:
            input = formatDecimalPlaces(cryptoValue: currencyRatio.counter.crypto.value)
            output = formatDecimalPlaces(fiatValue: currencyRatio.counter.fiat.value)
            opposingFix = formatDecimalPlaces(cryptoValue: currencyRatio.base.crypto.value)
        case .counterInFiat:
            input = formatDecimalPlaces(fiatValue: currencyRatio.counter.fiat.value)
            output = formatDecimalPlaces(cryptoValue: currencyRatio.counter.crypto.value)
            opposingFix = formatDecimalPlaces(fiatValue: currencyRatio.base.fiat.value)
        }
    }
}

private extension ExchangeConversionService {
    func formatDecimalPlaces(fiatValue: Decimal) -> String {
        return NumberFormatter.localCurrencyFormatterWithUSLocale.string(from: NSDecimalNumber(decimal: fiatValue))!
    }

    func formatDecimalPlaces(cryptoValue: Decimal) -> String {
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
