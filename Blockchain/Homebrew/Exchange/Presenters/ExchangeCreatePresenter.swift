//
//  ExchangeCreatePresenter.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ExchangeStyleTemplate {
    let primaryFont: UIFont
    let secondaryFont: UIFont
    let textColor: UIColor
    let pendingColor: UIColor
    var type: InputType
    
    enum InputType {
        case fiat
        case nonfiat
    }
    
    init(primaryFont: UIFont, secondaryFont: UIFont, textColor: UIColor, pendingColor: UIColor, type: InputType = .fiat) {
        self.primaryFont = primaryFont
        self.secondaryFont = secondaryFont
        self.textColor = textColor
        self.pendingColor = pendingColor
        self.type = type
    }
    
    var offset: CGFloat {
        return primaryFont.capHeight - secondaryFont.capHeight
    }
    
    private static let primary = UIFont(
        name: ExchangeCreateViewController.primaryFontName,
        size: ExchangeCreateViewController.primaryFontSize
        ) ?? UIFont.systemFont(ofSize: 17.0)
    
    private static let secondary = UIFont(
        name: ExchangeCreateViewController.secondaryFontName,
        size: ExchangeCreateViewController.secondaryFontSize
        ) ?? UIFont.systemFont(ofSize: 17.0)
    
    static let standard: ExchangeStyleTemplate = ExchangeStyleTemplate(
        primaryFont: primary,
        secondaryFont: secondary,
        textColor: .brandPrimary,
        pendingColor: UIColor.brandPrimary.withAlphaComponent(0.5),
        type: .fiat
    )
}

class ExchangeCreatePresenter {
    fileprivate let interactor: ExchangeCreateInput
    weak var interface: ExchangeCreateInterface?

    init(interactor: ExchangeCreateInput) {
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
    
    func onContinueButtonTapped() {
        
    }

    func onDisplayInputTypeTapped() {
        interactor.displayInputTypeTapped()
    }
}

extension ExchangeCreatePresenter: ExchangeCreateOutput {
    func entryRejected() {
        interface?.wigglePrimaryPrimaryLabel()
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
}
