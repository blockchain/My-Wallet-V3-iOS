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
    func onNumberButtonTapped(value: String) {
        
    }
    
    func onDecimalButtonTapped() {
        
    }

    func onBackspaceTapped() {
        
    }
    
    func onContinueButtonTapped() {
        
    }

    func onFiatToggleTapped() {
        interactor.toggleFiatInput()
    }
}

extension ExchangeCreatePresenter: ExchangeCreateOutput {
    func updatedInput(primary: String?, secondary: String?) {
        
    }
    
    func updatedRates(first: String, second: String, third: String) {
        
    }
}
