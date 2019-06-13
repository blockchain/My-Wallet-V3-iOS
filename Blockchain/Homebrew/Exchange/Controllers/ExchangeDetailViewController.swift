//
//  ExchangeDetailViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import SafariServices
import PlatformUIKit
import PlatformKit

protocol ExchangeDetailDelegate: class {
    func onViewLoaded()
}

/// This `UIViewController` is used for the `Exchange Confirmation`,
/// `Exchange Locked`, and `Trade Overview` screen. It contains
/// a `UICollectionView`.
class ExchangeDetailViewController: UIViewController {

    static func make(with model: ExchangeDetailPageModel, dependencies: ExchangeDependencies) -> ExchangeDetailViewController {
        let controller = ExchangeDetailViewController.makeFromStoryboard()
        controller.model = model
        controller.dependencies = dependencies
        return controller
    }

    // MARK: Public Properties

    weak var delegate: ExchangeDetailDelegate?
    var mostRecentOrderTransaction: OrderTransaction?
    var mostRecentConversion: Conversion?

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet fileprivate var layout: UICollectionViewFlowLayout!

    // MARK: Private Properties

    fileprivate var layoutAttributes: LayoutAttributes!
    fileprivate var model: ExchangeDetailPageModel!
    fileprivate var reuseIdentifiers: Set<String> = []
    fileprivate var coordinator: ExchangeDetailCoordinator!
    fileprivate var presenter: ExchangeDetailPresenter!
    fileprivate var dependencies: ExchangeDependencies!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = ExchangeDetailCoordinator(
            delegate: self,
            interface: self,
            dependencies: dependencies
        )
        dependenciesSetup()
        setupLayout()
        coordinator.handle(event: .pageLoaded(model))
        delegate?.onViewLoaded()
    }
    
    deinit {
        presenter = nil
    }

    fileprivate func dependenciesSetup() {
        let interactor = ExchangeDetailInteractor(dependencies: dependencies)
        presenter = ExchangeDetailPresenter(interactor: interactor)
        presenter.interface = self
        interactor.output = presenter
        delegate = presenter
    }
    
    fileprivate func setupLayout() {
        guard let page = model else { return }
        
        switch page.pageType {
        case .confirm, .locked:
            layoutAttributes = .exchangeDetail
        case .overview:
            layoutAttributes = .exchangeOverview
        }
        guard let layout = layout else { return }
        
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
    }
    
    fileprivate func registerCells() {
        collectionView.delegate = self
        collectionView.dataSource = self
        guard let page = model else { return }
        guard let cells = page.cells else { return }
        
        cells.forEach({ (cellModel) in
            let reuse = cellModel.reuseIdentifier
            if !reuseIdentifiers.contains(reuse) {
                let nib = UINib.init(nibName: reuse, bundle: nil)
                collectionView.register(nib, forCellWithReuseIdentifier: reuse)
                reuseIdentifiers.insert(reuse)
            }
        })
    }
    
    fileprivate func registerSupplementaryViews() {
        guard let page = model else { return }
        if let _ = page.footer {
            let footerNib = UINib(nibName: ActionableFooterView.identifier, bundle: nil)
            collectionView.register(
                footerNib,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: ActionableFooterView.identifier
            )
        }
        
        if let header = page.header {
            let headerNib = UINib(nibName: header.reuseIdentifier, bundle: nil)
            collectionView.register(
                headerNib,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: header.reuseIdentifier
            )
        }
        
        AnalyticsService.shared.trackEvent(title: page.pageType.analyticsIdentifier)
    }
    
    fileprivate func presentAlert(with alertModel: AlertModel) {
        let alert = AlertView.make(with: alertModel) { [weak self] action in
            guard let this = self else { return }
            guard let value = action.metadata else { return }
            
            switch value {
            case .url(let url):
                this.presentURL(url)
                /// The alert will be dismissed after the action is selected
                /// and we want the user to be back at the Swap or History screen.
                this.navigationController?.popViewController(animated: true)
            case .block(let block):
                block()
            case .pop:
                this.navigationController?.popViewController(animated: true)
            case .dismiss:
                this.dismiss(animated: true, completion: nil)
            case .payload:
                break
            }
        }
        alert.show()
    }
}

extension ExchangeDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let page = model else { return 0 }
        return page.cells?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let page = model else { return UICollectionViewCell() }
        guard let items = page.cells else { return UICollectionViewCell() }
        let item = items[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: item.reuseIdentifier,
            for: indexPath) as? ExchangeDetailCell else {
                return UICollectionViewCell()
        }
        cell.configure(with: item)
        return cell
    }
}

