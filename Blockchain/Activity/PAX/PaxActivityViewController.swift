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
    
    private var assetAccountRepository: ERC20AssetAccountRepository<PaxToken> = {
        return PAXServiceProvider.shared.services.assetAccountRepository
    }()
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet private var emptyStateView: PaxEmptyStateView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
        assetAccountRepository.currentAssetAccountDetails(fromCache: false)
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
            .disposed(by: disposeBag)
    }
    
    // MARK: Overrides
    
    override func emptyStateVisibility(_ visibility: Visibility) {
        emptyStateView.alpha = visibility.defaultAlpha
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
    
    // MARK: Private methods
    
    private func setup() {
        emptyStateView.alpha = 0.0
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24.0),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24.0)
        ])
        
        let viewModel = PaxEmptyStateViewModel(
            title: LocalizationConstants.Activity.Pax.emptyStateTitle,
            subTitle: LocalizationConstants.Activity.Pax.emptyStateMessage,
            link: PaxEmptyStateViewModel.Link(
                text: LocalizationConstants.Activity.Pax.emptyStateLinkText,
                action: { [weak self] in
                    self?.learnMoreAction()
                }
            ),
            ctaButton: PaxEmptyStateViewModel.CTAButton(
                title: LocalizationConstants.Activity.Pax.emptyStateCTATitle,
                action: { [weak self] in
                    self?.ctaAction()
                }
            )
        )
        
        emptyStateView.configure(with: viewModel)
    }
    
    private func learnMoreAction() {
        UIApplication.shared.openSafariViewController(
            url: Constants.Url.learnMoreAboutPaxURL,
            presentingViewController: AppCoordinator.shared.tabControllerManager.tabViewController
        )
    }
    
    private func ctaAction() {
        AppCoordinator.shared.tabControllerManager.swapTapped(nil)
    }
}
