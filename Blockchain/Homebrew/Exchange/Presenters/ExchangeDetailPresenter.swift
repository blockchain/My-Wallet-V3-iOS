//
//  ExchangeDetailPresenter.swift
//  Blockchain
//
//  Created by kevinwu on 9/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeDetailPresenter {
    fileprivate let interactor: ExchangeDetailInput
    weak var interface: ExchangeDetailInterface?

    init(interactor: ExchangeDetailInput) {
        self.interactor = interactor
    }
}

extension ExchangeDetailPresenter: ExchangeDetailDelegate {
    func onViewLoaded() {

    }
    
    func onSendOrderTapped() {

    }
}
