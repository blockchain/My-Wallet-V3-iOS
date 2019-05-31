//
//  ExchangeCreatePresenter.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit
import PlatformKit

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
    fileprivate var currentRateDescriptionType: ExchangeRateDescriptionType = .fromAssetToFiat
    fileprivate var recycleRateTimer: Timer?
    fileprivate var ratesMetadata: ExchangeRateMetadata?
    
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
    
    internal func hideError() {
        interface?.apply(
            transitionPresentation: ExchangeCreateInterface.AnimatedTransitionUpdate(
                transitions: [.primaryLabelTextColor(.brandPrimary)],
                transition: .crossFade(duration: 0.2)
            )
        )
    }
    
    fileprivate func displayError() {
        // TODO:
    }

    fileprivate func disableExchangeButton() {
        interface?.exchangeButtonEnabled(false)
    }
    
    fileprivate func enableExchangeButton() {
        interface?.exchangeButtonEnabled(true)
        exchangeButtonVisibility(.visible)
    }
    
    fileprivate func displayTiers() {
        interface?.showTiers()
    }
    
    fileprivate func cancelRatesTimer() {
        recycleRateTimer?.invalidate()
        recycleRateTimer = nil
    }
    
    fileprivate func setRatesRecycleTimer(duration: TimeInterval) {
        guard recycleRateTimer == nil else { return }
        recycleRateTimer = Timer(
            timeInterval: duration,
            repeats: true,
            block: { [weak self] _ in
                guard let self = self else { return }
                self.recycleRatesTimerFired()
                self.currentRateDescriptionType = self.currentRateDescriptionType.next()
        })
        guard let timer = recycleRateTimer else { return }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    fileprivate func recycleRatesTimerFired() {
        guard let metadata = ratesMetadata else { return }
        let font = Font(.branded(.montserratSemiBold), size: .custom(12.0)).result
        let attributedText = metadata.description(
            for: currentRateDescriptionType,
            font: font,
            fromColor: .brandPrimary,
            toColor: .darkGray
        )
        
        interface?.apply(
            transitionPresentation: ExchangeCreateInterface.AnimatedTransitionUpdate(
                transitions: [.updateConversionRateLabel(attributedText)],
                transition: .crossFade(duration: 0.5)
            )
        )
    }
}

extension ExchangeCreatePresenter: ExchangeCreateDelegate {
    
    func onViewDidLoad() {
        interactor.setup()
        interactor.resume()
    }
    
    func onViewWillAppear() {
        AnalyticsService.shared.trackEvent(title: "exchange_create")
        interactor.resume()
    }
    
    func onViewDidDisappear() {
        cancelRatesTimer()
    }
    
    func onDisplayRatesTapped() {
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [.exchangeButton(.hidden)],
                animation: .easeIn(duration: 0.2)
            )
        )
    }
    
    func onDelimiterTapped() {
        interactor.onDelimiterTapped()
    }

    func onAddInputTapped(value: String) {
        interactor.onAddInputTapped(value: value)
    }

    func onBackspaceTapped() {
        interactor.onBackspaceTapped()
    }

    func changeMarketPair(marketPair: MarketPair) {
        interactor.changeMarketPair(marketPair: marketPair)
    }

    func onToggleFixTapped() {
        interactor.toggleFix()
    }

    func onExchangeButtonTapped() {
        guard interactor.confirmationIsExecuting() == false else { return }
        interactor.confirmConversion()
    }
    
    func onSwapButtonTapped() {
        AnalyticsService.shared.trackEvent(title: "swap_tiers")
        displayTiers()
    }
    
    var rightNavigationCTAType: NavigationCTAType {
        switch interactor.status {
        case .error(let value):
            return value == .noVolumeProvided ? .help : .error
        case .inflight:
            return .activityIndicator
        case .unknown,
             .valid:
             return .help
        }
    }
}

extension ExchangeCreatePresenter: ExchangeCreateOutput {
    func tradeValidationInFlight() {
        disableExchangeButton()
        interface?.exchangeStatusUpdated()
    }
    
    var status: ExchangeInteractorStatus {
        return interactor.status
    }
    
    func errorReceived() {
        disableExchangeButton()
        interface?.exchangeStatusUpdated()
    }
    
    func errorDismissed() {
        enableExchangeButton()
        interface?.exchangeButtonEnabled(true)
        interface?.exchangeStatusUpdated()
    }
    
    func entryAboveTierLimit(amount: String) {
        let triggerText = String(format: LocalizationConstants.Swap.tierlimitErrorMessage, amount)
        let trigger = ActionableTrigger(text: triggerText, CTA: LocalizationConstants.Swap.upgradeNow, secondary: nil) { [weak self] in
            guard let this = self else { return }
            this.displayTiers()
        }
        interface?.apply(presentationUpdates: [.actionableErrorLabelTrigger(trigger)])
        displayError()
        disableExchangeButton()
    }
    
    func updateTradingPair(pair: TradingPair, fix: Fix) {
        interface?.updateTradingPairView(pair: pair, fix: fix)
    }

    func entryRejected() {
        interface?.apply(presentationUpdates: [.wigglePrimaryLabel])
    }
    
    func updatedInput(primary: NSAttributedString?, secondary: String?) {
        interface?.apply(presentationUpdates: [
            .updatePrimaryLabel(primary),
            .updateSecondaryLabel(secondary)
            ]
        )
    }
    
    func updateRateMetadata(_ metadata: ExchangeRateMetadata) {
        self.ratesMetadata = metadata
        setRatesRecycleTimer(duration: 4.5)
    }
    
    func updateBalance(cryptoValue: CryptoValue, fiatValue: FiatValue) {
        let font = Font(.branded(.montserratSemiBold), size: .custom(12.0)).result
        let first = NSAttributedString(
            string: "Your \(cryptoValue.currencyType.symbol) Balance",
            attributes: [.font: font,
                         .foregroundColor: UIColor.brandPrimary]
        )
        let fiat = NSAttributedString(
            string: fiatValue.toDisplayString(includeSymbol: true, locale: .current),
            attributes: [.font: font,
                         .foregroundColor: UIColor.green]
        )
        let asset = NSAttributedString(
            string: cryptoValue.toDisplayString(includeSymbol: true, locale: .current),
            attributes: [.font: font,
                         .foregroundColor: UIColor.darkGray]
        )
        let second = [fiat, asset].join(withSeparator: .space())
        let result = [first, second].join(withSeparator: .lineBreak())
        interface?.apply(
            transitionPresentation: ExchangeCreateInterface.AnimatedTransitionUpdate(
                transitions: [.updateBalanceLabel(result)],
                transition: .crossFade(duration: 0.5)
            )
        )
    }
    
    func updateTradingPairValues(left: String, right: String) {
        interface?.updateTradingPairViewValues(left: left, right: right)
    }

    func loadingVisibility(_ visibility: Visibility) {
        interface?.apply(presentationUpdates: [.loadingIndicator(visibility)])
    }

    func exchangeButtonVisibility(_ visibility: Visibility) {
        interface?.apply(
            animatedUpdate: ExchangeCreateInterface.AnimatedUpdate(
                animations: [.exchangeButton(visibility)],
                animation: .easeIn(duration: 0.2)
            )
        )
    }

    func exchangeButtonEnabled(_ enabled: Bool) {
        interface?.exchangeButtonEnabled(enabled)
    }

    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion) {
        interface?.showSummary(orderTransaction: orderTransaction, conversion: conversion)
    }
}
