//
//  PaxActivityViewController.swift
//  Blockchain
//
//  Created by AlexM on 5/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ERC20Kit

class PaxActivityViewController: SimpleTransactionsViewController {
    
    var disposable: Disposable?
    
    private var assetAccountRepository: ERC20AssetAccountRepository<PaxToken> = {
        return PAXServiceProvider.shared.services.assetAccountRepository
    }()
    
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
    
    @objc class func make() -> PaxActivityViewController {
        let controller = PaxActivityViewController.make(
            with: PaxActivityViewController.self,
            dataProvider: PaxActivityDataProvider.self,
            presenter: PaxActivityPresenter.self,
            interactor: PaxActivityInteractor(with: PAXServiceProvider.shared)
        )
        
        return controller
    }
    
    override func showItemDetails(item: Identifiable) {
        guard let model = item as? ERC20HistoricalTransaction<PaxToken> else { return }
        let detailViewController = TransactionDetailViewController()
        let navigation = TransactionDetailNavigationController(rootViewController: detailViewController)
        detailViewController.busyViewDelegate = navigation
        detailViewController.modalTransitionStyle = .coverVertical
        
        let viewModel: TransactionDetailViewModel = TransactionDetailViewModel(transaction: model)
        detailViewController.transactionModel = viewModel
        navigation.transactionHash = model.transactionHash
        
        guard let top = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController else { return }
        top.present(navigation, animated: true, completion: nil)
    }
    
    @objc func reload() {
        getBalance()
    }
    
    override func filterSelectorViewTapped() {
        
    }
    
    func getBalance(displayError: Bool? = false) {
        disposable = assetAccountRepository.currentAssetAccountDetails(fromCache: false)
            .map { $0.balance }
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { value in
                self.title = value.toDisplayString(includeSymbol: true)
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
