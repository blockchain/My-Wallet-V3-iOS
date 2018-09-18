//
//  ExchangeDetailInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 9/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class ExchangeDetailInteractor {
    var disposable: Disposable?
    fileprivate let markets: ExchangeMarketsAPI
    fileprivate let conversions: ExchangeConversionAPI
    fileprivate let tradeExecution: TradeExecutionAPI

    init(dependencies: ExchangeDependencies) {
        self.markets = dependencies.markets
        self.conversions = dependencies.conversions
        self.tradeExecution = dependencies.tradeExecution
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}

extension ExchangeDetailInteractor: ExchangeDetailInput {
    func viewLoaded() {

    }

    func sendOrderTapped() {

    }
}
