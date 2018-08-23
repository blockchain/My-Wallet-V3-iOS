//
//  ExchangeListDataProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeListDataProviderDelegate: class {
    func dataProvider(_ dataProvider: ExchangeListDataProvider, requestsNextPageBefore timestamp: Date)
    func newOrderTapped(_ dataProvider: ExchangeListDataProvider)
}

class ExchangeListDataProvider: NSObject {

    fileprivate static let estimatedCellHeight: CGFloat = 75.0

    weak var delegate: ExchangeListDataProviderDelegate?

    var selectionClosure: ((ExchangeTradeCellModel) -> Void)?

    fileprivate weak var tableView: UITableView?
    fileprivate var models: [ExchangeTradeCellModel]?

    init(table: UITableView) {
        tableView = table
        super.init()
        tableView?.estimatedRowHeight = ExchangeListDataProvider.estimatedCellHeight
        tableView?.delegate = self
        tableView?.dataSource = self
        registerAllCellTypes()
    }

    fileprivate func registerAllCellTypes() {
        guard let table = tableView else { return }
        let headerView = UINib(nibName: String(describing: ExchangeListOrderHeaderView.self), bundle: nil)
        let listCell = UINib(nibName: ExchangeListViewCell.identifier, bundle: nil)
        table.register(listCell, forCellReuseIdentifier: ExchangeListViewCell.identifier)
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
        return models?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = models?[indexPath.row] else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeListViewCell.identifier, for: indexPath) as? ExchangeListViewCell else { return UITableViewCell() }
        cell.configure(with: model)
        return cell
    }
}

extension ExchangeListDataProvider: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ExchangeListOrderHeaderView.self)) as? ExchangeListOrderHeaderView else { return nil }
        header.actionHandler = { [weak self] in
            guard let this = self else { return }
            this.delegate?.newOrderTapped(this)
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = models?[indexPath.row] else { return tableView.estimatedRowHeight }
        return ExchangeListViewCell.estimatedHeight(for: item)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ExchangeListOrderHeaderView.estimatedHeight()
    }
}

extension ExchangeListDataProvider: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height {
            guard let item = models?.last else { return }
            delegate?.dataProvider(self, requestsNextPageBefore: item.transactionDate)
        }
    }
}

