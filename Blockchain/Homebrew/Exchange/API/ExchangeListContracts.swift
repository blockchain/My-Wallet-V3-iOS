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
    func display(results: [ExchangeTradeCellModel])
    func append(results: [ExchangeTradeCellModel])
    func enablePullToRefresh()
    func showNewExchange(animated: Bool)
}

protocol ExchangeListInput: class {
    func canPage() -> Bool
    func fetchAllTrades()
    func refresh()
    func tradeSelectedWith(identifier: String) -> ExchangeTradeCellModel?
    func nextPageBefore(identifier: String)
}

protocol ExchangeListOutput: class {
    func willApplyUpdate()
    func didApplyUpdate()
    func loadedTrades(_ trades: [ExchangeTradeCellModel])
    func appendTrades(_ trades: [ExchangeTradeCellModel])
    func refreshedTrades(_ trades: [ExchangeTradeCellModel])
    func tradeWithIdentifier(_ identifier: String) -> ExchangeTradeCellModel?
    func tradeFetchFailed(error: Error?)
}