extension ExchangeDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        guard let page = model else { return .zero }
        guard let cells = page.cells else { return .zero }
        let cellModel = cells[indexPath.row]
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        let height = cellModel.heightForProposed(width: width)
        return CGSize(width: width, height: height)
    }

    // swiftlint:disable function_body_length
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind
        kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let page = model else { return UICollectionReusableView() }
        
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            guard let footerModel = page.footer else { return UICollectionReusableView() }
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ActionableFooterView.identifier,
                for: indexPath
                ) as? ActionableFooterView else { return UICollectionReusableView() }
            
            footer.configure(footerModel)
            
            switch page.pageType {
            case .confirm:
                guard let order = mostRecentOrderTransaction else { return footer }
                footer.actionBlock = { [weak self] in
                    guard let self = self else { return }
                    self.coordinator.handle(event: .confirmExchange(order))
                    self.dismiss(animated: false, completion: nil)
                }
            case .locked(let transaction, _):
                footer.actionBlock = { [weak self] in
                    guard let this = self else { return }
                    this.dismiss(animated: true, completion: nil)
                    if transaction.to.assetType == .pax {
                        NotificationCenter.default.post(Notification(name: Constants.NotificationKeys.swapToPaxFlowCompleted))
                    } else {
                        NotificationCenter.default.post(Notification(name: Constants.NotificationKeys.swapFlowCompleted))
                    }
                }
            case .overview:
                footer.actionBlock = {
                    guard let url = URL(string: Constants.Url.supportTicketBuySellExchange) else {
                        return
                    }
                    let viewController = SFSafariViewController(url: url)
                    viewController.modalPresentationStyle = .overFullScreen
                    self.present(viewController, animated: true, completion: nil)
                }
            }
            
            return footer
            
        case UICollectionView.elementKindSectionHeader:
            guard let header = page.header else { return UICollectionReusableView() }
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: header.reuseIdentifier,
                for: indexPath
                ) as? ExchangeHeaderView else { return UICollectionReusableView() }
            headerView.configure(with: header)
            
            if let view = headerView as? ExchangeLockedHeaderView {
                view.closeTapped = { [weak self] in
                    guard let this = self else { return }
                    this.dismiss(animated: true, completion: nil)
                }
            }
            return headerView
            
        default:
            return UICollectionReusableView()
        }
    }
    // swiftlint:enable function_body_length

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let page = model else { return .zero }
        guard let header = page.header else { return .zero }
        let width = collectionView.bounds.width
        let height = header.heightForProposed(width: width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard let page = model else { return .zero }
        guard let footer = page.footer else { return .zero }
        let width = collectionView.bounds.width
        let height = ActionableFooterView.height(with: footer, width: width)
        return CGSize(width: width, height: height)
    }
}

extension ExchangeDetailViewController: ExchangeDetailCoordinatorDelegate {
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, updated model: ExchangeDetailPageModel) {
        self.model = model
        registerCells()
        registerSupplementaryViews()
        collectionView.reloadData()
        if let alertModel = model.alertModel {
            presentAlert(with: alertModel)
        }
    }
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, completedTransaction: OrderTransaction) {
        guard let navController = navigationController else { return }
        navController.popToRootViewController(animated: false)
    }
}

extension ExchangeDetailViewController: ExchangeDetailInterface {
    
    func presentTiers() {
        _ = KYCTiersViewController.routeToTiers(fromViewController: self)
    }
    
    func presentURL(_ url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true, completion: nil)
    }
    
    func updateConfirmDetails(conversion: Conversion) {
        guard let orderTransaction = self.mostRecentOrderTransaction else {
            Logger.shared.error("Missing order transaction - should have been stored after onLoaded ExchangeDetailCoordinator event")
            return
        }
        /// We're still getting `conversion` updates when the user gets an error after
        /// submitting an order. If they've ever recieved an error on the `Confirm Order`
        /// screen, we want them to update the order prior to being able to submit.
        /// If we continue to update the conversion, the collectionView will reload
        /// and the footer with the submission button will be visible again.
        guard let model = model else { return }
        guard model.alertModel == nil else {
            Logger.shared.info("Not updating confirm details. Alert is currently presented.")
            return
        }
        coordinator.handle(event: .updateConfirmDetails(orderTransaction, conversion))
    }

    func navigationBarVisibility(_ visibility: Visibility) {
        guard let navController = navigationController else { return }
        navController.setNavigationBarHidden(visibility.isHidden, animated: false)
    }
    
    func updateBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }

    func updateNavigationBar(appearance: NavigationBarAppearance, color: UIColor) {
        guard let navigationController = self.navigationController as? BCNavigationController else {
            return
        }
        navigationController.apply(appearance, withBackgroundColor:color)
    }
    
    func updateTitle(_ value: String) {
        title = value
    }

    func loadingVisibility(_ visibility: Visibility) {
        if visibility == .hidden {
            LoadingViewPresenter.shared.hideBusyView()
        } else {
            LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.Exchange.sendingOrder)
        }
    }
}

extension ExchangeDetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ModalAnimator(operation: .dismiss, duration: 0.4)
        return dismissed is KYCTiersViewController ? animator: nil
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
        let animator = ModalAnimator(operation: .dismiss, duration: 0.4)
        return presented is KYCTiersViewController ? animator : nil
    }
}

extension ExchangeDetailViewController: ExchangeNavigatableView {
    var ctaTintColor: UIColor? {
        guard let model = model else { return nil }
        switch model.pageType {
        case .confirm,
             .locked:
            return UIColor.brandPrimary
        case .overview:
            return UIColor.white
        }
    }

    func navControllerCTAType() -> NavigationCTA {
        guard let model = model else { return .none }
        switch model.pageType {
        case .confirm:
            return .help
        case .locked,
             .overview:
            return .none
        }
    }
}
