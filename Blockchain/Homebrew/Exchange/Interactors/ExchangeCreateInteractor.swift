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
    var disposable: Disposable?
    weak var output: ExchangeCreateOutput?
    fileprivate var inputs: ExchangeInputsAPI
    fileprivate var markets: ExchangeMarketsAPI
    fileprivate var conversions: ExchangeConversionAPI
    private var model: MarketsModel? {
        didSet {
            if markets.hasAuthenticated {
                updateMarketsConversion()
            }
        }
    }

    init(dependencies: ExchangeDependencies,
         model: MarketsModel
    ) {
        self.markets = dependencies.markets
        self.inputs = dependencies.inputs
        self.conversions = dependencies.conversions
        self.model = model
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}

extension ExchangeCreateInteractor: ExchangeCreateInput {
    
    func viewLoaded() {
        guard let output = output else { return }
        guard let model = model else { return }
        inputs.setup(with: output.styleTemplate(), usingFiat: model.isUsingFiat)
        inputs.toggleInput(usingFiat: model.isUsingFiat)
        updatedInput()
        
        markets.setup()

        // Authenticate, then listen for conversions
        markets.authenticate(completion: { [unowned self] in
            self.subscribeToConversions()
            self.updateMarketsConversion()
        })
    }

    func subscribeToConversions() {
        disposable = markets.conversions.subscribe(onNext: { [weak self] conversion in
            guard let this = self else { return }

            // Use conversions service to determine new input/output
            this.conversions.update(with: conversion)
            let input = this.inputs.activeInput.input

            // Remove trailing zeros and decimal place - if the input values are equal, then avoid replacing
            // text, which would interrupt user entry
            let inputTest = this.conversions.removeInsignificantCharacters(input: input)
            let conversionInputTest = this.conversions.removeInsignificantCharacters(input: this.conversions.input)

            if inputTest != conversionInputTest {
                this.inputs.activeInput.input = this.conversions.input
            }
            this.inputs.lastOutput = this.conversions.output

            // Update interface to reflect the values returned from the conversion
            // Update input labels
            this.updateOutput()

            // Update trading pair view
            this.updateTradingValues(left: this.conversions.baseOutput, right: this.conversions.counterOutput)
        }, onError: { error in
            Logger.shared.error("Error subscribing to quote with trading pair")
        })
    }

    func updateMarketsConversion() {
        guard let model = model else {
            Logger.shared.error("Updating conversion with no model")
            return
        }
        markets.updateConversion(model: model)
    }

    func updatedInput() {
        // Update model volume
        guard let model = model else {
            Logger.shared.error("Updating input with no model")
            return
        }
        model.volume = inputs.activeInput.input

        // Update interface to reflect what has been typed
        updateOutput()

        // Re-subscribe to socket with new volume value
        updateMarketsConversion()
    }

    func updateOutput() {
        // Update the inputs in crypto and fiat
        guard let output = output else { return }
        if model?.isUsingFiat == true {
            
            let primary = inputs.primaryFiatAttributedString()
            output.updatedInput(primary: primary, secondary: inputs.lastOutput)
        } else {
            guard let model = model else { return }
            let symbol = model.pair.from.symbol
            let primary = inputs.primaryAssetAttributedString(symbol: symbol)
            output.updatedInput(primary: primary, secondary: inputs.lastOutput)
        }
    }

    func updateTradingValues(left: String, right: String) {
        output?.updateTradingPairValues(left: left, right: right)
    }

    func displayInputTypeTapped() {
        guard let model = model else { return }
        model.toggleFiatInput()
        inputs.toggleInput(usingFiat: model.isUsingFiat)
        updatedInput()
    }
    
    func ratesViewTapped() {
        
    }
    
    func useMinimumAmount() {
        
    }
    
    func useMaximumAmount() {
        
    }
    
    func onBackspaceTapped() {
        guard inputs.canBackspace() else {
            output?.entryRejected()
            return
        }
        inputs.backspace()
        updatedInput()
    }
    
    func onAddInputTapped(value: String) {
        guard let _ = model else {
            Logger.shared.error("Updating conversion with no model")
            return
        }
        
        guard canAddAdditionalCharacter(value) == true else {
            output?.entryRejected()
            return
        }
        
        inputs.add(
            character: value
        )
        
        updatedInput()
    }
    
    func onDelimiterTapped(value: String) {
        guard inputs.canAddDelimiter() else {
            output?.entryRejected()
            return
        }
        
        guard let model = model else { return }
        
        let text = model.isUsingFiat ? "00" : value
        
        inputs.add(
            delimiter: text
        )
        
        updatedInput()
    }
    
    fileprivate func canAddAdditionalCharacter(_ value: String) -> Bool {
        guard let model = model else { return false }
        switch model.isUsingFiat {
        case true:
            return inputs.canAddFiatCharacter(value)
        case false:
            return inputs.canAddAssetCharacter(value)
        }
    }
}
