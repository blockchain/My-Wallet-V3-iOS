//
//  TransactionsXlmViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class TransactionsXlmViewController: SimpleTransactionsViewController {

    var disposable: Disposable?
    var accountService: StellarAccountAPI = XLMServiceProvider.shared.services.accounts

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    @IBOutlet fileprivate var noTransactionsLabel: UILabel!
    @IBOutlet fileprivate var noTransactionsDescriptionLabel: UILabel!
    @IBOutlet fileprivate var CTAButton: UIButton!
    
    fileprivate var emptyStateSubviews: [UIView] {
        return [noTransactionsLabel,
                noTransactionsDescriptionLabel,
                CTAButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CTAButton.layer.cornerRadius = 4.0
    }

    @objc class func make(with provider: XLMServiceProvider) -> TransactionsXlmViewController {
        let controller = SimpleListViewController.make(
            with: TransactionsXlmViewController.self,
            dataProvider: TransactionsXlmDataProvider.self,
            presenter: TransactionsXlmPresenter.self,
            interactor: TransactionsXlmInteractor(with: provider)
        )
        
        return controller
    }
    
    override func showItemDetails(item: Identifiable) {
        guard let model = item as? StellarOperation else { return }
        let detailViewController = TransactionDetailViewController()
        let navigation = TransactionDetailNavigationController(rootViewController: detailViewController)
        detailViewController.busyViewDelegate = navigation
        detailViewController.modalTransitionStyle = .coverVertical
        
        if case let .payment(payment) = model {
            let viewModel: TransactionDetailViewModel = TransactionDetailViewModel(xlmTransaction: payment)
            detailViewController.transactionModel = viewModel
            navigation.transactionHash = payment.transactionHash
        }
        
        if case let .accountCreated(created) = model {
            let viewModel: TransactionDetailViewModel = TransactionDetailViewModel(xlmTransaction: created)
            detailViewController.transactionModel = viewModel
            navigation.transactionHash = created.transactionHash
        }
        
        guard let top = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController else { return }
        top.present(navigation, animated: true, completion: nil)
    }
    
    @objc func reload() {
        AppCoordinator.shared.tabControllerManager.tabViewController.updateBalanceLabelText("")
        getBalance()
    }

    func getBalance(displayError: Bool? = false) {
        disposable = accountService.currentStellarAccount(fromCache: false)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { account in
                let decimalNumber = NSDecimalNumber(decimal: account.assetAccount.balance)
                let truncatedBalance = NumberFormatter.stellarFormatter.string(from: decimalNumber) ?? ""
                let formattedBalance = truncatedBalance.appendAssetSymbol(for: .stellar)
                AppCoordinator.shared.tabControllerManager.tabViewController.updateBalanceLabelText(formattedBalance)
            }, onError: { error in
                if let shouldShowError = displayError, shouldShowError == true {
                    AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
                }
            })
    }

    // MARK: Overrides
    
    override func emptyStateVisibility(_ visibility: Visibility) {
        emptyStateSubviews.forEach({ $0.alpha = visibility.defaultAlpha })
    }

    override func append(results: [Identifiable]) {
        super.append(results: results)
        getBalance()
    }

    override func display(results: [Identifiable]) {
        super.display(results: results)
        getBalance()
    }

    override func refreshAfterFailedFetch() {
        // Error from failed fetch should already be displaying.
        // do not show another error if the balance fetch fails.
        getBalance(displayError: false)
    }
    
    // MARK: Actions
    
    @IBAction fileprivate func CTATapped(_ sender: UIButton) {
        let controller = AppCoordinator.shared.tabControllerManager
        controller.receiveCoinClicked(nil)
    }
}
