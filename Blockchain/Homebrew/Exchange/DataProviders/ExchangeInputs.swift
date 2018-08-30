//
//  ExchangeInputs.swift
//  Blockchain
//
//  Created by kevinwu on 8/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeInputsAPI: class {
    var activeInput: NumberInputDelegate { get }
    var lastOutput: String? { get }
    var conversionRate: NSDecimalNumber? { get set }

    func add(character: String)
    func backspace()
    func addDecimal()
    func toggleInput()
}

class ExchangeInputsService: ExchangeInputsAPI {
    var activeInput: NumberInputDelegate
    var lastOutput: String?
    var conversionRate: NSDecimalNumber?

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

    func addDecimal() {
        activeInput.addDecimal()
        updateOutput()
    }

    func updateOutput() {
        guard let rate = conversionRate else { return }
        let active = NSDecimalNumber(string: activeInput.input)
        let output = active.dividing(by: rate)
        lastOutput = output.stringValue
    }

    func toggleInput() {
        let newOutput = activeInput
        activeInput = NumberInputViewModel(newInput: lastOutput)
        lastOutput = newOutput.input
    }
}
