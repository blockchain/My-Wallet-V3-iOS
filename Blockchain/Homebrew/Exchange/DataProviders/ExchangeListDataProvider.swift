//
//  ExchangeListDataProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeListDataProviderDelegate: class {
    func dataProvider(_ dataProvider: ExchangeListDataProvider, nextPageBefore identifier: String)
    func dataProvider(_ dataProvider: ExchangeListDataProvider, didSelect trade: ExchangeTradeModel)
    func newOrderTapped(_ dataProvider: ExchangeListDataProvider)
    func refreshControlTriggered(_ dataProvider: ExchangeListDataProvider)
}

class ExchangeListDataProvider: NSObject {
    
    // MARK: Private Static Properties

    fileprivate static let estimatedCellHeight: CGFloat = 75.0
    
    // MARK: Public
    
    weak var delegate: ExchangeListDataProviderDelegate?
    
    // If this is `true` we should show the cell with
    // a loading indicator at the bottom of the `tableView`
    var isPaging: Bool = false {
        didSet {
            guard let table = tableView else { return }
            guard let current = models else { return }
            guard isPaging != oldValue else { return }
            table.beginUpdates()
            let path = IndexPath(row: current.count, section: 1)
            switch isPaging {
            case true:
                table.insertRows(at: [path], with: .automatic)
            case false:
                table.deleteRows(at: [path], with: .automatic)
            }
            table.endUpdates()
        }
    }
    
    var isRefreshing: Bool = false {
        didSet {
            guard let refresh = refreshControl else { return }
            switch isRefreshing {
            case true:
                refresh.beginRefreshing()
            case false:
                refresh.endRefreshing()
            }
        }
    }
    
    // MARK: Private Properties

    fileprivate weak var tableView: UITableView?
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var models: [ExchangeTradeModel]?

    init(table: UITableView) {
        tableView = table
        super.init()
        tableView?.estimatedRowHeight = ExchangeListDataProvider.estimatedCellHeight
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
        registerAllCellTypes()
    }

    fileprivate func registerAllCellTypes() {
        guard let table = tableView else { return }
        let newOrderCell = UINib(nibName: NewOrderTableViewCell.identifier, bundle: nil)
        let listCell = UINib(nibName: ExchangeListViewCell.identifier, bundle: nil)
        let loadingCell = UINib(nibName: LoadingTableViewCell.identifier, bundle: nil)
        let headerView = UINib(nibName: String(describing: ExchangeListHeaderView.self), bundle: nil)
        table.register(headerView, forHeaderFooterViewReuseIdentifier: String(describing: ExchangeListHeaderView.self))
        table.register(listCell, forCellReuseIdentifier: ExchangeListViewCell.identifier)
        table.register(loadingCell, forCellReuseIdentifier: LoadingTableViewCell.identifier)
        table.register(newOrderCell, forCellReuseIdentifier: NewOrderTableViewCell.identifier)
    }
    
    func setupPullToRefresh() {
        guard refreshControl == nil else { return }
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = control
        tableView?.refreshControl = refreshControl
    }

    func set(tradeModels: [ExchangeTradeModel]) {
        models = tradeModels
        tableView?.reloadData()
    }

    func append(tradeModels: [ExchangeTradeModel]) {
        if var current = models {
            current.append(contentsOf: tradeModels)
            models = current
        } else {
            models = tradeModels
        }
        tableView?.reloadData()
    }
    
    @objc fileprivate func refresh() {
        delegate?.refreshControlTriggered(self)
    }
}

extension ExchangeListDataProvider: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let items = models else { return 1 }
        return items.count > 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            guard let current = models else { return 0 }
            return isPaging ? current.count + 1 : current.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newOrderIdentifier = NewOrderTableViewCell.identifier
        let listIdentifier = ExchangeListViewCell.identifier
        let loadingIdentifier = LoadingTableViewCell.identifier
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: newOrderIdentifier,
                for: indexPath
                ) as? NewOrderTableViewCell else { return UITableViewCell() }
            
            /// This particular cell shouldn't have a separator.
            /// This is how we hide it.
            cell.separatorInset = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: 0.0,
                right: .greatestFiniteMagnitude
            )
            
            cell.actionHandler = { [weak self] in
                guard let this = self else { return }
                this.delegate?.newOrderTapped(this)
            }
            
            return cell
            
        case 1:
            guard let items = models else { return UITableViewCell() }
            
            if items.count > indexPath.row {
                let model = items[indexPath.row]
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: listIdentifier,
                    for: indexPath
                    ) as? ExchangeListViewCell else { return UITableViewCell() }
                
                cell.configure(with: model)
                return cell
            }
            
            if indexPath.row == items.count && isPaging {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: loadingIdentifier,
                    for: indexPath
                    ) as? LoadingTableViewCell else { return UITableViewCell() }
                return cell
            }
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items = models else { return }
        guard indexPath.section == 1 else { return }
        guard items.count > indexPath.row else { return }
        let model = items[indexPath.row]
        delegate?.dataProvider(self, didSelect: model)
    }
}

extension ExchangeListDataProvider: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return NewOrderTableViewCell.height()
        }
        
        guard let items = models else { return tableView.estimatedRowHeight }
        
        if items.count > indexPath.row {
            let item = items[indexPath.row]
            return ExchangeListViewCell.estimatedHeight(for: item)
        }
        
        return isPaging ? LoadingTableViewCell.height() : 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let items = models else { return nil }
        guard items.count > 0 else { return nil }
        
        let identifier = String(describing: ExchangeListHeaderView.self)
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: identifier
            ) as? ExchangeListHeaderView else { return nil }
        
        return header
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let items = models else { return 0.0 }
        guard items.count > 0 else { return 0.0 }
        guard section == 1 else { return 0.0 }
        
        return ExchangeListHeaderView.height()
    }
}

extension ExchangeListDataProvider: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height {
            guard let item = models?.last else { return }
            delegate?.dataProvider(self, nextPageBefore: item.identifier)
        }
    }
}

