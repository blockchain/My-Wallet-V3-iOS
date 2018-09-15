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
    weak var output: ExchangeCreateOutput? {
        didSet {
            // output is not set during ExchangeCreateInteractor initialization,
            // so the first update to the trading pair view is done here
            didSetModel(oldModel: nil)
        }
    }
    fileprivate let inputs: ExchangeInputsAPI
    fileprivate let markets: ExchangeMarketsAPI
    fileprivate let conversions: ExchangeConversionAPI
    private var model: MarketsModel? {
        didSet {
            didSetModel(oldModel: oldValue)
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

    func didSetModel(oldModel: MarketsModel?) {
        // Only update TradingPair in Trading Pair View if it is different
        // from the old TradingPair
        if let model = model {
            if oldModel == nil ||
               (oldModel != nil && oldModel!.pair != model.pair) {
                output?.updateTradingPair(pair: model.pair, fix: model.fix)
            }
        }
        // TICKET: IOS-1287 - This should be called after user has stopped typing
        if markets.hasAuthenticated {
            updateMarketsConversion()
        }
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
            guard let model = this.model, model.pair.stringRepresentation == conversion.quote.pair else {
                Logger.shared.error("Pair returned from conversion is different from model pair")
                return
            }

            // Use conversions service to determine new input/output
            this.conversions.update(with: conversion)

            // Update interface to reflect the values returned from the conversion
            // Update input labels
            this.updateOutput()

            // Update trading pair view values
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
        model.volume = inputs.activeInput

        // Update interface to reflect what has been typed
        updateOutput()

        // Re-subscribe to socket with new volume value
        updateMarketsConversion()
    }

    func updateOutput() {
        // Update the inputs in crypto and fiat
        guard let output = output else { return }
        guard let model = model else { return }
        let symbol = NumberFormatter.localCurrencyFormatter.currencySymbol ?? "$"
        let suffix = model.pair.from.symbol
        
        let secondaryAmount = conversions.output.count == 0 ? "0.00": conversions.output
        let secondaryResult = model.isUsingFiat ? (secondaryAmount + " " + suffix) : (symbol + secondaryAmount)
        
        if model.isUsingFiat == true {
            let primary = inputs.primaryFiatAttributedString()
            output.updatedInput(primary: primary, secondary: conversions.output)
        } else {
            let symbol = model.pair.from.symbol
            let primary = inputs.primaryAssetAttributedString(symbol: symbol)
            output.updatedInput(primary: primary, secondary: secondaryResult)
        }
    }

    func updateTradingValues(left: String, right: String) {
        output?.updateTradingPairValues(left: left, right: right)
    }

    func displayInputTypeTapped() {
        guard let model = model else { return }
        model.toggleFiatInput()
        inputs.isUsingFiat = model.isUsingFiat
        inputs.toggleInput(withOutput: conversions.output)
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
