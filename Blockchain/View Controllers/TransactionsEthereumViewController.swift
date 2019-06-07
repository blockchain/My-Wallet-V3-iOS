//
//  TransactionsEthereumViewController.swift
//  Blockchain
//
//  Created by Jack on 20/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import PlatformKit
import EthereumKit
import ERC20Kit
import RxSwift

extension TransactionsViewController {
    fileprivate var _balance: String {
        set {
            perform("setBalance:", with: newValue)
        }
        get {
            return perform("balance").takeUnretainedValue() as! String
        }
    }
    
    fileprivate var _noTransactionsView: UIView {
        set {
            perform("setNoTransactionsView:", with: newValue)
        }
        get {
            return perform("noTransactionsView").takeUnretainedValue() as! UIView
        }
    }
    
    fileprivate func _setupNoTransactionView(in view: UIView) {
        perform("setupNoTransactionsViewEtherInView:", with: view)
    }
}

final class TransactionsEthereumViewController: TransactionsViewController {
    
    @objc var detailViewController: TransactionDetailViewController!
    
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var transactions: [EtherTransaction] = []
    
    private let disposables = CompositeDisposable()
    
    private let repository = ETHServiceProvider.shared.repository
    
    private let assetAccountRepository = ETHServiceProvider.shared.assetAccountRepository
    private let transactionService = ETHServiceProvider.shared.transactionService
    
    deinit {
        disposables.dispose()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.frame = UIView.rootViewSafeAreaFrame(navigationBar: true, tabBar: true, assetSelector: true)
        
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        setupPullToRefresh()
        
        _setupNoTransactionView(in: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _balance = ""
        reload()
    }
    
    @objc func reload() {
        loadTransactions()
        updateBalance()
    }
    
    @objc func reloadSymbols() {
        updateBalance()
        tableView.reloadData()
        detailViewController.reloadSymbols()
    }
    
    private func updateBalance() {
        let disposable = assetAccountRepository.currentAssetAccountDetails(fromCache: false)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] details in
                let balance = details.balance

                let tabControllerManager = AppCoordinator.shared.tabControllerManager

                self?._balance = BlockchainSettings.sharedAppInstance().symbolLocal
                    ? NumberFormatter.formatEthToFiat(
                        withSymbol: balance.toDisplayString(includeSymbol: true),
                        exchangeRate: tabControllerManager.latestEthExchangeRate
                      )
                    : NumberFormatter.formatEth(balance)
            }, onError: nil)
        disposables.insertWithDiscardableResult(disposable)
    }
    
    private func setupPullToRefresh() {
        let tableViewController = UITableViewController()
        tableViewController.tableView = tableView
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableViewController.refreshControl = refreshControl
    }
    
    private func loadTransactions() {
        let disposable = transactionService.fetchTransactions()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [weak self] in
                self?.refreshControl.endRefreshing()
            })
            .do(onSuccess: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .do(onError: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .subscribe(onSuccess: { [weak self] ethereumTransactions in
                guard let `self` = self else { return }
                
                let legacyTransactions = ethereumTransactions
                    .map { $0.legacyTransaction }
                    .compactMap { $0 }
                self.transactions = legacyTransactions
                self._noTransactionsView.isHidden = self.transactions.count > 0
                self.tableView.reloadData()
            }, onError: { [weak self] _ in
                guard let `self` = self else { return }
                
                self._noTransactionsView.isHidden = self.transactions.count > 0
                self.tableView.reloadData()
            })

        disposables.insertWithDiscardableResult(disposable)
    }
    
    private func getAssetButtonClicked() {
        let tabControllerManager: TabControllerManager = AppCoordinator.shared.tabControllerManager
        tabControllerManager.receiveCoinClicked(nil)
    }
}

extension TransactionsEthereumViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TransactionEtherTableViewCell
        if let transactionCell = tableView.dequeueReusableCell(withIdentifier: "TransactionEtherTableViewCell") as? TransactionEtherTableViewCell {
            cell = transactionCell
        } else {
            cell = Bundle.main.loadNibNamed("TransactionEtherCell", owner: nil, options: nil)![0] as! TransactionEtherTableViewCell
        }

        let transaction = transactions[indexPath.row]
        cell.transaction = transaction
        cell.reload()

        return cell
    }
}

extension TransactionsEthereumViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? TransactionEtherTableViewCell {
           cell.transactionClicked()
        }
    }
}
