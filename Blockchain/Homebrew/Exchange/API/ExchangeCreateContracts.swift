//
//  ExchangeCreateContracts.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeCreateInterface: class {
    typealias ViewUpdate = ExchangeCreateViewController.ViewUpdate
    typealias AnimatedUpdate = AnimatablePresentationUpdate<ViewUpdate>
    typealias PresentationUpdate = ExchangeCreateViewController.PresentationUpdate
    
    typealias PresentationUpdateGroup = AnimatablePresentationUpdateGroup<
        ViewUpdate,
        ExchangeCreatePresenter.InternalEvent
    >
    typealias TransitionUpdate = ExchangeCreateViewController.TransitionUpdate
    typealias AnimatedTransitionUpdate = TransitionPresentationUpdate<TransitionUpdate>
    
    typealias TransitionUpdateGroup = TransitionPresentationUpdateGroup<
        TransitionUpdate,
        ExchangeCreatePresenter.InternalEvent
    >
    
    func styleTemplate() -> ExchangeStyleTemplate
    func updateTradingPairViewValues(left: String, right: String)
    func updateTradingPairView(pair: TradingPair, fix: Fix)
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion)
    
    func apply(presentationUpdateGroup: PresentationUpdateGroup)
    func apply(transitionUpdateGroup: TransitionUpdateGroup)
    
    func apply(presentationUpdates: [PresentationUpdate])
    func apply(animatedUpdate: AnimatedUpdate)
    func apply(transitionPresentation: AnimatedTransitionUpdate)

    func exchangeButtonEnabled(_ enabled: Bool)
}

// Conforms to NumberKeypadViewDelegate to avoid redundancy of keypad input methods
protocol ExchangeCreateInput: NumberKeypadViewDelegate {
    func viewLoaded()
    func displayInputTypeTapped()
    func useMinimumAmount(assetAccount: AssetAccount)
    func useMaximumAmount(assetAccount: AssetAccount)
    func confirmationIsExecuting() -> Bool
    func confirmConversion()
    func changeMarketPair(marketPair: MarketPair)
}

protocol ExchangeCreateOutput: class {
    func entryRejected()
    func styleTemplate() -> ExchangeStyleTemplate
    func updatedInput(primary: NSAttributedString?, secondary: String?)
    func updatedRates(first: String, second: String, third: String)
    func updateTradingPairValues(left: String, right: String)
    func updateTradingPair(pair: TradingPair, fix: Fix)
    func insufficientFunds(balance: String)
    func genericSocketError()
    func entryBelowMinimumValue(minimum: String?)
    func entryAboveMaximumValue(maximum: String?)
    func loadingVisibility(_ visibility: Visibility)
    func exchangeButtonEnabled(_ enabled: Bool)
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion)
}
