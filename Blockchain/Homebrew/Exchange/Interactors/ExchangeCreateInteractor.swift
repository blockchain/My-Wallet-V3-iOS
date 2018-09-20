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
    fileprivate let tradeExecution: TradeExecutionAPI
    fileprivate let tradeLimitService: TradeLimitsAPI
    private(set) var model: MarketsModel? {
        didSet {
            didSetModel(oldModel: oldValue)
        }
    }

    init(dependencies: ExchangeDependencies, model: MarketsModel) {
        self.markets = dependencies.markets
        self.inputs = dependencies.inputs
        self.conversions = dependencies.conversions
        self.tradeExecution = dependencies.tradeExecution
        self.tradeLimitService = dependencies.tradeLimits
        self.model = model
    }

    func didSetModel(oldModel: MarketsModel?) {
        // TICKET: IOS-1287 - This should be called after user has stopped typing
        if markets.hasAuthenticated {
            updateMarketsConversion()
        }

        // Only update TradingPair in Trading Pair View if it is different
        // from the old TradingPair
        guard let model = model else { return }

        if let oldModel = oldModel {
            if oldModel.pair != model.pair || oldModel.fix != model.fix {
                output?.updateTradingPair(pair: model.pair, fix: model.fix)
            }
        } else {
            output?.updateTradingPair(pair: model.pair, fix: model.fix)
        }
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}

extension ExchangeCreateInteractor: ExchangeCreateInput {

    fileprivate enum TradingLimit {
        case min
        case max
    }
    
    func viewLoaded() {
        guard let output = output else { return }
        guard let model = model else { return }
        inputs.setup(with: output.styleTemplate(), usingFiat: model.isUsingFiat)
        
        updatedInput()
        
        markets.setup()
        tradeLimitService.initialize(withFiatCurrency: model.fiatCurrency)

        // Authenticate, then listen for conversions
        markets.authenticate(completion: { [unowned self] in
            self.subscribeToConversions()
            self.updateMarketsConversion()
        })
    }

    func subscribeToConversions() {
        disposable = markets.conversions.subscribe(onNext: { [weak self] conversion in
            guard let this = self else { return }

            guard let model = this.model else { return }

            guard model.pair.stringRepresentation == conversion.quote.pair else {
                Logger.shared.warning(
                    "Pair '\(conversion.quote.pair)' is different from model pair '\(model.pair.stringRepresentation)'."
                )
                return
            }

            // Store conversion
            model.lastConversion = conversion

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

        if model.isUsingFiat {
            let primary = inputs.primaryFiatAttributedString()
            output.updatedInput(primary: primary, secondary: conversions.output)
        } else {
            let assetType = model.isUsingBase ? model.pair.from : model.pair.to
            let symbol = assetType.symbol
            let primary = inputs.primaryAssetAttributedString(symbol: symbol)
            output.updatedInput(primary: primary, secondary: secondaryResult)
        }
        
        guard let conversion = model.lastConversion else { return }
        
        output.updatedRates(
            first: conversion.baseToCounterDescription,
            second: conversion.baseToFiatDescription,
            third: conversion.counterToFiatDescription
        )
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
        applyTradingLimit(limit: .min)
    }
    
    func useMaximumAmount() {
        applyTradingLimit(limit: .max)
    }

    func toggleFix() {
        guard let model = model else { return }
        model.toggleFix()
        model.lastConversion = nil
        clearInputs()
        updatedInput()
        output?.updateTradingPair(pair: model.pair, fix: model.fix)
    }
    
    func onBackspaceTapped() {
        guard inputs.canBackspace() else {
            output?.entryRejected()
            return
        }

        inputs.backspace()

        // Clear conversions if the user backspaced all the way to 0
        if !inputs.canBackspace() {
            clearInputs()
        }

        updatedInput()
    }

    func onAddInputTapped(value: String) {
        guard model != nil else {
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

    func changeTradingPair(tradingPair: TradingPair) {
        guard let model = model else { return }

        // Unsubscribe from old pair conversions
        Logger.shared.debug("Unsubscribing from old currency pair '\(model.pair.stringRepresentation)'")
        markets.unsubscribeToCurrencyPair(pair: model.pair.stringRepresentation)

        // Update to new pair
        model.pair = tradingPair
        updatedInput()
        output?.updateTradingPair(pair: model.pair, fix: model.fix)
    }

    func confirmConversion() {
        guard let conversion = self.model?.lastConversion else {
            Logger.shared.error("No conversion stored")
            return
        }

        output?.loadingVisibility(.visible, action: ExchangeCreateViewController.Action.createPayment)

        // Submit order to get payment information
        tradeExecution.submitOrder(with: conversion, success: { [weak self] orderTransaction, conversion in
            guard let this = self else { return }
            this.output?.loadingVisibility(.hidden, action: ExchangeCreateViewController.Action.createPayment)
            this.output?.showSummary(orderTransaction: orderTransaction, conversion: conversion)
        }, error: { [weak self] errorMessage in
            guard let this = self else { return }
            AlertViewPresenter.shared.standardError(message: errorMessage)
            this.output?.loadingVisibility(.hidden, action: ExchangeCreateViewController.Action.createPayment)
        })
    }

    // MARK: - Private

    private func applyTradingLimit(limit: TradingLimit) {
        guard let model = model else { return }

        model.fix = .baseInFiat
        model.lastConversion = nil
        inputs.isUsingFiat = true
        clearInputs()
        output?.updateTradingPair(pair: model.pair, fix: model.fix)

        tradeLimitService.getTradeLimits(withFiatCurrency: model.fiatCurrency) { [weak self] limitsResult in
            guard let strongSelf = self else { return }

            guard case let .success(limits) = limitsResult else { return }

            let limitString = (limit == .min) ? limits.minOrder.description : limits.maxPossibleOrder.description
            limitString.unicodeScalars.forEach { char in
                let charStringValue = String(char)
                if CharacterSet.decimalDigits.contains(char) {
                    strongSelf.onAddInputTapped(value: charStringValue)
                } else if "." == charStringValue {
                    strongSelf.onDelimiterTapped(value: charStringValue)
                }
            }
        }
    }

    private func clearInputs() {
        inputs.clear()
        conversions.clear()
        output?.updateTradingPairValues(left: "", right: "")
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
