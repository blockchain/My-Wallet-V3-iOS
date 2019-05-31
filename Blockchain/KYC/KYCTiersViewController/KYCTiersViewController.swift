//
//  KYCTiersViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import SafariServices
import UIKit
import RxSwift
import PlatformUIKit
import PlatformKit

protocol KYCTiersInterface: class {
    func apply(_ model: KYCTiersPageModel)
    func loadingIndicator(_ visibility: Visibility)
    func collectionViewVisibility(_ visibility: Visibility)
}

class KYCTiersViewController: UIViewController {
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var layout: UICollectionViewFlowLayout!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    // MARK: Private Properties
    
    fileprivate static let limitsAPI: TradeLimitsAPI = ExchangeServices().tradeLimits
    fileprivate var layoutAttributes: LayoutAttributes = .tiersOverview
    fileprivate var coordinator: KYCTiersCoordinator!
    fileprivate var disposable: Disposable?

    // MARK: Public Properties
    
    var pageModel: KYCTiersPageModel!
    var selectedTier: ((KYCTier) -> Void)?
    
    static func make(
        with pageModel: KYCTiersPageModel
    ) -> KYCTiersViewController {
        let controller = KYCTiersViewController.makeFromStoryboard()
        controller.pageModel = pageModel
        return controller
    }
    
    // MARK: Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
        disposable?.dispose()
        disposable = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.KYC.swapLimits
        coordinator = KYCTiersCoordinator(interface: self)
        setupLayout()
        registerCells()
        registerSupplementaryViews()
        registerForNotifications()
        collectionView.reloadData()
        pageModel.trackPresentation()
        
        if let navController = navigationController as? BCNavigationController {
            navController.headerLabel.text = LocalizationConstants.KYC.swapLimits
        }
        if let navController = navigationController as? SettingsNavigationController {
            navController.headerLabel.text = LocalizationConstants.KYC.swapLimits
        }
        view.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.968627451, blue: 0.9764705882, alpha: 1)
    }
    
    fileprivate func setupLayout() {
        guard let layout = layout else { return }
        
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
    }
    
    fileprivate func registerCells() {
        guard let collection = collectionView else { return }
        collection.delegate = self
        collection.dataSource = self
        
        let nib = UINib(nibName: KYCTierCell.identifier, bundle: nil)
        collection.register(nib, forCellWithReuseIdentifier: KYCTierCell.identifier)
    }
    
    fileprivate func registerSupplementaryViews() {
        guard let collection = collectionView else { return }
        let header = UINib(nibName: pageModel.header.identifier, bundle: nil)
        let footer = UINib(nibName: KYCTiersFooterView.identifier, bundle: nil)
        collection.register(
            header,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: pageModel.header.identifier
        )
        collection.register(
            footer,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: KYCTiersFooterView.identifier
        )
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.when(Constants.NotificationKeys.kycStopped) { [weak self] _ in
            guard let this = self else { return }
            this.coordinator.refreshViewModel(
                suppressCTA: this.pageModel.header.suppressDismissCTA
            )
        }
    }
}

extension KYCTiersViewController: KYCTiersHeaderViewDelegate {
    func headerView(_ view: KYCTiersHeaderView, actionTapped: KYCTiersHeaderViewModel.Action) {
        switch actionTapped {
        case .contactSupport:
            guard let supportURL = URL(string: Constants.Url.blockchainSupportRequest) else { return }
            let controller = SFSafariViewController(url: supportURL)
            present(controller, animated: true, completion: nil)
        case .learnMore:
            guard let verificationURL = URL(string: Constants.Url.verificationRejectedURL) else { return }
            let controller = SFSafariViewController(url: verificationURL)
            present(controller, animated: true, completion: nil)
        }
    }
    
    func dismissButtonTapped(_ view: KYCTiersHeaderView) {
        dismiss(animated: true, completion: nil)
    }
}

extension KYCTiersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageModel.cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = pageModel.cells[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: KYCTierCell.identifier,
            for: indexPath) as? KYCTierCell else {
                return UICollectionViewCell()
        }
        cell.delegate = self
        cell.configure(with: item)
        return cell
    }
}

extension KYCTiersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = pageModel.cells[indexPath.row]
        guard let cell = collectionView.cellForItem(at: indexPath) as? KYCTierCell else { return }
        guard item.status == .none else {
            Logger.shared.debug(
                """
                Not presenting KYC. KYC should only be presented if the status is `.none` for \(item.tier.tierDescription).
                The status is: \(item.status)
                """
            )
            return
        }
        tierCell(cell, selectedTier: item.tier)
    }
}

