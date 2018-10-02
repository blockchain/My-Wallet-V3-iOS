//
//  ExchangeCreatePresenter.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreatePresenter {
    
    typealias ViewUpdate = ExchangeCreateViewController.ViewUpdate
    typealias TransitionUpdate = ExchangeCreateViewController.TransitionUpdate
    typealias AnimatableGroup  = AnimatablePresentationUpdateGroup<ViewUpdate, ViewUpdate>
    typealias TransitionGroup = TransitionPresentationUpdateGroup<TransitionUpdate, TransitionUpdate>
    
    fileprivate let interactor: ExchangeCreateInteractor
    weak var interface: ExchangeCreateInterface?

    init(interactor: ExchangeCreateInteractor) {
        self.interactor = interactor
    }
}

extension ExchangeCreatePresenter: ExchangeCreateDelegate {
    
    func onViewLoaded() {
        interactor.viewLoaded()
        
        interface?.apply(
            presentationUpdates:[
                .conversionRatesView(.hidden, animated: false),
                .keypadVisibility(.visible, animated: false),
            ]
        )
        
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [
                    .exchangeButton(.visible),
                    .conversionView(.visible),
                    .ratesChevron(.hidden)],
                animation: .none)
        )
    }
    
    func onDisplayRatesTapped() {
        interface?.apply(
            presentationUpdates:[
                .conversionRatesView(.visible, animated: true),
                .keypadVisibility(.hidden, animated: true),
                ]
        )
        
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [.exchangeButton(.hidden),
                             .conversionView(.hidden)],
                animation: .easeIn(duration: 0.2)
            )
        )
    }
    
    func onHideRatesTapped() {
        interface?.apply(
            presentationUpdates:[
                .conversionRatesView(.hidden, animated: true),
                .keypadVisibility(.visible, animated: true),
                ]
        )
        
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [
                    .conversionView(.visible),
                    .ratesChevron(.hidden),
                    .exchangeButton(.visible)
                ],
                animation: .easeIn(duration: 0.2)
            )
        )
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
        interface?.apply(presentationUpdates: [.conversionRatesView(ratesViewVisibility, animated: animated)])
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [.ratesChevron(ratesViewVisibility)],
                animation: .easeIn(duration: 0.2)
            )
        )
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
        guard interactor.confirmationIsExecuting() == false else { return }
        interactor.confirmConversion()
    }

    func confirmConversion() {
        guard interactor.confirmationIsExecuting() == false else { return }
        interactor.confirmConversion()
    }
}

extension ExchangeCreatePresenter: ExchangeCreateOutput {
    func entryBelowMinimumValue(minimum: String) {
        
    }
    
    func entryAboveMaximumValue(maximum: String) {
        
    }
    
    func updateTradingPair(pair: TradingPair, fix: Fix) {
        interface?.updateTradingPairView(pair: pair, fix: fix)
    }

    func entryRejected() {
        interface?.apply(presentationUpdates: [.wigglePrimaryLabel])
    }
    
    func styleTemplate() -> ExchangeStyleTemplate {
        return interface?.styleTemplate() ?? .standard
    }
    
    func updatedInput(primary: NSAttributedString?, secondary: String?) {
        interface?.apply(presentationUpdates: [
            .updatePrimaryLabel(primary),
            .updateSecondaryLabel(secondary)
            ]
        )
    }
    
    func updatedRates(first: String, second: String, third: String) {
        interface?.apply(presentationUpdates: [.updateRateLabels(first: first, second: second, third: third)])
    }
    
    func updateTradingPairValues(left: String, right: String) {
        interface?.updateTradingPairViewValues(left: left, right: right)
    }

    func loadingVisibility(_ visibility: Visibility) {
        interface?.apply(presentationUpdates: [.loadingIndicator(visibility)])
    }

    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion) {
        interface?.showSummary(orderTransaction: orderTransaction, conversion: conversion)
    }
}
