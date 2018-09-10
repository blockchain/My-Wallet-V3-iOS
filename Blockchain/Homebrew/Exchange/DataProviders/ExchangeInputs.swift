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
    var activeInput: NumberInputDelegate { get set }
    var inputComponents: InputComponents { get }
    var lastOutput: String? { get set }

    func add(character: String)
    func backspace()
    func toggleInput()
}

// A class containing an active input that can switch values with an output using toggleInput()
class ExchangeInputsService: ExchangeInputsAPI {
    var activeInput: NumberInputDelegate
    var inputComponents: InputComponents {
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
        let components = activeInput.input.components(separatedBy: decimalSeparator)
        return (components.first ?? "0", decimalSeparator, components.count > 1 ? components.last : nil)
    }
    var lastOutput: String?

    init() {
        self.activeInput = NumberInputViewModel(newInput: nil)
    }

    func add(character: String) {
        activeInput.add(character: character)
    }

    func backspace() {
        activeInput.backspace()
    }

    func toggleInput() {
        let newOutput = activeInput
        activeInput = NumberInputViewModel(newInput: lastOutput)
        lastOutput = newOutput.input
    }
}
