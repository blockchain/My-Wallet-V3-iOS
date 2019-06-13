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
    
    @objc var detailViewController: TransactionDetailViewController?
    
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var transactions: [EtherTransaction] = []
    
    private let disposables = CompositeDisposable()
    
    private let repository = ETHServiceProvider.shared.repository
    
    private let assetAccountRepository = ETHServiceProvider.shared.assetAccountRepository
    private let transactionService = ETHServiceProvider.shared.transactionService
    
    private let wallet = WalletManager.shared.wallet.ethereum
    
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
        detailViewController?.reloadSymbols()
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
        // On completed
        let onCompleted = { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self._noTransactionsView.isHidden = self.transactions.count > 0
            self.tableView.reloadData()
        }
        
        let disposable = wallet.fetchEthereumTransactions(using: transactionService)
            .asObservable()
            .subscribe(onNext: { [weak self] transactions in
                self?.transactions = transactions
                onCompleted()
            }, onError: { _ in
                onCompleted()
            }, onDisposed: { [weak self] in
                self?.refreshControl.endRefreshing()
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
