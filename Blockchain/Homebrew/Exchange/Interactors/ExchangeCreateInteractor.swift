//
//  ExchangeCreateInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreateInteractor {
    weak var output: ExchangeCreateOutput?
    fileprivate let inputs: ExchangeInputsAPI
    fileprivate let markets: ExchangeMarketsAPI

    init(dependencies: ExchangeDependencies) {
        self.markets = dependencies.markets
        self.inputs = dependencies.inputs
    }
}

extension ExchangeCreateInteractor: ExchangeCreateInput {
    func toggleFiatInput() {
        inputs.toggleInput()
        output?.updatedInput(primary: inputs.activeInput.input, secondary: inputs.lastOutput)
    }
    
    func ratesButtonTapped() {
        
    }
    
    func useMinimumButtonTapped() {
        
    }
    
    func useMaximumButtonTapped() {
        
    }
    
    func onBackspaceTapped() {
        inputs.backspace()
        output?.updatedInput(primary: inputs.activeInput.input, secondary: inputs.lastOutput)
    }
    
    func onNumberButtonTapped(value: String) {
        inputs.add(character: value)
        output?.updatedInput(primary: inputs.activeInput.input, secondary: inputs.lastOutput)
    }

    func onDecimalButtonTapped() {
        inputs.addDecimal()
        output?.updatedInput(primary: inputs.activeInput.input, secondary: inputs.lastOutput)
    }
}
