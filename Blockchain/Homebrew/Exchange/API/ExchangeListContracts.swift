//
//  ExchangeListContracts.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeListInterface: class {
    func paginationActivityIndicatorVisibility(_ visibility: Visibility)
    func refreshControlVisibility(_ visibility: Visibility)
    func display(results: [ExchangeTradeModel])
    func append(results: [ExchangeTradeModel])
    func enablePullToRefresh()
    func showNewExchange(animated: Bool)
    func showTradeDetails(trade: ExchangeTradeModel)
}

protocol ExchangeListInput: class {
    func canPage() -> Bool
    func fetchAllTrades()
    func refresh()
    func tradeSelectedWith(identifier: String) -> ExchangeTradeModel?
    func nextPageBefore(identifier: String)
}

protocol ExchangeListOutput: class {
    func willApplyUpdate()
    func didApplyUpdate()
    func loadedTrades(_ trades: [ExchangeTradeModel])
    func appendTrades(_ trades: [ExchangeTradeModel])
    func refreshedTrades(_ trades: [ExchangeTradeModel])
    func tradeWithIdentifier(_ identifier: String) -> ExchangeTradeModel?
    func tradeFetchFailed(error: Error?)
}
