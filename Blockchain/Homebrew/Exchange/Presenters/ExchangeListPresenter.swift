//
//  ExchangeListPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeListPresenter {
    fileprivate let interactor: ExchangeListInput
    weak var interface: ExchangeListInterface?
    
    init(interactor: ExchangeListInput) {
        self.interactor = interactor
    }
}

extension ExchangeListPresenter: ExchangeListDelegate {
    func onAppeared() {
        interface?.refreshControlVisibility(.visible)
        interactor.fetchAllTrades()
    }
    
    func onNextPageRequest(_ identifier: String) {
        guard interactor.canPage() else { return }
        interface?.paginationActivityIndicatorVisibility(.visible)
        interactor.nextPageBefore(identifier: identifier)
    }
    
    func onNewOrderTapped() {
        interface?.showNewExchange(animated: true)
    }
    
    func onPullToRefresh() {
        interface?.refreshControlVisibility(.visible)
        interactor.refresh()
    }
}

extension ExchangeListPresenter: ExchangeListOutput {
    func willApplyUpdate() {
        // TODO:
    }
    
    func didApplyUpdate() {
        // TODO:
    }
    
    func loadedTrades(_ trades: [ExchangeTradeCellModel]) {
        interface?.refreshControlVisibility(.hidden)
        if trades.count == 0 {
            interface?.showNewExchange(animated: false)
        } else {
            interface?.enablePullToRefresh()
            interface?.display(results: trades)
        }
    }
    
    func appendTrades(_ trades: [ExchangeTradeCellModel]) {
        interface?.paginationActivityIndicatorVisibility(.hidden)
        interface?.append(results: trades)
    }
    
    func refreshedTrades(_ trades: [ExchangeTradeCellModel]) {
        interface?.refreshControlVisibility(.hidden)
        interface?.display(results: trades)
    }
    
    func tradeWithIdentifier(_ identifier: String) -> ExchangeTradeCellModel? {
        return interactor.tradeSelectedWith(identifier: identifier)
    }
    
    func tradeFetchFailed(error: Error?) {
        // TODO:
    }
}
