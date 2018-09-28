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
    fileprivate let tradeExecution: TradeExecutionAPI

    weak var output: ExchangeDetailOutput?

    init(dependencies: ExchangeDependencies) {
        self.markets = dependencies.markets
        self.tradeExecution = dependencies.tradeExecution
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}

extension ExchangeDetailInteractor: ExchangeDetailInput {
    func viewLoaded() {
        disposable = markets.conversions.subscribe(onNext: { [weak self] conversion in
            guard let this = self else { return }
            this.output?.received(conversion: conversion)
        })
    }

    func sendOrderTapped() {

    }
}
