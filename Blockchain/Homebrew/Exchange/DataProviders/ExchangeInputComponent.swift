//
//  ExchangeInputComponent.swift
//  Blockchain
//
//  Created by AlexM on 9/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ExchangeInputComponent {
    let wholeValue: String
    let delimiter: String
    let factionalValue: String?
}

extension ExchangeInputComponent {
    static let empty: ExchangeInputComponent = ExchangeInputComponent(
        wholeValue: "0",
        delimiter: Locale.current.decimalSeparator ?? ".",
        factionalValue: nil
    )
    
    func attributedFiat(withFont font: UIFont) -> NSAttributedString? {
        let attributed = NSAttributedString(string: wholeValue + delimiter + (factionalValue ?? ""))
        let stylized = attributed.stylizedPrice(font, includeCurrencySymbol: true)
        return stylized
    }
}

private extension NSAttributedString {
    func stylizedPrice(_ withFont: UIFont, includeCurrencySymbol: Bool = true) -> NSAttributedString {
        let formatter = NumberFormatter.localCurrencyFormatter
        
        guard let currencySymbol = formatter.currencySymbol else {
            assertionFailure("Expected a currency symbol")
            return self
        }
        
        let copy = NSMutableAttributedString(attributedString: self)
        if includeCurrencySymbol {
            copy.insert(NSAttributedString(string: currencySymbol), at: 0)
        }
        
        if let components = copy.string.components(separatedBy: copy.string.delimiter).last {
            if components.count == 1 {
                copy.append(NSAttributedString(string: "0"))
            }
        }
        
        guard let decimalIndex = copy.string.currencyDelimiterRange?.lowerBound else {
            assertionFailure("Expected a decimal point.")
            return self
        }
        
        var stylizedPrice: NSMutableAttributedString = NSMutableAttributedString(string: copy.string)
        if copy.string.contains(".") {
            stylizedPrice = NSMutableAttributedString(
                string: copy.string.replacingOccurrences(of: ".", with: " "),
                attributes: [.font: withFont]
            )
        }
        
        if copy.string.contains(",") {
            stylizedPrice = NSMutableAttributedString(
                string: copy.string.replacingOccurrences(of: ",", with: " "),
                attributes: [.font: withFont]
            )
        }
        
        if copy.string.contains("١") {
            stylizedPrice = NSMutableAttributedString(
                string: copy.string.replacingOccurrences(of: "١", with: " "),
                attributes: [.font: withFont]
            )
        }
        
        /// This takes into account the additional space
        /// added if we opt to `includeCurrencySymbol`
        let decimalRange = NSRange(
            location: decimalIndex,
            length: includeCurrencySymbol ? formatter.maximumFractionDigits + 1 : formatter.maximumFractionDigits
        )
        
        guard let currencyRange = stylizedPrice.string.range(of: currencySymbol)?.asNSRange else { return stylizedPrice }
        let reducedSize = ceil(withFont.pointSize / 2)
        guard let reducedFont = UIFont(name: withFont.fontName, size: reducedSize) else { return stylizedPrice }
        let offset = withFont.capHeight - reducedFont.capHeight
        stylizedPrice.addAttribute(.font, value: reducedFont, range: decimalRange)
        stylizedPrice.addAttribute(.baselineOffset, value: offset, range: decimalRange)
        stylizedPrice.addAttribute(.font, value: reducedFont, range: currencyRange)
        stylizedPrice.addAttribute(.baselineOffset, value: offset, range: currencyRange)
        stylizedPrice.addAttribute(.kern, value: 1.5, range: currencyRange)
        return stylizedPrice
    }
}

private extension String {
    
    var delimiter: String {
        return Locale.current.decimalSeparator ?? "."
    }
    
    var currencyDelimiterRange: NSRange? {
        /// Arabaic countries
        if let range = range(of: "١")?.asNSRange {
            return range
        }
        
        /// For EU countries
        if let range = range(of: ",")?.asNSRange {
            return range
        }
        
        /// For US
        if let range = range(of: ".")?.asNSRange {
            return range
        }
        
        return nil
    }
}

private extension Range where Bound == String.Index {
    var asNSRange: NSRange {
        return NSRange(
            location: self.lowerBound.encodedOffset,
            length: self.upperBound.encodedOffset - self.lowerBound.encodedOffset
        )
    }
}

