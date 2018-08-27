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
        let newOrderCell = UINib(nibName: NewOrderTableViewCell.identifier, bundle: nil)
        let listCell = UINib(nibName: ExchangeListViewCell.identifier, bundle: nil)
        let loadingCell = UINib(nibName: LoadingTableViewCell.identifier, bundle: nil)
        table.register(listCell, forCellReuseIdentifier: ExchangeListViewCell.identifier)
        table.register(loadingCell, forCellReuseIdentifier: LoadingTableViewCell.identifier)
        table.register(newOrderCell, forCellReuseIdentifier: NewOrderTableViewCell.identifier)
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
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let current = models else { return 0 }
        switch section {
        case 0:
            return 1
        case 1:
            return isPaging ? current.count + 1 : current.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = models else { return UITableViewCell() }
        
        let newOrderIdentifier = NewOrderTableViewCell.identifier
        let listIdentifier = ExchangeListViewCell.identifier
        let loadingIdentifier = LoadingTableViewCell.identifier
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: newOrderIdentifier,
                for: indexPath
                ) as? NewOrderTableViewCell else { return UITableViewCell() }
            
            cell.actionHandler = { [weak self] in
                guard let this = self else { return }
                this.delegate?.newOrderTapped(this)
            }
            
            return cell
            
        case 1:
            guard items.count > indexPath.row else { return UITableViewCell() }
            
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
}

extension ExchangeListDataProvider: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let items = models else { return tableView.estimatedRowHeight }
        
        if indexPath.section == 0 {
            return NewOrderTableViewCell.height()
        }
        
        if items.count > indexPath.row {
            let item = items[indexPath.row]
            return ExchangeListViewCell.estimatedHeight(for: item)
        }
        
        return isPaging ? LoadingTableViewCell.height() : 0.0
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

