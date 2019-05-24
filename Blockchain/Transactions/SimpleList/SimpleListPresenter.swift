//
//  SimpleListPresenter.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

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
        interactor.selected(item)
    }

    func onPullToRefresh() {
        interface?.emptyStateVisibility(.hidden)
        interface?.refreshControlVisibility(.visible)
        interactor.refresh()
    }
}

extension SimpleListPresenter: SimpleListOutput {
    func showItemDetails(_ item: Identifiable) {
        interface?.loadingIndicatorVisibility(.hidden)
        interface?.showItemDetails(item: item)
    }
    
    func willApplyUpdate() {
        interface?.loadingIndicatorVisibility(.visible)
    }

    func didApplyUpdate() {
        interface?.loadingIndicatorVisibility(.hidden)
    }

    func loadedItems(_ items: [Identifiable]) {
        interface?.emptyStateVisibility(.hidden)
        interface?.refreshControlVisibility(.hidden)
        interface?.display(results: items)
    }

    func appendItems(_ items: [Identifiable]) {
        interface?.emptyStateVisibility(.hidden)
        interface?.paginationActivityIndicatorVisibility(.hidden)
        interface?.append(results: items)
    }

    func refreshedItems(_ items: [Identifiable]) {
        interface?.emptyStateVisibility(.hidden)
        interface?.refreshControlVisibility(.hidden)
        interface?.display(results: items)
    }

    func itemFetchFailed(error: Error?) {
        Logger.shared.error(error?.localizedDescription ?? "Unknown error")
        interface?.refreshControlVisibility(.hidden)

        if let serviceError = error as? StellarServiceError {
            switch serviceError {
            case .noDefaultAccount,
                     .noXLMAccount:
                interface?.emptyStateVisibility(.visible)
            default:
                interface?.emptyStateVisibility(.hidden)
            }
        } else {
            interface?.showError(message: LocalizationConstants.Errors.genericError)
        }

        interface?.refreshAfterFailedFetch()
    }
}
