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
    
    var activeInput: NumberInputDelegate
    
    var inputComponents: ExchangeInputComponents
    var lastOutput: String?
    private var components: [InputComponent] {
        return inputComponents.components
    }
    
    init() {
        self.inputComponents = ExchangeInputComponents(template: .standard)
        self.activeInput = NumberInputViewModel(newInput: nil)
    }
    
    func setup(with template: ExchangeStyleTemplate, usingFiat: Bool) {
        inputComponents = ExchangeInputComponents(template: template)
    }
    
    func primaryFiatAttributedString() -> NSAttributedString {
        guard components.count > 0 else { return NSAttributedString(string: "NaN")}
        guard let symbol = NumberFormatter.localCurrencyFormatter.currencySymbol else { return NSAttributedString(string: "NaN") }
        let symbolComponent = InputComponent(
            value: symbol,
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
    
    func maxFiatFractional() -> Int {
        return 2
    }
    
    func maxAssetFractional() -> Int {
        return 8
    }
    
    func canBackspace() -> Bool {
        return components.canDrop()
    }
    
    func canAddFiatCharacter(_ character: String) -> Bool {
        guard components.count > 0 else { return true }
        if components.contains(where: { $0.type == .pendingFractional }) {
            return components.filter({ $0.type == .fractional }).count < maxFiatFractional()
        }
        return true
    }
    
    func canAddAssetCharacter(_ character: String) -> Bool {
        guard components.count > 0 else { return true }
        if components.contains(where: { $0.type == .pendingFractional }) {
            return components.filter({ $0.type == .fractional }).count < maxAssetFractional()
        }
        return true
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
            activeInput.add(character: character)
            return
        }
        
        let component = InputComponent(
            value: character,
            type: .whole
        )
        inputComponents.append(component)
        activeInput.add(character: character)
        
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
        activeInput.backspace()
    }
    
    func toggleInput(usingFiat: Bool) {
        let newOutput = activeInput
        activeInput = NumberInputViewModel(newInput: lastOutput)
        lastOutput = newOutput.input
        inputComponents.isUsingFiat = usingFiat
        inputComponents.convertComponents(with: activeInput.input)
    }
}
