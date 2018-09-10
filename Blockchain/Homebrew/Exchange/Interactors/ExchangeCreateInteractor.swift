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
            this.conversions.update(with: conversion)
            this.inputs.activeInput.input = this.conversions.input
            this.inputs.lastOutput = this.conversions.output
            this.updateOutput()
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
        model.volume = Decimal(string: inputs.activeInput.input)!

        updateOutput()

        // Re-subscribe to socket with new volume value
        updateMarketsConversion()
    }

    func updateOutput() {
        // Update the inputs in crypto and fiat
        if model?.isUsingFiat == true {
            let components = inputs.inputComponents
            output?.updatedInput(
                primary: components.integer,
                primaryDecimal: components.fractional,
                secondary: inputs.lastOutput
            )
        } else {
            output?.updatedInput(
                primary: inputs.activeInput.input,
                primaryDecimal: nil,
                secondary: inputs.lastOutput
            )
        }

        // Update the amounts shown in the Trading Pair view
    }

    func displayInputTypeTapped() {
        model?.toggleFiatInput()
        inputs.toggleInput()
        updatedInput()
    }
    
    func ratesViewTapped() {
        
    }
    
    func useMinimumAmount() {
        
    }
    
    func useMaximumAmount() {
        
    }
    
    func onBackspaceTapped() {
        inputs.backspace()
        updatedInput()
    }
    
    func onAddInputTapped(value: String) {
        inputs.add(character: value)
        updatedInput()
    }
}
