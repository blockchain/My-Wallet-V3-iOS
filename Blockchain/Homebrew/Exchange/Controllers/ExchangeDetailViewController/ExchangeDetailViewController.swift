//
//  ExchangeDetailViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// This `UIViewController` is used for the `Exchange Confirmation`,
/// `Exchange Locked`, and `Trade Overview` screen. It contains
/// a `UICollectionView`.
class ExchangeDetailViewController: UIViewController {
    
    enum PageModel {
        case confirm(Conversion, RatesAPI)
        case locked(Trade)
        case overview(ExchangeTradeCellModel)
    }
    
    static func make(with model: PageModel) -> ExchangeDetailViewController {
        let controller = ExchangeDetailViewController.makeFromStoryboard()
        controller.model = model
        return controller
    }
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet fileprivate var layout: UICollectionViewFlowLayout!
    
    // MARK: Private Properties
    
    fileprivate var layoutAttributes: LayoutAttributes!
    fileprivate var model: PageModel!
    fileprivate var cellModels: [ExchangeCellModel]?
    fileprivate var reuseIdentifiers: Set<String> = []
    fileprivate var coordinator: ExchangeDetailCoordinator!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = ExchangeDetailCoordinator(delegate: self, interface: self)
        setupLayout()
        coordinator.handle(event: .pageLoaded(model))
    }
    
    fileprivate func setupLayout() {
        guard let page = model else { return }
        
        switch page {
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
        
        cellModels?.forEach({ (cellModel) in
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
        switch page {
        case .confirm:
            let footerNib = UINib(nibName: ActionableFooterView.identifier, bundle: nil)
            collectionView.register(
                footerNib,
                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                withReuseIdentifier: ActionableFooterView.identifier
            )
        case .locked:
            let headerNib = UINib(nibName: ExchangeLockedHeaderView.identifier, bundle: nil)
            collectionView.register(
                headerNib,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: ExchangeLockedHeaderView.identifier
            )
            
            let footerNib = UINib(nibName: ActionableFooterView.identifier, bundle: nil)
            collectionView.register(
                footerNib,
                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                withReuseIdentifier: ActionableFooterView.identifier
            )
            
        case .overview:
            let headerNib = UINib(nibName: ExchangeDetailHeaderView.identifier, bundle: nil)
            collectionView.register(
                headerNib,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: ExchangeDetailHeaderView.identifier
            )
        }
    }
}

extension ExchangeDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let items = cellModels else { return UICollectionViewCell() }
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let models = cellModels else { return .zero }
        let model = models[indexPath.row]
        let width = collectionView.bounds.size.width - layoutAttributes.sectionInsets.left - layoutAttributes.sectionInsets.right
        let height = model.heightForProposed(width: width)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind
        kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let page = model else { return UICollectionReusableView() }
        switch page {
        case .confirm(let conversion, let ratesAPI):
            guard kind == UICollectionElementKindSectionFooter else { return UICollectionReusableView() }
            
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionFooter,
                withReuseIdentifier: ActionableFooterView.identifier,
                for: indexPath
                ) as? ActionableFooterView else { return UICollectionReusableView() }
            footer.title = LocalizationConstants.Exchange.sendNow
            footer.actionBlock = {
                self.coordinator.handle(event: .confirmExchange(conversion, ratesAPI))
            }

            return footer
            
        case .locked:
            switch kind {
            case UICollectionElementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: ExchangeLockedHeaderView.identifier,
                    for: indexPath
                    ) as? ExchangeLockedHeaderView else { return UICollectionReusableView() }
                header.closeTapped = { [weak self] in
                    guard let this = self else { return }
                    this.dismiss(animated: true, completion: nil)
                }
                
                return header
            case UICollectionElementKindSectionFooter:
                guard let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionFooter,
                    withReuseIdentifier: ActionableFooterView.identifier,
                    for: indexPath
                    ) as? ActionableFooterView else { return UICollectionReusableView() }
                footer.title = LocalizationConstants.Exchange.done
                
                return footer
            default:
                return UICollectionReusableView()
            }
        case .overview(let trade):
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: ExchangeDetailHeaderView.identifier,
                for: indexPath
                ) as? ExchangeDetailHeaderView else { return UICollectionReusableView() }
            header.title = trade.amountReceivedDisplayValue
            return header
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let page = model else { return .zero }
        switch page {
        case .confirm:
            return .zero
        case .locked:
            return CGSize(
                width: collectionView.bounds.width,
                height: ExchangeLockedHeaderView.estimatedHeight()
            )
        case .overview(let trade):
            let title = trade.amountReceivedDisplayValue
            let height = ExchangeDetailHeaderView.height(for: title)
            return CGSize(
                width: collectionView.bounds.width,
                height: height
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard let page = model else { return .zero }
        switch page {
        case .confirm, .locked:
            return CGSize(
                width: collectionView.bounds.width,
                height: ActionableFooterView.height()
            )
        case .overview:
            return .zero
        }
    }
}

extension ExchangeDetailViewController: ExchangeDetailCoordinatorDelegate {
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, updated models: [ExchangeCellModel]) {
        cellModels = models
        registerCells()
        registerSupplementaryViews()
        collectionView.reloadData()
    }
}

extension ExchangeDetailViewController: ExchangeDetailInterface {
    func navigationBarVisibility(_ visibility: Visibility) {
        guard let navController = navigationController else { return }
        navController.setNavigationBarHidden(visibility.isHidden, animated: false)
    }
    
    func updateBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }
    
    func updateTitle(_ value: String) {
        navigationItem.title = value
    }

    func loadingVisibility(_ visibility: Visibility, action: ExchangeDetailCoordinator.Action) {
        if visibility == .hidden {
            LoadingViewPresenter.shared.hideBusyView()
        } else {
            var text = LocalizationConstants.loading
            switch action {
            case .confirmExchange: text = LocalizationConstants.Exchange.sendingOrder
            }
            LoadingViewPresenter.shared.showBusyView(withLoadingText: text)
        }
    }
}
