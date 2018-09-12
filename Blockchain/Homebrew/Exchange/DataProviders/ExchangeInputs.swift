//
//  ExchangeInputs.swift
//  Blockchain
//
//  Created by kevinwu on 8/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias InputComponents = (integer: String, decimalSeparator: String?, fractional: String?)

protocol ExchangeInputsAPI: class {
    var activeInput: NumberInputDelegate { get }
    var inputComponents: InputComponents { get }
    var lastOutput: String? { get }
    var conversionRate: Decimal? { get set }

    func add(character: String)
    func backspace()
    func toggleInput()
}

class ExchangeInputsService: ExchangeInputsAPI {
    var activeInput: NumberInputDelegate
    var inputComponents: InputComponents {
        let decimalSeparator = activeInput.decimalSeparator
        let components = activeInput.input.components(separatedBy: decimalSeparator)
        return (components.first ?? "0", decimalSeparator, components.count > 1 ? components.last : nil)
    }
    var lastOutput: String?
    var conversionRate: Decimal?

    init() {
        self.activeInput = NumberInputViewModel(newInput: nil)
    }

    func add(character: String) {
        activeInput.add(character: character)
        updateOutput()
    }

    func backspace() {
        activeInput.backspace()
        updateOutput()
    }

    func updateOutput() {
        guard let rate = conversionRate else { return }
        let active = NSDecimalNumber(string: activeInput.input)
        let output = active.dividing(by: NSDecimalNumber(decimal: rate))
        lastOutput = output.stringValue
    }

    func toggleInput() {
        let newOutput = activeInput
        activeInput = NumberInputViewModel(newInput: lastOutput)
        lastOutput = newOutput.input
    }
}
