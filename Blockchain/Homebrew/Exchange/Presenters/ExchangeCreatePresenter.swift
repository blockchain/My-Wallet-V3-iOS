//
//  ExchangeCreatePresenter.swift
//  Blockchain
//
//  Created by kevinwu on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreatePresenter {
    fileprivate let interactor: ExchangeCreateInput
    weak var interface: ExchangeCreateInterface?

    init(interactor: ExchangeCreateInput) {
        self.interactor = interactor
    }
}

extension ExchangeCreatePresenter: ExchangeCreateDelegate {
    func onAddInputTapped(value: String) {
        interactor.onAddInputTapped(value: value)
    }

    func onBackspaceTapped() {
        interactor.onBackspaceTapped()
    }
    
    func onContinueButtonTapped() {
        
    }

    func onFiatToggleTapped() {
        interactor.displayInputTypeTapped()
    }
}

extension ExchangeCreatePresenter: ExchangeCreateOutput {
    func updatedInput(primary: String?, secondary: String?) {
         interface?.updateInputLabels(primary: primary, secondary: secondary)
    }
    
    func updatedRates(first: String, second: String, third: String) {
        
    }
}
