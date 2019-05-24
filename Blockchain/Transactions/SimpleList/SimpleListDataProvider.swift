//
//  SimpleListDataProvider.swift
//  Blockchain
//
//  Created by kevinwu on 10/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit

protocol SimpleListDataProviderDelegate: class {
    func dataProvider(_ dataProvider: SimpleListDataProvider, nextPageBefore identifier: String)
    func dataProvider(_ dataProvider: SimpleListDataProvider, didSelect item: Identifiable)
    func refreshControlTriggered(_ dataProvider: SimpleListDataProvider)

    var estimatedCellHeight: CGFloat { get }
}

// Data provider for a SimpleListViewController
class SimpleListDataProvider: NSObject, UITableViewDataSource {

    // MARK: Public

    weak var delegate: SimpleListDataProviderDelegate?

    // If this is `true` we should show the cell with
    // a loading indicator at the bottom of the `tableView`
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

    // Cannot be fileprivate because it must be accessible by subclass
    weak var tableView: UITableView?

    // MARK: Private Properties

    fileprivate var refreshControl: UIRefreshControl!
    var models: [Identifiable]?
    fileprivate var estimatedCellHeight: CGFloat {
        return delegate?.estimatedCellHeight ?? 44.0
    }

    // Called by SimpleListViewController factory method
    required override init() {
        super.init()
    }

    init(table: UITableView) {
        tableView = table
        super.init()
        setupTableView()
    }

    func setupWithTable(table: UITableView) {
        tableView = table
        setupTableView()
    }

    fileprivate func setupTableView() {
        tableView?.estimatedRowHeight = estimatedCellHeight
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
        registerAllCellTypes()
    }

    func registerAllCellTypes() {
         Logger.shared.error("Not overridden by superclass!")
    }

    func setupPullToRefresh() {
        guard refreshControl == nil else { return }
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = control
        tableView?.refreshControl = refreshControl
    }

    func set(listModels: [Identifiable]) {
        models = listModels
        tableView?.reloadData()
    }

    func append(listModels: [Identifiable]) {
        if var current = models {
            current.append(contentsOf: listModels)
            models = current
        } else {
            models = listModels
        }
        tableView?.reloadData()
    }

    @objc fileprivate func refresh() {
        delegate?.refreshControlTriggered(self)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let current = models else { return 0 }
            return isPaging ? current.count + 1 : current.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LoadingTableViewCell.identifier,
            for: indexPath
            ) as? LoadingTableViewCell else { return UITableViewCell() }
        /// This particular cell shouldn't have a separator.
        /// This is how we hide it.
        cell.separatorInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: 0.0,
            right: .greatestFiniteMagnitude
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items = models else { return }
        guard items.count > indexPath.row else { return }
        let model = items[indexPath.row]
        delegate?.dataProvider(self, didSelect: model)
    }
}

extension SimpleListDataProvider: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isPaging ? LoadingTableViewCell.height() : estimatedCellHeight
    }
}

extension SimpleListDataProvider: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height {
            guard let item = models?.last else { return }
            delegate?.dataProvider(self, nextPageBefore: item.identifier)
        }
    }
}
