//
//  ExchangeInputsService.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// A class containing an active input that can switch values with an output using toggleInput()
class ExchangeInputsService: ExchangeInputsAPI {
    
    var isUsingFiat: Bool = false {
        didSet {
            inputComponents.isUsingFiat = isUsingFiat
        }
    }
    
    var activeInput: String {
        return inputComponents.numericalString
    }
    
    var inputComponents: ExchangeInputComponents
    private var components: [InputComponent] {
        return inputComponents.components
    }
    
    init() {
        self.inputComponents = ExchangeInputComponents(template: .standard)
    }
    
    func setup(with template: ExchangeStyleTemplate, usingFiat: Bool) {
        inputComponents = ExchangeInputComponents(template: template)
        isUsingFiat = usingFiat
    }
    
    func estimatedSymbolWidth(currencySymbol: String, template: ExchangeStyleTemplate) -> CGFloat {
        let component = InputComponent(value: currencySymbol, type: .symbol)
        let value = component.attributedString(with: template)
        return isUsingFiat ? (value.width / 2) : 0.0
    }
    
    func primaryFiatAttributedString(currencySymbol: String) -> NSAttributedString {
        guard components.count > 0 else { return NSAttributedString(string: "NaN")}
        let symbolComponent = InputComponent(
            value: currencySymbol,
            type: .symbol
        )
        return inputComponents.primaryFiatAttributedString(symbolComponent)
    }
    
    func primaryAssetAttributedString(symbol: String) -> NSAttributedString {
        guard components.count > 0 else { return NSAttributedString(string: "NaN")}
        let suffixComponent = InputComponent(
            value: symbol,
            type: .suffix
        )
        return inputComponents.primaryAssetAttributedString(suffixComponent)
    }
    
    func maxFiatInteger() -> Int {
        return 6
    }
    
    func maxAssetInteger() -> Int {
        return 5
    }
    
    func maxFiatFractional() -> Int {
        return NumberFormatter.localCurrencyFractionDigits
    }
    
    func maxAssetFractional() -> Int {
        return NumberFormatter.assetFractionDigits
    }
    
    func canBackspace() -> Bool {
        return components.canDrop()
    }
    
    func canAddFiatCharacter(_ character: String) -> Bool {
        guard components.count > 0 else { return true }
        let pendingFractional = components.contains(where: { $0.type == .pendingFractional })
        if pendingFractional {
            return components.filter({ $0.type == .fractional }).count < maxFiatFractional()
        } else {
            return components.filter({ $0.type == .whole }).count < maxFiatInteger()
        }
    }
    
    func canAddAssetCharacter(_ character: String) -> Bool {
        guard components.count > 0 else { return true }
        let pendingFractional = components.contains(where: { $0.type == .pendingFractional })
        if pendingFractional {
            return components.filter({ $0.type == .fractional }).count < maxAssetFractional()
        } else {
            return components.filter({ $0.type == .whole }).count < maxAssetInteger()
        }
    }
    
    func canAddDelimiter() -> Bool {
        return components.contains(where: { $0.type == .pendingFractional }) == false
    }
    
    func canAddFractionalAsset() -> Bool {
        guard components.count > 0 else { return false }
        if components.contains(where: { $0.type == .pendingFractional }) {
            return components.filter({ $0.type == .fractional }).count < maxAssetFractional()
        } else {
            return false
        }
    }
    
    func canAddFractionalFiat() -> Bool {
        guard components.count > 0 else { return false }
        if components.contains(where: { $0.type == .pendingFractional }) {
            return components.filter({ $0.type == .fractional }).count < maxFiatFractional()
        } else {
            return false
        }
    }
    
    func add(character: String) {
        if components.contains(where: { $0.type == .pendingFractional || $0.type == .fractional }) {
            let component = InputComponent(
                value: character,
                type: .fractional
            )
            
            inputComponents.append(component)
            return
        }
        
        let component = InputComponent(
            value: character,
            type: .whole
        )
        inputComponents.append(component)
    }
    
    func add(delimiter: String) {
        guard canAddDelimiter() == true else { return }
        
        let component = InputComponent(
            value: delimiter,
            type: .pendingFractional
        )
        
        inputComponents.append(component)
    }
    
    func backspace() {
        inputComponents.dropLast()
    }
    
    func toggleInput(withOutput output: String) {
        inputComponents.convertComponents(with: output)
    }

    func clear() {
        while canBackspace() {
            backspace()
        }
    }
}
