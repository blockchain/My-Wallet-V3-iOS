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

    fileprivate var dataProvider: ExchangeListDataProvider?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider = ExchangeListDataProvider(table: tableView)
        dataProvider?.delegate = self
    }
}

extension ExchangeListViewController: ExchangeListDataProviderDelegate {
    func newOrderTapped(_ dataProvider: ExchangeListDataProvider) {
        // TODO
    }

    func dataProvider(_ dataProvider: ExchangeListDataProvider, requestsNextPageBefore timestamp: Date) {
        // TODO
    }
}
