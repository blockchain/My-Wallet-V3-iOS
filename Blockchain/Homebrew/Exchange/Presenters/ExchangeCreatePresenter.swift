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
        
        interface?.conversionViewVisibility(.visible, animated: false)
        interface?.keypadViewVisibility(.visible, animated: false)
        interface?.exchangeButtonVisibility(.visible, animated: false)
        
        interface?.ratesViewVisibility(.hidden, animated: false)
        interface?.ratesChevronButtonVisibility(.hidden, animated: false)
    }
    
    func onDisplayRatesTapped() {
        interface?.conversionViewVisibility(.hidden, animated: true)
        interface?.keypadViewVisibility(.hidden, animated: true)
        interface?.exchangeButtonVisibility(.hidden, animated: true)
    }
    
    func onHideRatesTapped() {
        interface?.conversionViewVisibility(.visible, animated: true)
        interface?.ratesViewVisibility(.hidden, animated: true)
        interface?.ratesChevronButtonVisibility(.hidden, animated: true)
        
        interface?.keypadViewVisibility(.visible, animated: true)
        interface?.exchangeButtonVisibility(.visible, animated: true)
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
    
    func onKeypadVisibilityUpdated(_ visibility: Visibility, animated: Bool) {
        let ratesViewVisibility: Visibility = visibility == .hidden ? .visible : .hidden
        interface?.ratesViewVisibility(ratesViewVisibility, animated: animated)
        interface?.ratesChevronButtonVisibility(ratesViewVisibility, animated: animated)
    }

    func changeMarketPair(marketPair: MarketPair) {
        interactor.changeMarketPair(marketPair: marketPair)
    }

    func onToggleFixTapped() {
        interactor.toggleFix()
    }

    func onUseMinimumTapped(assetAccount: AssetAccount) {
        interactor.useMinimumAmount(assetAccount: assetAccount)
    }

    func onUseMaximumTapped(assetAccount: AssetAccount) {
        interactor.useMaximumAmount(assetAccount: assetAccount)
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
        interface?.updateRateLabels(first: first, second: second, third: third)
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
