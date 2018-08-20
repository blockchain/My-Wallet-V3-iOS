//
//  ExchangeListDataProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeListDataProviderDelegate: class {
    func dataProvider(_ dataProvider: ExchangeListDataProvider, requestsNextPageBefore timetstamp: Date)
}

class ExchangeListDataProvider: NSObject {

    weak var delegate: ExchangeListDataProviderDelegate?

    var selectionClosure: ((ExchangeTradeCellModel) -> Void)?

    fileprivate weak var tableView: UITableView?
    fileprivate var models: [ExchangeTradeCellModel]?
    fileprivate var currentPage: Page<[ExchangeTradeCellModel]>?

    init(table: UITableView) {
        tableView = table
        super.init()
        tableView?.delegate = self
        tableView?.dataSource = self
    }

    fileprivate func registerAllCellTypes() {
        guard let table = tableView else { return }
        let orderCell = UINib(nibName: ExchangeListOrderCell.identifier, bundle: nil)
        let listCell = UINib(nibName: ExchangeListViewCell.identifier, bundle: nil)
        table.register(orderCell, forCellReuseIdentifier: ExchangeListOrderCell.identifier)
        table.register(listCell, forCellReuseIdentifier: ExchangeListViewCell.identifier)
    }

    func display(page: Page<[ExchangeTradeCellModel]>) {
        if let trades = page.result {
            models = trades
            tableView?.reloadData()
        }
        currentPage = page
    }

    func append(page: Page<[ExchangeTradeCellModel]>) {
        currentPage = page
        if let trades = page.result, var current = models {
            current.append(contentsOf: trades)
            models = current
            tableView?.reloadData()
        }
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ExchangeListViewCell.estimatedHeight()
    }
}

extension ExchangeListDataProvider: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height {
            if let page = currentPage {
                guard page.result?.count == page.pageSize else { return }
                guard let item = models?.last else { return }
                delegate?.dataProvider(self, requestsNextPageBefore: item.transactionDate)
            }
        }
    }
}