extension KYCTiersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = pageModel.cells[indexPath.row]
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        let height = KYCTierCell.heightForProposedWidth(width, model: model)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind
        kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            guard let disclaimer = pageModel.disclaimer else { return UICollectionReusableView() }
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: KYCTiersFooterView.identifier,
                for: indexPath
                ) as? KYCTiersFooterView else { return UICollectionReusableView() }
            let trigger = ActionableTrigger( text: disclaimer, CTA: LocalizationConstants.ObjCStrings.BC_STRING_LEARN_MORE) { [weak self] in
                guard let strongSelf = self else { return }
                guard let supportURL = URL(string: Constants.Url.airdropProgram) else { return }
                let controller = SFSafariViewController(url: supportURL)
                strongSelf.present(controller, animated: true, completion: nil)
            }
            footer.configure(with: trigger)
            return footer
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: pageModel.header.identifier,
                for: indexPath
                ) as? KYCTiersHeaderView else { return UICollectionReusableView() }
            header.configure(with: pageModel.header)
            header.delegate = self
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
        let height = pageModel.header.estimatedHeight(
            for: collectionView.bounds.width,
            model: pageModel.header
        )
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
        ) -> CGSize {
        guard let disclaimer = pageModel.disclaimer else { return .zero }
        let height = KYCTiersFooterView.estimatedHeight(
            for: disclaimer,
            width: collectionView.bounds.width
        )
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        return CGSize(width: width, height: height)
    }
}

extension KYCTiersViewController: KYCTierCellDelegate {
    func tierCell(_ cell: KYCTierCell, selectedTier: KYCTier) {
        /// When a user is selecting a tier from `Swap` (which only happens
        /// when the user isn't KYC approved) we want to present KYC from the applications
        /// rootViewController rather than from `self`.
        if let block = self.selectedTier {
            block(selectedTier)
        } else {
            KYCCoordinator.shared.start(from: self, tier: selectedTier)
        }
    }
}

extension KYCTiersViewController: KYCTiersInterface {
    func apply(_ model: KYCTiersPageModel) {
        pageModel = model
        registerSupplementaryViews()
        collectionView.reloadData()
        pageModel.trackPresentation()
    }
    
    func collectionViewVisibility(_ visibility: Visibility) {
        collectionView.alpha = visibility.defaultAlpha
    }
    
    func loadingIndicator(_ visibility: Visibility) {
        switch visibility {
        case .visible:
            LoadingViewPresenter.shared.showBusyView(
                withLoadingText: LocalizationConstants.loading
            )
        case .hidden:
            LoadingViewPresenter.shared.hideBusyView()
        }
    }
}

extension KYCTiersViewController {
    typealias CurrencyCode = String
    
    static func tiersMetadata(_ currencyCode: CurrencyCode = "USD") -> Observable<KYCTiersPageModel> {
        let tradesObservable = limitsAPI.getTradeLimits(withFiatCurrency: currencyCode, ignoringCache: true)
            .optional()
            .catchErrorJustReturn(nil)
            .asObservable()
        return Observable.zip(BlockchainDataRepository.shared.tiers, tradesObservable)
            .subscribeOn(MainScheduler.asyncInstance)
            .map { (response, limits) -> KYCTiersPageModel in
                let userTiers = response.userTiers
                let formatter: NumberFormatter = NumberFormatter.localCurrencyFormatterWithGroupingSeparator
                let max = NSDecimalNumber(decimal: limits?.maxTradableToday ?? 0)
                let header = KYCTiersHeaderViewModel.make(
                    with: response,
                    availableFunds: formatter.string(from: max),
                    suppressDismissCTA: true
                )
                let filtered = userTiers.filter({ $0.tier != .tier0 })
                let cells = filtered.map({ return KYCTierCellModel.model(from: $0) }).compactMap({ return $0 })
                
                let page = KYCTiersPageModel(header: header, cells: cells)
                return page
        }
    }
    
    static func routeToTiers(
        fromViewController: UIViewController,
        code: CurrencyCode = "USD"
    ) -> Disposable {
        return tiersMetadata()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { model in
                let controller = KYCTiersViewController.make(with: model)
                if let from = fromViewController as? UIViewControllerTransitioningDelegate {
                    controller.transitioningDelegate = from
                }
                if let navController = fromViewController.navigationController {
                    navController.pushViewController(controller, animated: true)
                } else {
                    let navController = BCNavigationController(rootViewController: controller)
                    fromViewController.present(navController, animated: true, completion: nil)
                }
            })
    }
}

extension KYCTiersViewController: NavigatableView {
    
    var leftCTATintColor: UIColor {
        return .white
    }
    
    var rightCTATintColor: UIColor {
        return .white
    }
    
    var leftNavControllerCTAType: NavigationCTAType {
        guard let navController = navigationController else { return .dismiss }
        if parent is ExchangeContainerViewController && navController.viewControllers.count == 1 {
            return .menu
        } else {
            return navController.viewControllers.count > 1 ? .back : .dismiss
        }
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return .none
    }
    
    var navigationDisplayMode: NavigationBarDisplayMode {
        return .dark
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        if parent is ExchangeContainerViewController && navController.viewControllers.count == 1 {
            AppCoordinator.shared.toggleSideMenu()
            return
        }
        
        guard let navController = navigationController else {
            dismiss(animated: true, completion: nil)
            return
        }
        navController.popViewController(animated: true)
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        // no op
    }
}
