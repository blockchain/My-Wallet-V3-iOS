//
//  ExchangeCreatePresenter.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreatePresenter {
    
    enum InternalEvent: CompletionEvent {
        case block(() -> Void)
    }
    
    typealias ViewUpdate = ExchangeCreateViewController.ViewUpdate
    typealias ViewUpdateGroup = AnimatablePresentationUpdateGroup<ViewUpdate, InternalEvent>
    typealias ViewUpdateBlock = UpdateCompletion<InternalEvent>
    typealias TransitionUpdate = ExchangeCreateViewController.TransitionUpdate
    typealias TransitionUpdateGroup = TransitionPresentationUpdateGroup<TransitionUpdate, InternalEvent>
    
    fileprivate let interactor: ExchangeCreateInteractor
    fileprivate let feedback: UINotificationFeedbackGenerator
    fileprivate var errorDisappearenceTimer: Timer?
    weak var interface: ExchangeCreateInterface?

    init(interactor: ExchangeCreateInteractor) {
        self.interactor = interactor
        self.feedback = UINotificationFeedbackGenerator()
    }
    
    // MARK: Private Functions
    
    fileprivate func handle(internalEvent: InternalEvent) {
        switch internalEvent {
        case .block(let block):
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    fileprivate func wigglePrimaryLabel() {
        feedback.prepare()
        interface?.apply(presentationUpdates: [.wigglePrimaryLabel])
        feedback.notificationOccurred(.error)
    }
    
    fileprivate func cancelErrorDisappearanceTimer() {
        errorDisappearenceTimer?.invalidate()
        errorDisappearenceTimer = nil
    }
    
    fileprivate func setErrorDisappearanceTimer(duration: TimeInterval) {
        errorDisappearenceTimer?.invalidate()
        errorDisappearenceTimer = Timer(
            fire: Date(timeIntervalSinceNow: duration),
            interval: 0,
            repeats: false,
            block: { [weak self] timer in
                self?.errorDisappearanceTimerFired()
        })
        guard let timer = errorDisappearenceTimer else { return }
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    fileprivate func errorDisappearanceTimerFired() {
        interface?.apply(animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
            animations: [.secondaryLabel(.visible)],
            animation: .none
            )
        )
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [.errorLabel(.hidden)],
                animation: .standard(duration: 0.2)
            )
        )
        
        interface?.apply(
            transitionPresentation: ExchangeCreateInterface.AnimatedTransitionUpdate(
                transitions: [.primaryLabelTextColor(.brandPrimary)],
                transition: .crossFade(duration: 0.2)
            )
        )
    }
    
    fileprivate func displayError() {
        let completion: ViewUpdateBlock = { [weak self] internalEvents in
            guard let this = self else { return }
            guard let events = internalEvents else { return }
            events.forEach({ this.handle(internalEvent: $0) })
        }
        
        let group = ViewUpdateGroup(
            preparations: [.secondaryLabel(.hidden)],
            animations: [.errorLabel(.visible)],
            animation: .standard(duration: 0.2),
            completionEvents: [],
            completion: completion
        )
        interface?.apply(presentationUpdateGroup: group)
        interface?.exchangeEnabled(false)
    }
    
    fileprivate func triggerErrorFeedback() {
        let completion: ViewUpdateBlock = { [weak self] internalEvents in
            guard let this = self else { return }
            guard let events = internalEvents else { return }
            events.forEach({ this.handle(internalEvent: $0) })
        }
        
        let block = { [weak self] in
            guard let this = self else { return }
            this.wigglePrimaryLabel()
        }
        
        let group = TransitionUpdateGroup(
            transitions: [.primaryLabelTextColor(.red)],
            transitionType: .crossFade(duration: 0.2),
            completionEvents: [.block(block)],
            completion: completion
        )
        interface?.apply(transitionUpdateGroup: group)
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
                    .ratesChevron(.hidden),
                    .errorLabel(.hidden)],
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
    
    func insufficientFunds(balance: String) {
        interface?.apply(presentationUpdates: [.updateErrorLabel(balance)])
        displayError()
    }
    
    func entryBelowMinimumValue(minimum: String?) {
        let display = minimum == nil ? LocalizationConstants.Exchange.belowTradingLimit : LocalizationConstants.Exchange.yourMin + " " + minimum!
        interface?.apply(presentationUpdates: [.updateErrorLabel(display)])
        displayError()
    }
    
    func entryAboveMaximumValue(maximum: String?) {
        let display = maximum == nil ? LocalizationConstants.Exchange.aboveTradingLimit : LocalizationConstants.Exchange.yourMax + " " + maximum!
        interface?.apply(presentationUpdates: [.updateErrorLabel(display)])
        displayError()
    }

    func genericSocketError() {
        let display = LocalizationConstants.Errors.genericError
        interface?.apply(presentationUpdates: [.updateErrorLabel(display)])
        displayError()
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
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [.conversionTitleLabel(.visible)],
                animation: .standard(duration: 0.2)
            )
        )
    }
    
    func updateTradingPairValues(left: String, right: String) {
        interface?.updateTradingPairViewValues(left: left, right: right)
    }

    func loadingVisibility(_ visibility: Visibility) {
        interface?.apply(presentationUpdates: [.loadingIndicator(visibility)])
    }

    func exchangeEnabled(_ enabled: Bool) {
        errorDisappearanceTimerFired()
        interface?.exchangeEnabled(enabled)
    }

    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion) {
        interface?.showSummary(orderTransaction: orderTransaction, conversion: conversion)
    }
}
