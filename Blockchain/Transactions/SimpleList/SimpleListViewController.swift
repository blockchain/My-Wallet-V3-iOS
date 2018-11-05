//
//  SimpleListViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SimpleListDelegate: class {
    func onLoaded()
    func onDisappear()
    func onNextPageRequest(_ identifier: String)
    func onItemCellTapped(_ item: Identifiable)
    func onPullToRefresh()
}

// A view controller for a simple table view that is
// - refreshable by pulling down
// - able to trigger the next page by scrolling to the bottom

class SimpleListViewController: UIViewController, SimpleListInterface {

    // MARK: Public Properties

    weak var delegate: SimpleListDelegate?

    // MARK: Private IBOutlets

    // Cannot be fileprivate because it must be accessible by subclass
    @IBOutlet var tableView: UITableView!

    // MARK: Private Properties

    fileprivate var dataProvider: SimpleListDataProvider?
    fileprivate var presenter: SimpleListPresenter?

    // MARK: Factory

    class func make<
        T: SimpleListViewController,
        U: SimpleListDataProvider,
        V: SimpleListPresenter,
        W: SimpleListInteractor
    > (
        with type: T.Type,
        dataProvider: U.Type,
        presenter: V.Type,
        interactor: W
    ) -> T {
        let controller = T.makeFromStoryboard()
        
        let presenter = V.init(interactor: interactor)
        interactor.output = presenter
        controller.presenter = presenter

        let dataProvider = U.init()
        controller.dataProvider = dataProvider

        return controller
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider?.setupWithTable(table: tableView)
        dependenciesSetup()
        dataProvider?.delegate = self
        delegate?.onLoaded()
    }

    fileprivate func dependenciesSetup() {
        guard presenter == nil else {
            presenter?.interface = self
            delegate = presenter
            return
        }
        let interactor = SimpleListInteractor()
        presenter = SimpleListPresenter(interactor: interactor)
        presenter?.interface = self
        interactor.output = presenter
        delegate = presenter
    }
    
    func loadingIndicatorVisibility(_ visibility: Visibility) {
        switch visibility {
        case .visible:
            LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.loading)
        case .hidden, .translucent:
            LoadingViewPresenter.shared.hideBusyView()
        }
    }
    
    func paginationActivityIndicatorVisibility(_ visibility: Visibility) {
        dataProvider?.isPaging = visibility == .visible
    }
    
    func refreshControlVisibility(_ visibility: Visibility) {
        dataProvider?.isRefreshing = visibility.isHidden == false
    }
    
    func display(results: [Identifiable]) {
        dataProvider?.set(listModels: results)
    }
    
    func append(results: [Identifiable]) {
        dataProvider?.append(listModels: results)
    }
    
    func enablePullToRefresh() {
        dataProvider?.setupPullToRefresh()
    }
    
    func showItemDetails(item: Identifiable) {
        // in ExchangeList example, message is sent to coordinator
    }
    
    func emptyStateVisibility(_ visibility: Visibility) {
        
    }
    
    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message)
    }

    func refreshAfterFailedFetch() {
    }
}

extension SimpleListViewController: SimpleListDataProviderDelegate {
    func dataProvider(_ dataProvider: SimpleListDataProvider, nextPageBefore identifier: String) {
        delegate?.onNextPageRequest(identifier)
    }

    func dataProvider(_ dataProvider: SimpleListDataProvider, didSelect item: Identifiable) {
        delegate?.onItemCellTapped(item)
    }

    func refreshControlTriggered(_ dataProvider: SimpleListDataProvider) {
        delegate?.onPullToRefresh()
    }

    var estimatedCellHeight: CGFloat {
        return 44.0
    }
}
