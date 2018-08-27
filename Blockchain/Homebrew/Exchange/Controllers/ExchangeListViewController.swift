//
//  ExchangeListViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeListDelegate: class {
    func onLoaded()
    func onNextPageRequest(_ identifier: String)
    func onNewOrderTapped()
    func onPullToRefresh()
}

class ExchangeListViewController: UIViewController {
    
    // MARK: Public Properties
    
    weak var delegate: ExchangeListDelegate?

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var tableView: UITableView!

    // MARK: Private Properties

    fileprivate var dataProvider: ExchangeListDataProvider?
    fileprivate var presenter: ExchangeListPresenter!
    fileprivate var dependencies: ExchangeDependencies!
    fileprivate var coordinator: ExchangeCoordinator!
    
    // MARK: Factory
    
    class func make(with dependencies: ExchangeDependencies, coordinator: ExchangeCoordinator) -> ExchangeListViewController {
        let controller = ExchangeListViewController.makeFromStoryboard()
        controller.dependencies = dependencies
        controller.coordinator = coordinator
        return controller
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataProvider = ExchangeListDataProvider(table: tableView)
        dependenciesSetup()
        delegate?.onLoaded()
        dataProvider?.delegate = self
    }
    
    fileprivate func dependenciesSetup() {
        let interactor = ExchangeListInteractor(dependencies: dependencies)
        presenter = ExchangeListPresenter(interactor: interactor)
        presenter.interface = self
        interactor.output = presenter
        delegate = presenter
    }
}

extension ExchangeListViewController: ExchangeListInterface {
    func paginationActivityIndicatorVisibility(_ visibility: Visibility) {
        dataProvider?.isPaging = visibility == .visible
    }
    
    func refreshControlVisibility(_ visibility: Visibility) {
        dataProvider?.isRefreshing = visibility.isHidden == false
    }
    
    func display(results: [ExchangeTradeCellModel]) {
        dataProvider?.append(tradeModels: results)
    }
    
    func append(results: [ExchangeTradeCellModel]) {
        dataProvider?.append(tradeModels: results)
    }
    
    func enablePullToRefresh() {
        dataProvider?.setupPullToRefresh()
    }
    
    func showNewExchange(animated: Bool) {
        // TODO
    }
}

extension ExchangeListViewController: ExchangeListDataProviderDelegate {
    func dataProvider(_ dataProvider: ExchangeListDataProvider, didSelect trade: ExchangeTradeCellModel) {
        // TODO: Show order detail screen for trade.
    }
    
    func refreshControlTriggered(_ dataProvider: ExchangeListDataProvider) {
        delegate?.onPullToRefresh()
    }
    
    func newOrderTapped(_ dataProvider: ExchangeListDataProvider) {
        delegate?.onNewOrderTapped()
    }
    
    func dataProvider(_ dataProvider: ExchangeListDataProvider, nextPageBefore identifier: String) {
        delegate?.onNextPageRequest(identifier)
    }
}
