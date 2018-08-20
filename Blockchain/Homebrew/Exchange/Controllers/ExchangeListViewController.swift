//
//  ExchangeListViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeListViewController: UIViewController {

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var tableView: UITableView!

    // MARK: Private Properties

    fileprivate var refreshControl: UIRefreshControl!
    fileprivate lazy var wallet: Wallet = {
        let wallet = WalletManager.shared.wallet
        return wallet
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        setupTableViewCells()
    }

    fileprivate func setupRefreshControl() {
        guard refreshControl == nil else { return }
        refreshControl = UIRefreshControl()
        // TODO: Hook up selector. 
        tableView.refreshControl = refreshControl
    }

    fileprivate func setupTableViewCells() {
        let orderCell = UINib(nibName: ExchangeListOrderCell.identifier, bundle: nil)
        let listCell = UINib(nibName: ExchangeListViewCell.identifier, bundle: nil)
        tableView.register(orderCell, forCellReuseIdentifier: ExchangeListOrderCell.identifier)
        tableView.register(listCell, forCellReuseIdentifier: ExchangeListViewCell.identifier)
    }

}
