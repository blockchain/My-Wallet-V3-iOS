//
//  ExchangeCreateInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class ExchangeCreateInteractor {
    weak var output: ExchangeCreateOutput?
    fileprivate let inputs: ExchangeInputsAPI
    fileprivate var markets: ExchangeMarketsAPI

    init(dependencies: ExchangeDependencies) {
        self.markets = dependencies.markets
        self.inputs = dependencies.inputs
    }
}

extension ExchangeCreateInteractor: ExchangeCreateInput {
    func authenticate() {
        markets.authenticate(completion: { [unowned self] in
            self.markets.pair = TradingPair(from: .bitcoin, to: .ethereum)!
        })
    }

    func displayInputTypeTapped() {
        inputs.toggleInput()
        output?.updatedInput(primary: inputs.activeInput.input, secondary: inputs.lastOutput)
    }
    
    func ratesViewTapped() {
        
    }
    
    func useMinimumAmount() {
        
    }
    
    func useMaximumAmount() {
        
    }
    
    func onBackspaceTapped() {
        inputs.backspace()
        output?.updatedInput(primary: inputs.activeInput.input, secondary: inputs.lastOutput)
    }
    
    func onAddInputTapped(value: String) {
        inputs.add(character: value)
        output?.updatedInput(primary: inputs.activeInput.input, secondary: inputs.lastOutput)
    }
}
