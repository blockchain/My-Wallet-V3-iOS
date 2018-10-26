//
//  SimpleListPresenter.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class SimpleListPresenter {
    fileprivate let interactor: SimpleListInput
    weak var interface: SimpleListInterface?

    required init(interactor: SimpleListInput) {
        self.interactor = interactor
    }
}

extension SimpleListPresenter: SimpleListDelegate {
    func onLoaded() {
        interface?.enablePullToRefresh()
        interface?.refreshControlVisibility(.visible)
        interactor.fetchAllItems()
    }

    func onDisappear() {
        interactor.cancel()
    }

    func onNextPageRequest(_ identifier: String) {
        guard interactor.canPage() else { return }
        interface?.paginationActivityIndicatorVisibility(.visible)
        interactor.nextPageBefore(identifier: identifier)
    }

    func onItemCellTapped(_ item: Identifiable) {
        interface?.showItemDetails(item: item)
    }

    func onPullToRefresh() {
        interface?.refreshControlVisibility(.visible)
        interactor.refresh()
    }
}

extension SimpleListPresenter: SimpleListOutput {
    func willApplyUpdate() {
        // TODO:
    }

    func didApplyUpdate() {
        // TODO:
    }

    func loadedItems(_ items: [Identifiable]) {
        interface?.refreshControlVisibility(.hidden)
        interface?.display(results: items)
    }

    func appendItems(_ items: [Identifiable]) {
        interface?.paginationActivityIndicatorVisibility(.hidden)
        interface?.append(results: items)
    }

    func refreshedItems(_ items: [Identifiable]) {
        interface?.refreshControlVisibility(.hidden)
        interface?.display(results: items)
    }

    func itemWithIdentifier(_ identifier: String) -> Identifiable? {
        return interactor.itemSelectedWith(identifier: identifier)
    }

    func itemFetchFailed(error: Error?) {
        Logger.shared.error(error?.localizedDescription ?? "Unknown error")
        interface?.refreshControlVisibility(.hidden)
        interface?.showError(message: LocalizationConstants.Errors.genericError)
    }
}
