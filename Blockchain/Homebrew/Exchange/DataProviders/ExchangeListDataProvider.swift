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
    func newOrderTapped(_ dataProvider: ExchangeListDataProvider)
}

class ExchangeListDataProvider: NSObject {

    fileprivate static let estimatedCellHeight: CGFloat = 75.0

    weak var delegate: ExchangeListDataProviderDelegate?

    var selectionClosure: ((ExchangeTradeCellModel) -> Void)?
    
    var isPaging: Bool = false {
        didSet {
            guard let table = tableView else { return }
            guard let current = models else { return }
            guard isPaging != oldValue else { return }
            table.beginUpdates()
            let path = IndexPath(row: current.count, section: 0)
            switch isPaging {
            case true:
                table.insertRows(at: [path], with: .automatic)
            case false:
                table.deleteRows(at: [path], with: .automatic)
            }
            table.endUpdates()
        }
    }

    fileprivate weak var tableView: UITableView?
    fileprivate var models: [ExchangeTradeCellModel]?

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
        let headerView = UINib(nibName: String(describing: ExchangeListOrderHeaderView.self), bundle: nil)
        let listCell = UINib(nibName: ExchangeListViewCell.identifier, bundle: nil)
        let loadingCell = UINib(nibName: LoadingTableViewCell.identifier, bundle: nil)
        table.register(listCell, forCellReuseIdentifier: ExchangeListViewCell.identifier)
        table.register(loadingCell, forCellReuseIdentifier: LoadingTableViewCell.identifier)
        table.register(headerView, forHeaderFooterViewReuseIdentifier: String(describing: ExchangeListOrderHeaderView.self))
    }

    func append(tradeModels: [ExchangeTradeCellModel]) {
        if var current = models {
            current.append(contentsOf: tradeModels)
            models = current
        } else {
            models = tradeModels
        }
        tableView?.reloadData()
    }
}

extension ExchangeListDataProvider: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let current = models else { return 0 }
        return isPaging ? current.count + 1 : current.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = models else { return UITableViewCell() }
        if items.count > indexPath.row {
            let model = items[indexPath.row]
            let identifier = ExchangeListViewCell.identifier
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: identifier,
                for: indexPath
                ) as? ExchangeListViewCell else { return UITableViewCell() }
            
            cell.configure(with: model)
            return cell
        }
        
        if indexPath.row == items.count && isPaging {
            let identifier = LoadingTableViewCell.identifier
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: identifier,
                for: indexPath
                ) as? LoadingTableViewCell else { return UITableViewCell() }
            return cell
        }
        
        return UITableViewCell()
    }
}

extension ExchangeListDataProvider: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier = String(describing: ExchangeListOrderHeaderView.self)
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: identifier
            ) as? ExchangeListOrderHeaderView else { return nil }
        
        header.actionHandler = { [weak self] in
            guard let this = self else { return }
            this.delegate?.newOrderTapped(this)
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let items = models else { return tableView.estimatedRowHeight }
        if items.count > indexPath.row {
            let item = items[indexPath.row]
            return ExchangeListViewCell.estimatedHeight(for: item)
        }
        return isPaging ? LoadingTableViewCell.height() : 0.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ExchangeListOrderHeaderView.estimatedHeight()
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

