//
//  ExchangeCreatePresenter.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreatePresenter {
    fileprivate let interactor: ExchangeCreateInteractor
    weak var interface: ExchangeCreateInterface?

    init(interactor: ExchangeCreateInteractor) {
        self.interactor = interactor
    }
}

extension ExchangeCreatePresenter: ExchangeCreateDelegate {
    func onViewLoaded() {
        interactor.viewLoaded()
    }
    
    func onDelimiterTapped(value: String) {
        interactor.onDelimiterTapped(value: value)
    }

    func onAddInputTapped(value: String) {
        interactor.onAddInputTapped(value: value)
    }

    func onBackspaceTapped() {
        interactor.onBackspaceTapped()
    }

    func changeTradingPair(tradingPair: TradingPair) {
        interactor.changeTradingPair(tradingPair: tradingPair)
    }

    func onToggleFixTapped() {
        interactor.toggleFix()
    }

    func onDisplayInputTypeTapped() {
        interactor.displayInputTypeTapped()
    }

    func onExchangeButtonTapped() {
        interactor.confirmConversion()
    }

    func confirmConversion() {
        interactor.confirmConversion()
    }
}

extension ExchangeCreatePresenter: ExchangeCreateOutput {
    func updateTradingPair(pair: TradingPair, fix: Fix) {
        interface?.updateTradingPairView(pair: pair, fix: fix)
    }

    func entryRejected() {
        interface?.wigglePrimaryLabel()
    }
    
    func styleTemplate() -> ExchangeStyleTemplate {
        return interface?.styleTemplate() ?? .standard
    }
    
    func updatedInput(primary: NSAttributedString?, secondary: String?) {
        interface?.updateAttributedPrimary(primary, secondary: secondary)
    }
    
    func updatedInput(primary: String?, primaryDecimal: String?, secondary: String?) {
        interface?.updateInputLabels(primary: primary, primaryDecimal: primaryDecimal, secondary: secondary)
    }
    
    func updatedRates(first: String, second: String, third: String) {
        
    }
    
    func updateTradingPairValues(left: String, right: String) {
        interface?.updateTradingPairViewValues(left: left, right: right)
    }

    func loadingVisibility(_ visibility: Visibility, action: ExchangeCreateViewController.Action) {
        interface?.loadingVisibility(visibility, action: action)
    }

    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion) {
        interface?.showSummary(orderTransaction: orderTransaction, conversion: conversion)
    }
}
