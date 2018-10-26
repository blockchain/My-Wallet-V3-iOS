//
//  SimpleListContracts.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SimpleListInterface: class {
    func paginationActivityIndicatorVisibility(_ visibility: Visibility)
    func refreshControlVisibility(_ visibility: Visibility)
    func display(results: [Identifiable])
    func append(results: [Identifiable])
    func enablePullToRefresh()
    func showItemDetails(item: Identifiable)
    func showError(message: String)
}

protocol SimpleListInput: class {
    func canPage() -> Bool
    func fetchAllItems()
    func refresh()
    func cancel()
    func itemSelectedWith(identifier: String) -> Identifiable?
    func nextPageBefore(identifier: String)
}

protocol SimpleListOutput: class {
    func willApplyUpdate()
    func didApplyUpdate()
    func loadedItems(_ items: [Identifiable])
    func appendItems(_ items: [Identifiable])
    func refreshedItems(_ items: [Identifiable])
    func itemWithIdentifier(_ identifier: String) -> Identifiable?
    func itemFetchFailed(error: Error?)
}
