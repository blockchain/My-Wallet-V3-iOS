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
    func onDisappear()
    func onNextPageRequest(_ identifier: String)
    func onTradeCellTapped(_ trade: ExchangeTradeModel)
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
        dataProvider?.delegate = self
        delegate?.onLoaded()
        registerForNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let controller = navigationController as? BCNavigationController {
            controller.applyDarkAppearance()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.onDisappear()
    }
    
    fileprivate func dependenciesSetup() {
        let interactor = ExchangeListInteractor(dependencies: dependencies)
        presenter = ExchangeListPresenter(interactor: interactor)
        presenter.interface = self
        interactor.output = presenter
        delegate = presenter
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.when(Constants.NotificationKeys.exchangeSubmitted) { [weak self] _ in
            guard let this = self else { return }
            this.delegate?.onLoaded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ExchangeListViewController: ExchangeListInterface {
    func showTradeDetails(trade: ExchangeTradeModel) {
        coordinator.handle(event: .showTradeDetails(trade: trade))
    }

    func paginationActivityIndicatorVisibility(_ visibility: Visibility) {
        dataProvider?.isPaging = visibility == .visible
    }
    
    func refreshControlVisibility(_ visibility: Visibility) {
        dataProvider?.isRefreshing = visibility.isHidden == false
    }
    
    func display(results: [ExchangeTradeModel]) {
        dataProvider?.set(tradeModels: results)
    }
    
    func append(results: [ExchangeTradeModel]) {
        dataProvider?.append(tradeModels: results)
    }
    
    func enablePullToRefresh() {
        dataProvider?.setupPullToRefresh()
    }
    
    func showNewExchange(animated: Bool) {
        coordinator.handle(event: .createHomebrewExchange(animated: animated, viewController: nil))
    }
}

extension ExchangeListViewController: ExchangeListDataProviderDelegate {
    func dataProvider(_ dataProvider: ExchangeListDataProvider, didSelect trade: ExchangeTradeModel) {
        delegate?.onTradeCellTapped(trade)
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
